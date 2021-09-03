param environment string
param tags object

param random string = uniqueString(resourceGroup().id)
param containerRegistryPrefix string = 'cr'
param containerRegistrySKU string = 'Standard'
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2019-05-01' = {
  name: '${containerRegistryPrefix}${random}'
  location: resourceGroup().location
  sku: {
    name: containerRegistrySKU
  }
  properties: {
    adminUserEnabled: true
  }
  tags: tags
}


param acrPullName string = guid(resourceGroup().id)
param acrPullRole string = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d'
resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2021-04-01-preview' = {
  name: acrPullName
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRole
    principalId: aksCluster.identity.principalId
    principalType: 'ServicePrincipal'
  }
}

param logAnalyticsWorkspaceSKU string = 'free'
param logAnalyticsWorkspacePrefix string = 'log-${aksClusterPrefix}'
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: '${logAnalyticsWorkspacePrefix}-${environment}-${resourceGroup().location}'
  location: resourceGroup().location
  properties: {
    sku: {
      name: logAnalyticsWorkspaceSKU
    }
  }
}

param keyVaultPrefix string = 'kv-${aksClusterPrefix}'
param keyVaultSKU string = 'standard'
param keyVaultFamily string = 'A'
resource keyVault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: '${keyVaultPrefix}-${environment}-${resourceGroup().location}'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: aksCluster.properties.identityProfile.kubeletidentity.objectId
        permissions: {
          secrets: [
            'list'
            'get'
          ]
        }
      }
    ]
    sku: {
      name: keyVaultSKU
      family: keyVaultFamily
    }
  }
  tags: tags
}


@secure()
@description('ssh public key used for linux nodes')
param sshPublicKey string
@description('admin name for kubernetes cluster')
param adminName string = 'aks_admin'
@description('subnet for aks nodes')
param aksClusterPrefix string = 'aks'
param vmSize string = 'Standard_B2ms'
param zones array = [
  '1'
  '2'
  '3'
]
param aksNodeSubnet string
param appgwSubnet string


resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: '${aksClusterPrefix}-${environment}-${resourceGroup().location}'
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
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
        availabilityZones: zones
        enableAutoScaling: true
        vnetSubnetID: aksNodeSubnet
        minCount: 1
        maxCount: 3
        nodeTaints: [
          'CriticalAddonsOnly=true:NoSchedule'
        ]
      }
    ]
    linuxProfile: {
      adminUsername: adminName
      ssh: {
        publicKeys: [
          {
            keyData: sshPublicKey
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
          subnetID: appgwSubnet
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
      minCount: 1
      maxCount: 3
      vnetSubnetID: aksNodeSubnet
      osType: 'Linux'
      vmSize: vmSize
      mode: 'User'
      type: 'VirtualMachineScaleSets'
      availabilityZones: zones     
    }
  }
}

output aksIdentity string = aksCluster.identity.principalId 
output aksFQDN string = aksCluster.properties.azurePortalFQDN
