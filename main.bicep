targetScope = 'subscription'
param RGName string = 'RG-Sentinel-Playbooks-demo'
param resourceGroupLocation string = 'westeurope'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2019-04-01' existing = {
  name: RGName
  location: resourceGroupLocation
  properties: {}
}

