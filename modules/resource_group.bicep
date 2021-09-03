targetScope = 'subscription'

param resourcePrefix string = 'rg'
param environment string
param location string
param name string
param tags object

resource resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: '${resourcePrefix}-${name}-${environment}-${location}'
  location: location
  tags: tags
  properties: {
  }
}

output rg_name string = resource_group.name
