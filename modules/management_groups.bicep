targetScope = 'tenant'

resource mg_non_prod 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'Non-Prod'
  properties: {
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/4f86b03e-3df6-4d41-b222-9582f9e231cb'
      }
    }
    displayName: 'Non-Prod'
  }
}

resource mg_prod 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'Production'
  properties: {
    details: {
      parent: {
        id: '/providers/Microsoft.Management/managementGroups/4f86b03e-3df6-4d41-b222-9582f9e231cb'
      }
    }
    displayName: 'Production'
  }
}

resource mg_prod_eastus 'Microsoft.Management/managementGroups@2021-04-01' = {
  name: 'EastUS'
  properties: {
    details: {
      parent: {
        id: mg_prod.id
      }
    }
    displayName: 'EastUS'
  }
}

output mg_prod_id string = mg_prod.id
output mg_prod_eastus_id string = mg_prod_eastus.id
output mg_non_prod_id string = mg_non_prod.id
