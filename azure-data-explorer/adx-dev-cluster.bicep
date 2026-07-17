targetScope = 'resourceGroup'

param clusterName string = 'usag-wiesbaden-cys26'
param location string = 'northeurope'
param tags object = {
  createdBy: 'Lorenzo'
}

module cluster 'br/public:avm/res/kusto/cluster:0.10.0' = {
  name: '${clusterName}-deployment'
  params: {
    name: clusterName
    sku: 'Dev(No SLA)_Standard_D11_v2'
    capacity: 1
    enableAutoStop: true
    enableDiskEncryption: false
    enableDoubleEncryption: false
    enablePublicNetworkAccess: true
    enablePurge: true
    enableStreamingIngest: true
    location: location
    tags: tags
    tier: 'Basic'
  }
}

output clusterResourceId string = resourceId('Microsoft.Kusto/clusters', clusterName)
