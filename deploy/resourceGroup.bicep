targetScope = 'subscription'

param location string = 'westeurope'
param environment string
param environmentVersion string

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg'
  location: location
  tags: {
    environment: environment
    environmentVersion: environmentVersion
  }
}
