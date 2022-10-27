param privateEndpointName string
param privateEndpointGroupIds array
param location string
param privateLinkServiceId string
param privateDNSZonesArray array
param privateDNSZonesResourceGroupId string
param virtualNetworkName string
param virtualNetworkResourceGroupId string
param subnetName string

var privateDNSZoneScope = split(privateDNSZonesResourceGroupId, '/')
var vnetScope = split(virtualNetworkResourceGroupId, '/')

resource privateDNSZones 'Microsoft.Network/privateDnsZones@2020-06-01' existing = [for privateDNSZone in privateDNSZonesArray: {
  name: privateDNSZone
  scope: resourceGroup(privateDNSZoneScope[2], privateDNSZoneScope[4])
}]

resource vnet 'Microsoft.Network/virtualNetworks@2022-01-01' existing = {
  name: virtualNetworkName
  scope: resourceGroup(vnetScope[2], vnetScope[4])
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = {
  parent: vnet
  name: subnetName
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          groupIds: privateEndpointGroupIds
          privateLinkServiceId: privateLinkServiceId
        }
      }
    ]
  }
}

resource privateDNSZoneGroups 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-01-01' = {
  parent: privateEndpoint
  name: '${privateEndpoint.name}PrivateDNSZoneGroup'
  properties: {
    privateDnsZoneConfigs: [for (privatednszone, index) in privateDNSZonesArray: {
      name: privateDNSZones[index].name
      properties: {
        privateDnsZoneId: privateDNSZones[index].id
      }
    }]
  }
}
