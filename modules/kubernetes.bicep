resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: 'craks'
  location: resourceGroup().location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

var ACRPullRole = concat('/subscriptions/', subscription().subscriptionId, '/providers/Microsoft.Authorization/roleDefinitions/', '7f951dda-4ed3-4680-a7ca-43fe172d538d')
param AcrPull string = newGuid()
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: AcrPull
  scope: containerRegistry
  properties: {
    roleDefinitionId: ACRPullRole
    principalId: aksCluster.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: 'log-k8s'
  location: resourceGroup().location
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

@secure()
@description('SSH key used for linux nodes')
param ssh_public_key string
@description('aks admin name')
param k8s_admin_name string = 'aks_admin'
@description('subnet that aks nodes should be in')
param aks_node_subnet string
param appgw_subnet string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: 'aks-lab'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: 'dns'
    enableRBAC: true
    agentPoolProfiles: [
      {
        name: 'systempool'
        count: 3
        vmSize: 'Standard_B2ms'
        osType: 'Linux'
        mode: 'System'
        availabilityZones: [
          '1'
          '2'
          '3'
        ]
        enableAutoScaling: true
        vnetSubnetID: aks_node_subnet
        minCount: 1
        maxCount: 3
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
    linuxProfile: {
      adminUsername: k8s_admin_name
      ssh: {
        publicKeys: [
          {
            keyData: ssh_public_key
          }
        ]
      }
    }
    aadProfile: {
      managed: true
    }
    addonProfiles: {
      omsagent:{
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspace.id
        }
      }
      ingressApplicationGateway:{
        enabled: true
        config: {
          subnetID: appgw_subnet
        }
      }
    }
    networkProfile: {
      networkPlugin: 'azure'
      networkMode: 'transparent'
      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.200'
    }
  }
  resource agent_pool_1 'agentPools' = {
    name: 'agentpool1'
    properties: {
      count: 3
      enableAutoScaling: true
      minCount: 3
      maxCount: 5
      vnetSubnetID: aks_node_subnet
      osType: 'Linux'
      vmSize: 'Standard_B2ms'
      mode: 'User'
      type: 'VirtualMachineScaleSets'
      availabilityZones: [
        '1'
        '2'
        '3'
      ]      
    }
  }
}

output aks_identity string = aksCluster.identity.principalId 
