param environment string
param tags object
param resourcePrefix string = 'vnet'
param vNetSettings object = {
  vnetPrefixes: [
    {
      name: 'vnet-prefix'
      addressPrefix: '10.0.0.0/16'
    }
  ]
  subnets: [
    {
      name: 'snet-aks'
      addressPrefix: '10.0.0.0/24'
    }
    {
      name: 'snet-appgw'
      addressPrefix: '10.0.1.0/24'
    }
  ]
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: '${resourcePrefix}-${environment}-${resourceGroup().location}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vNetSettings.vnetPrefixes[0].addressPrefix
      ]
    }
    subnets: [
      {
        name: vNetSettings.subnets[0].name
        properties: {
          addressPrefix: vNetSettings.subnets[0].addressPrefix
        }
      }
      {
        name: vNetSettings.subnets[1].name
        properties: {
          addressPrefix: vNetSettings.subnets[1].addressPrefix
        }
      }
    ]
  }
  tags: tags
}

output aksNodeSubnet string = virtualNetwork.properties.subnets[0].id
output appgwSubnet string = virtualNetwork.properties.subnets[1].id
