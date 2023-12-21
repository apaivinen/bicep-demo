// CUSTOM STARTS
param o365connectorName string = 'office365-Email-Automation'
param location string = resourceGroup().location
targetScope = 'resourceGroup' //unnecessary due to default scope being RG already but left this in just for fun

resource o365connector 'Microsoft.Web/connections@2016-06-01' existing = {
  name: o365connectorName
}

// CUSTOM ENDS


param workflows_bicepdemo_name string = 'bicepdemo3'
// Deleted connection reference from here 


resource workflows_bicepdemo_name_resource 'Microsoft.Logic/workflows@2016-06-01' = {
  name: workflows_bicepdemo_name
  location: location                // MODIFIED LOCATION FROM HERE
  dependsOn:[                     // CUSTOM DEPENDS ON!!
    o365connector
  ]
  tags: {
    'LogicAppsCategory ': 'security'
  }
  properties: {
    state: 'Enabled'
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {
        '$connections': {
          defaultValue: {}
          type: 'Object'
        }
      }
      triggers: {
        When_a_HTTP_request_is_received: {
          type: 'Request'
          kind: 'Http'
        }
      }
      actions: {
        'Send_an_email_(V2)': {
          runAfter: {}
          type: 'ApiConnection'
          inputs: {
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
              }
            }
            method: 'post'
            body: {
              To: 'anssi@leikkikentta.onmicrosoft.com'
              Subject: 'demo testing'
              Body: '<p><span style="white-space: pre-wrap;">test content</span></p>'
              Importance: 'Normal'
            }
            path: '/v2/Mail'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          office365: {
            id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/office365'
            connectionId: o365connector.id                  // MODIFIED CONNECTOR ID
            connectionName: o365connector.name              // MODIFIED CONNECTOR NAME
          }
        }
      }
    }
  }
}
