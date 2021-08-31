targetScope = 'tenant'
param subscriptionId string

module governance './modules/management_groups.bicep' = {
  name: 'governance' 
}

module policy './modules/policy.bicep' = {
  name: 'Policy'
  scope: managementGroup('4f86b03e-3df6-4d41-b222-9582f9e231cb') 
}

module rg_network './modules/resource_group.bicep' = {
  name: 'rg-networking'
  scope: subscription(subscriptionId)
  params: {
    resource_group_name: 'rg-networking'
  }
}

module network_module './modules/network.bicep' = {
  name: 'network_module'
  scope: resourceGroup(subscriptionId, rg_network.name)
}

module rg_kubernetes './modules/resource_group.bicep' = {
  name: 'rg-kubernetes'
  scope: subscription(subscriptionId)
  params: {
    resource_group_name: 'rg-kubernetes'
  }
}

@secure()
param ssh_public_key string
module kubernetes_module './modules/kubernetes.bicep' = {
  name: 'kubernetes_module'
  scope: resourceGroup(subscriptionId, rg_kubernetes.name)
  params: {
    ssh_public_key: ssh_public_key
    aks_node_subnet: network_module.outputs.aks_node_subnet
    appgw_subnet: network_module.outputs.appgw_subnet
  }
}


