[CmdletBinding()]
param(
    [ValidatePattern('^[A-Za-z0-9-]+$')]
    [string]$CopyId = 'cyber-defend-usagwsbdn-cys26-initial',

    [switch]$Execute
)

$ErrorActionPreference = 'Stop'

$studentSubscriptionId = '408bb797-a8dd-42f8-9b4a-66c71f7fa199'
$sourceClusterUri = 'https://dibsecadx.eastus2.kusto.windows.net'
$sourceDatabaseName = 'cyber-defend-q0xxzc'
$destinationClusterUri = 'https://usag-wiesbaden-cys26.northeurope.kusto.windows.net'
$destinationDatabaseName = 'cyber-defend-usagwsbdn-cys26'
$backupStorageAccountName = 'adxdibsecadx09da4d6a'
$backupContainerName = 'adx-backups'
$backupIdentityObjectId = '8b8fadd4-9d17-4471-b0c7-139625bfef12'
$backupBlobPrefix = "https://$backupStorageAccountName.blob.core.windows.net/"
$backupDfsPrefix = "https://$backupStorageAccountName.dfs.core.windows.net/"

function Get-PlainTextAccessToken {
    $accessToken = (Get-AzAccessToken -ResourceUrl 'https://kusto.kusto.windows.net').Token

    if ($accessToken -is [System.Security.SecureString]) {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($accessToken)
        try {
            return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        }
        finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }

    return $accessToken
}

function Invoke-KustoManagement {
    param(
        [Parameter(Mandatory)]
        [string]$ClusterUri,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$Command
    )

    $body = @{ db = $DatabaseName; csl = $Command } | ConvertTo-Json -Compress
    try {
        Invoke-RestMethod -Method POST -Uri "$ClusterUri/v1/rest/mgmt" -Headers @{
            Authorization = "Bearer $(Get-PlainTextAccessToken)"
            'x-ms-client-request-id' = "restore-cyber-defend;$(New-Guid)"
        } -ContentType 'application/json; charset=utf-8' -Body $body -ErrorAction Stop
    }
    catch {
        $providerMessage = $_.Exception.Message
        if ($_.Exception.Response) {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            try {
                $providerMessage = $reader.ReadToEnd()
            }
            finally {
                $reader.Dispose()
            }
        }

        throw "Kusto management command failed for $ClusterUri/$DatabaseName.`nCommand: $Command`nProvider response: $providerMessage"
    }
}

function Get-KustoRows {
    param(
        [Parameter(Mandatory)]
        $Response
    )

    $resultTable = $Response.Tables[0]
    foreach ($row in $resultTable.Rows) {
        $item = [ordered]@{}
        for ($index = 0; $index -lt $resultTable.Columns.Count; $index++) {
            $item[$resultTable.Columns[$index].ColumnName] = $row[$index]
        }
        [pscustomobject]$item
    }
}

function Get-TableDetails {
    param(
        [Parameter(Mandatory)]
        [string]$ClusterUri,

        [Parameter(Mandatory)]
        [string]$DatabaseName,

        [Parameter(Mandatory)]
        [string]$TableName
    )

    $details = @(Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $ClusterUri -DatabaseName $DatabaseName -Command ".show table $TableName details"))
    if ($details.Count -ne 1) {
        throw "Expected one details row for table '$TableName' in database '$DatabaseName', but received $($details.Count)."
    }

    return $details[0]
}

function Get-TableColumnDefinition {
    param(
        [Parameter(Mandatory)]
        [string]$TableName
    )

    $schemaRows = @(Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $sourceClusterUri -DatabaseName $sourceDatabaseName -Command ".show table $TableName schema as json"))
    if ($schemaRows.Count -ne 1) {
        throw "Expected one schema row for table '$TableName', but received $($schemaRows.Count)."
    }

    $schema = $schemaRows[0].Schema | ConvertFrom-Json
    $columns = foreach ($column in $schema.OrderedColumns) {
        if ($column.Name -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
            throw "Column '$($column.Name)' in table '$TableName' needs an escaped identifier, which this script intentionally does not generate automatically."
        }

        "$($column.Name):$($column.CslType)"
    }

    return ($columns -join ', ')
}

function New-ExternalTableName {
    param(
        [Parameter(Mandatory)]
        [int]$TableIndex
    )

    return "CopyExport_${TableIndex}_$(([Guid]::NewGuid().ToString('N')).Substring(0, 12))"
}

$context = Get-AzContext
if ($context.Subscription.Id -ne $studentSubscriptionId) {
    throw "Select the Student subscription ($studentSubscriptionId) before running this script. Current subscription: $($context.Subscription.Id)."
}

$sourceTables = @(
    Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $sourceClusterUri -DatabaseName $sourceDatabaseName -Command '.show tables | project TableName') |
        ForEach-Object { $_.TableName } |
        Sort-Object
)

if ($sourceTables.Count -eq 0) {
    throw "The source database '$sourceDatabaseName' has no tables to copy."
}

foreach ($tableName in $sourceTables) {
    if ($tableName -notmatch '^[A-Za-z_][A-Za-z0-9_]*$') {
        throw "Table '$tableName' needs an escaped identifier, which this script intentionally does not generate automatically."
    }
}

$schemaRows = @(Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $sourceClusterUri -DatabaseName $sourceDatabaseName -Command '.show database schema as csl script with (ShowObfuscatedStrings = true)'))
$sourceSchemaScript = ($schemaRows | ForEach-Object { $_.DatabaseSchemaScript }) -join [Environment]::NewLine

if ([string]::IsNullOrWhiteSpace($sourceSchemaScript)) {
    throw "The source database '$sourceDatabaseName' did not return a schema script."
}

if (-not $Execute) {
    [pscustomobject]@{
        SourceTableCount = $sourceTables.Count
        SchemaScriptRows = $schemaRows.Count
        CopyId = $CopyId
        BackupPrefix = "https://$backupStorageAccountName.blob.core.windows.net/$backupContainerName/$CopyId"
        Result = 'Preview completed without changing the source, destination, or backup storage. Re-run with -Execute to export and restore data.'
    } | Format-List
    return
}

$destinationSchemaScript = $sourceSchemaScript -replace [regex]::Escape($sourceDatabaseName), $destinationDatabaseName
Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command ".execute database script <|`n$destinationSchemaScript" | Out-Null

$managedIdentityPolicy = '[{"ObjectId":"' + $backupIdentityObjectId + '","AllowedUsages":"ExternalTable"}]'
$policyCommand = '.alter-merge cluster policy managed_identity ```' + [Environment]::NewLine + $managedIdentityPolicy + [Environment]::NewLine + '```'
Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command $policyCommand | Out-Null

$destinationTables = @(
    Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command '.show tables | project TableName') |
        ForEach-Object { $_.TableName } |
        Sort-Object
)

$missingTables = @($sourceTables | Where-Object { $_ -notin $destinationTables })
if ($missingTables.Count -gt 0) {
    throw "The destination schema is missing source tables: $($missingTables -join ', ')."
}

$copyResults = for ($tableIndex = 0; $tableIndex -lt $sourceTables.Count; $tableIndex++) {
    $tableName = $sourceTables[$tableIndex]
    $sourceDetails = Get-TableDetails -ClusterUri $sourceClusterUri -DatabaseName $sourceDatabaseName -TableName $tableName
    $sourceRowsBeforeExport = [long]$sourceDetails.TotalRowCount
    $exportUri = "https://$backupStorageAccountName.blob.core.windows.net/$backupContainerName/$CopyId/$tableName;managed_identity=$backupIdentityObjectId"
    $exportCommand = ".export to parquet (h@'$exportUri') <| $tableName"
    $exportRows = @(Get-KustoRows -Response (Invoke-KustoManagement -ClusterUri $sourceClusterUri -DatabaseName $sourceDatabaseName -Command $exportCommand))
    $exportedRows = [long](($exportRows | Measure-Object -Property NumRecords -Sum).Sum)

    if ($sourceRowsBeforeExport -gt 0 -and $exportRows.Count -eq 0) {
        throw "The export of '$tableName' returned no blobs for $sourceRowsBeforeExport source rows."
    }

    $externalTableName = New-ExternalTableName -TableIndex $tableIndex
    $externalTableCreated = $false
    try {
        if ($exportedRows -gt 0) {
            $columnDefinition = Get-TableColumnDefinition -TableName $tableName
            $storageConnectionStrings = @($exportRows | ForEach-Object {
                $blobPath = [string]$_.Path
                if (-not $blobPath.StartsWith($backupBlobPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
                    throw "Export path '$blobPath' is not in the expected backup storage account."
                }

                $dfsPath = $backupDfsPrefix + $blobPath.Substring($backupBlobPrefix.Length)
                "h@'$dfsPath;managed_identity=$backupIdentityObjectId'"
            }) -join ",`n"
            $createExternalTableCommand = ".create external table $externalTableName ($columnDefinition) kind=storage dataformat=parquet (`n$storageConnectionStrings`n)"
            Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command $createExternalTableCommand | Out-Null
            $externalTableCreated = $true
            try {
                Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command ".set-or-replace $tableName <| external_table('$externalTableName')" | Out-Null
            }
            catch {
                $detailsAfterError = Get-TableDetails -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -TableName $tableName
                if ([long]$detailsAfterError.TotalRowCount -eq $exportedRows) {
                    Write-Warning "The restore command for '$tableName' returned an error after materializing $exportedRows rows. Continuing because the destination count matches the export snapshot."
                }
                else {
                    throw
                }
            }
        }
        elseif ($sourceRowsBeforeExport -eq 0) {
            Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command ".clear table $tableName data" | Out-Null
        }

        $destinationDetails = Get-TableDetails -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -TableName $tableName
        [pscustomobject]@{
            TableName = $tableName
            SourceRowsBeforeExport = $sourceRowsBeforeExport
            ExportedRows = $exportedRows
            DestinationRowsAfterRestore = [long]$destinationDetails.TotalRowCount
            MatchesExport = ($exportedRows -eq [long]$destinationDetails.TotalRowCount)
        }
    }
    finally {
        if ($externalTableCreated) {
            try {
                Invoke-KustoManagement -ClusterUri $destinationClusterUri -DatabaseName $destinationDatabaseName -Command ".drop external table $externalTableName" | Out-Null
            }
            catch {
                Write-Warning "The temporary external table '$externalTableName' could not be removed automatically. Review and remove it after the restore completes."
            }
        }
    }
}

$copyResults | Format-Table -AutoSize

$mismatches = @($copyResults | Where-Object { -not $_.MatchesExport })
if ($mismatches.Count -gt 0) {
    throw "Copy verification failed for: $($mismatches.TableName -join ', ')."
}

[pscustomobject]@{
    SourceDatabase = "$sourceClusterUri/$sourceDatabaseName"
    DestinationDatabase = "$destinationClusterUri/$destinationDatabaseName"
    BackupPrefix = "https://$backupStorageAccountName.blob.core.windows.net/$backupContainerName/$CopyId"
    TablesVerified = $copyResults.Count
    CopyId = $CopyId
    Result = 'Schema and exported-row-count verification succeeded.'
} | Format-List