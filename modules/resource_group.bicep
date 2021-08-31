targetScope = 'subscription'

param resource_group_name string
resource resource_group 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resource_group_name
  location: 'east us'
  tags: {
    location: 'east us'
  }
  properties: {
  }
}

output rg_name string = resource_group.name
