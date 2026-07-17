targetScope = 'resourceGroup'

param clusterName string = 'usag-wiesbaden-cys26'
param databaseName string = 'cyber-defend-usagwsbdn-cys26'
param location string = 'northeurope'
param softDeletePeriod string = 'P365D'
param hotCachePeriod string = 'P365D'

resource database 'Microsoft.Kusto/clusters/databases@2024-04-13' = {
  name: '${clusterName}/${databaseName}'
  location: location
  kind: 'ReadWrite'
  properties: {
    softDeletePeriod: softDeletePeriod
    hotCachePeriod: hotCachePeriod
  }
}

output databaseResourceId string = database.id
