param storageAccountName string
param location string
param sku string = 'Standard_LRS'
param kind string = 'StorageV2'
param disablePublicAccess bool = true

resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: disablePublicAccess ? false : true
    publicNetworkAccess: disablePublicAccess ? 'Disabled' : 'Enabled'
    networkAcls: {
      defaultAction: disablePublicAccess ? 'Deny' : 'Allow'
      bypass: 'AzureServices'
    }
  }
}

output storageAccountName string = sa.name
output storageAccountId string = sa.id
