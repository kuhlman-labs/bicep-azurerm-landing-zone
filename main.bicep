targetScope = 'subscription'

resource network_resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-networking'
  location: 'east us'
  tags: {
    location: 'east us'
  }
  properties: {
  }
}

resource kubernetes_resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-kubernetes'
  location: 'east us'
  tags: {
    location: 'east us'
  }
  properties: {
  }
}

module network_module './modules/network.bicep' = {
  name: 'network_module'
  scope: network_resource_group  
}

param ssh_public_key string

module kubernetes_module './modules/kubernetes.bicep' = {
  name: 'kubernetes_module'
  scope: kubernetes_resource_group
  params: {
    ssh_public_key: ssh_public_key
    aks_node_subnet: network_module.outputs.aks_node_subnet
    appgw_subnet: network_module.outputs.appgw_subnet
  }
}
