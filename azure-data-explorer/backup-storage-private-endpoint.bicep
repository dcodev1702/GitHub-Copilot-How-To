targetScope = 'resourceGroup'

param clusterName string = 'usag-wiesbaden-cys26'
param dfsEndpointName string = 'mpe-adxdibsecadx09da4d6a-dfs'
param backupStorageResourceId string = '/subscriptions/192ad012-896e-4f14-8525-c37a2a9640f9/resourceGroups/ADX/providers/Microsoft.Storage/storageAccounts/adxdibsecadx09da4d6a'
param backupStorageRegion string = 'eastus2'

resource backupStorageDfsPrivateEndpoint 'Microsoft.Kusto/clusters/managedPrivateEndpoints@2024-04-13' = {
  name: '${clusterName}/${dfsEndpointName}'
  properties: {
    groupId: 'dfs'
    privateLinkResourceId: backupStorageResourceId
    privateLinkResourceRegion: backupStorageRegion
    requestMessage: 'Student ADX Cyber Defend database restore access.'
  }
}

output dfsManagedPrivateEndpointResourceId string = backupStorageDfsPrivateEndpoint.id
