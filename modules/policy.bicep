targetScope = 'managementGroup'

resource policyAssignmentCIS 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'CIS Azure'
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/612b5213-9160-4969-8578-1518bd2a000c'
  }
}

resource policyAssignmentAKS 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: 'AKS Baseline'
  properties: {
    policyDefinitionId: '/providers/Microsoft.Authorization/policySetDefinitions/a8640138-9b0a-4a28-b8cb-1666c838647d'
  }
}
