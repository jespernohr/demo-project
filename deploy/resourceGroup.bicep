targetScope = 'subscription'

param location string = 'westeurope'
param tags object = {
}

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg'
  location: location
  tags: tags
}
