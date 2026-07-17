# Azure Data Explorer Lab

## Deployment Scope

| Setting | Value |
| --- | --- |
| Tenant | DIB Security Commercial (`b22dee98-83da-4207-b9ab-5ba931866f44`) |
| Subscription | Student (`408bb797-a8dd-42f8-9b4a-66c71f7fa199`) |
| Resource group | `USAG-WSBDN-CYS-26` |
| Cluster name | `usag-wiesbaden-cys26` |
| Resource type | `Microsoft.Kusto/clusters` |
| Region | North Europe (`northeurope`) |
| SKU | `Dev(No SLA)_Standard_D11_v2` |
| Tier and capacity | `Basic`, `1` |
| Cluster type | Dev/Test, single node, no SLA |

## Access URLs

- [Azure portal cluster overview](https://portal.azure.com/#@b22dee98-83da-4207-b9ab-5ba931866f44/resource/subscriptions/408bb797-a8dd-42f8-9b4a-66c71f7fa199/resourceGroups/USAG-WSBDN-CYS-26/providers/Microsoft.Kusto/clusters/usag-wiesbaden-cys26/overview)
- [Azure portal resource group](https://portal.azure.com/#@b22dee98-83da-4207-b9ab-5ba931866f44/resource/subscriptions/408bb797-a8dd-42f8-9b4a-66c71f7fa199/resourceGroups/USAG-WSBDN-CYS-26/overview)
- [Azure Data Explorer web UI](https://dataexplorer.azure.com/clusters/https%3A%2F%2Fusag-wiesbaden-cys26.northeurope.kusto.windows.net)
- Query endpoint: `https://usag-wiesbaden-cys26.northeurope.kusto.windows.net`
- Ingestion endpoint: `https://ingest-usag-wiesbaden-cys26.northeurope.kusto.windows.net`

Sign in with the DIB Security identity before opening the portal or Data Explorer URLs.

## Template Configuration

[adx-dev-cluster.bicep](adx-dev-cluster.bicep) uses Azure Verified Module `avm/res/kusto/cluster:0.10.0` to deploy the cluster with the following configuration:

- Auto-stop, streaming ingestion, and purge enabled.
- Public network access enabled.
- Disk encryption and double encryption disabled.
- Resource tag: `createdBy=Lorenzo`.
- [cyber-defend-database.bicep](cyber-defend-database.bicep) creates the `cyber-defend-usagwsbdn-cys26` read-write database with 365-day retention and hot-cache policies.

## Deploy

Authenticate to the DIB Security tenant and select the Student subscription:

```powershell
Connect-AzAccount -Tenant 'b22dee98-83da-4207-b9ab-5ba931866f44' -Subscription '408bb797-a8dd-42f8-9b4a-66c71f7fa199'
Set-AzContext -Subscription '408bb797-a8dd-42f8-9b4a-66c71f7fa199'
```

Confirm that the Kusto resource provider is registered, then preview and deploy the template from the repository root:

```powershell
Get-AzResourceProvider -ProviderNamespace 'Microsoft.Kusto' |
  Select-Object ProviderNamespace, RegistrationState

New-AzResourceGroupDeployment `
  -Name 'usag-wiesbaden-cys26-d11v2-whatif' `
  -ResourceGroupName 'USAG-WSBDN-CYS-26' `
  -TemplateFile '.\azure-data-explorer\adx-dev-cluster.bicep' `
  -WhatIf

New-AzResourceGroupDeployment `
  -Name 'usag-wiesbaden-cys26-d11v2' `
  -ResourceGroupName 'USAG-WSBDN-CYS-26' `
  -TemplateFile '.\azure-data-explorer\adx-dev-cluster.bicep'
```

Do not redeploy or delete the same cluster name while its provisioning state is non-terminal.

## Cyber Defend Database Copy

| Setting | Value |
| --- | --- |
| Source cluster and database | `dibsecadx/cyber-defend-q0xxzc` in the Security subscription |
| Destination cluster and database | `usag-wiesbaden-cys26/cyber-defend-usagwsbdn-cys26` in Student |
| Source inventory at copy preparation | 48 tables, 358,621 rows, approximately 200.9 MB original data |
| Transfer method | Source schema script, UAMI-backed Parquet export, and table-by-table restore through temporary external tables |
| Backup identity | `uami-adx-backup` (`8b8fadd4-9d17-4471-b0c7-139625bfef12`) |
| Backup storage | `adxdibsecadx09da4d6a` / `adx-backups` |

The restore uses the current DIB Security user, which is an `AllDatabasesAdmin` on both clusters, to run the management commands. It does not use a shared key, SAS token, or user-level storage access. The shared `uami-adx-backup` identity has `Storage Blob Data Contributor` on the backup account and is used by both ADX clusters for storage access.

- [Destination database in the Azure portal](https://portal.azure.com/#@b22dee98-83da-4207-b9ab-5ba931866f44/resource/subscriptions/408bb797-a8dd-42f8-9b4a-66c71f7fa199/resourceGroups/USAG-WSBDN-CYS-26/providers/Microsoft.Kusto/clusters/usag-wiesbaden-cys26/databases/cyber-defend-usagwsbdn-cys26/overview)
- [Source database in the Azure portal](https://portal.azure.com/#@b22dee98-83da-4207-b9ab-5ba931866f44/resource/subscriptions/192ad012-896e-4f14-8525-c37a2a9640f9/resourceGroups/ADX/providers/Microsoft.Kusto/clusters/dibsecadx/databases/cyber-defend-q0xxzc/overview)

[backup-storage-private-endpoint.bicep](backup-storage-private-endpoint.bicep) manages the Student cluster's DFS managed private endpoint to the locked-down ADLS Gen2 backup account. The restore reads Parquet through that DFS endpoint; the storage-side private endpoint request must be approved before a restore can access the backup files.

Preview the schema and copy plan, then perform the copy:

```powershell
.\azure-data-explorer\restore-cyber-defend-database.ps1
.\azure-data-explorer\restore-cyber-defend-database.ps1 -Execute
```

The script uses the fixed `CopyId` `cyber-defend-usagwsbdn-cys26-initial` to group the export artifacts. It clones the source schema before it copies data, replaces each destination table from its exported snapshot, removes each temporary external table, and fails if any destination row count differs from the corresponding export row count.

### Initial Copy Verification

The initial copy was verified on July 14, 2026 with the following results:

- 48 source tables and 48 destination tables.
- 358,621 source rows and 358,621 destination rows.
- Source and destination database schema scripts match after normalizing the database name.

## Check Provisioning State

Run this command to check the live Azure Data Explorer lifecycle state:

```powershell
$cluster = Get-AzResource `
  -ResourceGroupName 'USAG-WSBDN-CYS-26' `
  -ResourceType 'Microsoft.Kusto/clusters' `
  -Name 'usag-wiesbaden-cys26' `
  -ExpandProperties

[pscustomobject]@{
  ClusterState = $cluster.Properties.state
  ProvisioningState = $cluster.Properties.provisioningState
  QueryUri = $cluster.Properties.uri
  DataIngestionUri = $cluster.Properties.dataIngestionUri
} | Format-List
```

The cluster is ready when the returned state is `Running` and the provisioning state is `Succeeded`.
