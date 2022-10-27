param name string
param location string
param retentionInDays int

@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForIngestion string
@allowed([
  'Disabled'
  'Enabled'
])
param publicNetworkAccessForQuery string

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: name
  location: location
  properties: {
    retentionInDays: retentionInDays
    publicNetworkAccessForIngestion: publicNetworkAccessForIngestion
    publicNetworkAccessForQuery: publicNetworkAccessForQuery
    sku: {
      name: 'PerGB2018'
    }
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output workspaceName string = logAnalytics.name
output workspaceId string = logAnalytics.id
