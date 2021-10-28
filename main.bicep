//setting target scope for deployment https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deploy-to-tenant?tabs=azure-cli
targetScope = 'tenant'

//common variables for environment
@description('subscription id for deployment')
param subscriptionId string

@allowed([
  'non-prod'
  'prod'
])
@description('deployment environment')
param environment string = 'non-prod'

@allowed([
  'eastus'
  'eastus2'
])
@description('azure region for deployment')
param location string = 'eastus'

@description('resource tags for environment')
param tags object = {
  location: location
  environment: environment
  deploymentType: 'Bicep'
}

//creating management groups for azure ad tenant
module management_groups './modules/management_groups.bicep' = {
  name: 'management_groups' 
}

//creating baseline policies for all enviornments
@description('root management group id')
param rootManagementGroup string

module policy_baseline './modules/policy_baseline.bicep' = {
  name: 'policy_baseline'
  scope: managementGroup(rootManagementGroup) 
}

//creating resource group for environment networking components
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

//creating vnet and subnets for environment
module network_module './modules/network.bicep' = {
  name: 'network_module'
  scope: resourceGroup(subscriptionId, rg_network.name)
  params: {
    environment: environment
    tags: tags
  }
}

//creating resource group for environment kubernetes components
module rg_aks './modules/resource_group.bicep' = {
  name: 'rg-aks-${environment}-${location}'
  scope: subscription(subscriptionId)
  params: {
    name: 'aks'
    location: location
    environment: environment
    tags: tags
  }
}

//creating kubernetes enviornment resources
@secure()
@description('public key to use for kubernetes nodes')
param sshPublicKey string

@description('object id for aks admin azure ad group')
param aksAdminGroupObjectIDs array

module aks_module './modules/aks.bicep' = {
  name: 'aks_module'
  scope: resourceGroup(subscriptionId, rg_aks.name)
  params: {
    environment: environment
    sshPublicKey: sshPublicKey
    aksNodeSubnet: network_module.outputs.aksNodeSubnet
    appgwSubnet: network_module.outputs.appgwSubnet
    aksAdminGroupObjectIDs: aksAdminGroupObjectIDs
    tags: tags
  }
}
