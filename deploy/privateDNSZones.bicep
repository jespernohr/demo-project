param vNetId string

param privateDnsZones array

resource privateDnsZoneName_resource 'Microsoft.Network/privateDnsZones@2020-06-01' = [for item in privateDnsZones: {
  name: item
  location: 'global'
}]

resource privateDnsZoneName_linkingOf_privateDnsZoneName 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = [for item in range(0, length(privateDnsZones)): {
  parent: privateDnsZoneName_resource[item]
  name: 'linkingOf${privateDnsZoneName_resource[item].name}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vNetId
    }
  }
}]

output privateDNSZones array = privateDnsZones
