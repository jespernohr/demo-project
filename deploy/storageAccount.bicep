param storageAccountName string
param location string
param sku string = 'Standard_LRS'
param kind string = 'StorageV2'

resource sa 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: sku
  }
  kind: kind
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
  }
}

output storageAccountName string = sa.name
output storageAccountId string = sa.id
