resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'vnet-lab'
  location: 'east us'
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'snet-aks'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'snet-appgw'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

output aks_node_subnet string = virtualNetwork.properties.subnets[0].id
output appgw_subnet string = virtualNetwork.properties.subnets[1].id
