targetScope = 'subscription'

param location string
param environment string
param environmentVersion string

var logAnalyticsName = 'log-${environment}'

resource rgManagement 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-management'
  location: location
  tags: {
    environment: environment
    environmentVersion: environmentVersion
  }
}

resource rgNetwork 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-network'
  location: location
  tags: {
    environment: environment
    environmentVersion: environmentVersion
  }
}

resource rgStorage 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-storage'
  location: location
  tags: {
    environment: environment
    environmentVersion: environmentVersion
  }
}

module logAnalytics 'logAnalyticsWorkspace.bicep' = {
  scope: rgManagement
  name: 'deployLogAnalytics'
  params: {
    location: location
    name: logAnalyticsName
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
  }
}

module virtualNetwork 'virtualNetworks.bicep' = {
  name: 'VirtualNetwork'
  scope: rgNetwork
  params: {
    logAnalyticsId: logAnalytics.outputs.workspaceId
    name: 'vnet-sharedservices'
    location: 'westeurope'
    subnets: [
      {
        name: 'snet-pe'
        addressPrefix: '10.1.11.0/24'
        privateEndpointNetworkPolicies: 'Enabled'
        privateLinkServiceNetworkPolicies: 'Disabled'
        serviceEndpoints: []
      }
    ]
    addressPrefixes: [
      '10.1.10.0/23'
    ]
  }
}

module privateDNSZones 'privateDNSZones.bicep' = {
  scope: rgNetwork
  name: 'privateDNSZones'
  params: {
    privateDnsZones: [
      'privatelink.blob.${az.environment().suffixes.storage}'
    ]
    vNetId: virtualNetwork.outputs.virtualNetworkId
  }
}

module storageAccount 'storageAccount.bicep' = {
  scope: rgStorage
  name: 'storageAccount'
  params: {
    location: location
    storageAccountName: 'sa${substring(uniqueString(rgStorage.id), 0, 10)}'
  }
}

module privateEndpoint 'privateEndpoints.bicep' = {
  scope: rgNetwork
  name: 'privateEndpoint'
  params: {
    location: location
    privateDNSZonesArray: privateDNSZones.outputs.privateDNSZones
    privateDNSZonesResourceGroupId: rgNetwork.id
    privateEndpointGroupIds: [
      'blob'
    ]
    privateEndpointName: 'pe-storage'
    privateLinkServiceId: storageAccount.outputs.storageAccountId
    subnetName: 'snet-pe'
    virtualNetworkName: virtualNetwork.outputs.virtualNetworkName
    virtualNetworkResourceGroupId: rgNetwork.id
  }
}
