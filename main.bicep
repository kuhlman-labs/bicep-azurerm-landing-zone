targetScope = 'tenant'

param subscriptionId string = 'f43de08a-5e35-4ea9-8ca1-11fc231ace6a'
param rootManagementGroup string = '4f86b03e-3df6-4d41-b222-9582f9e231cb'
@allowed([
  'non-prod'
  'prod'
])
param environment string = 'non-prod'
@allowed([
  'eastus'
  'eastus2'
])
param location string = 'eastus'
param tags object = {
  location: location
  environment: environment
  deploymentType: 'Bicep'
}

module management_groups './modules/management_groups.bicep' = {
  name: 'management_groups' 
}

module policy_baseline './modules/policy_baseline.bicep' = {
  name: 'policy_baseline'
  scope: managementGroup(rootManagementGroup) 
}

module rg_network './modules/resource_group.bicep' = {
  name: 'rg-networking-${environment}-${location}'
  scope: subscription(subscriptionId)
  params: {
    name: 'networking'
    location: location
    environment: environment
    tags: tags
  }
}

module network_module './modules/network.bicep' = {
  name: 'network_module'
  scope: resourceGroup(subscriptionId, rg_network.name)
  params: {
    environment: environment
    tags: tags
  }
}

module rg_kubernetes './modules/resource_group.bicep' = {
  name: 'rg-kubernetes-${environment}-${location}'
  scope: subscription(subscriptionId)
  params: {
    name: 'kubernetes'
    location: location
    environment: environment
    tags: tags
  }
}

@secure()
param sshPublicKey string
module kubernetes_module './modules/kubernetes.bicep' = {
  name: 'kubernetes_module'
  scope: resourceGroup(subscriptionId, rg_kubernetes.name)
  params: {
    environment: environment
    sshPublicKey: sshPublicKey
    aksNodeSubnet: network_module.outputs.aksNodeSubnet
    appgwSubnet: network_module.outputs.appgwSubnet
    tags: tags
  }
}
