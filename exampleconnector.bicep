param connections_office365_Block_EntraIDUser_Incident_name string = 'office365-Block-EntraIDUser-Incident'

resource connections_office365_Block_EntraIDUser_Incident_name_resource 'Microsoft.Web/connections@2016-06-01' = {
  name: connections_office365_Block_EntraIDUser_Incident_name
  location: 'westeurope'
  kind: 'V1'
  properties: {
    displayName: connections_office365_Block_EntraIDUser_Incident_name
    statuses: [
      {
        status: 'Connected'
      }
    ]
    customParameterValues: {}
    nonSecretParameterValues: {}
    createdTime: '2023-12-18T14:22:23.7211315Z'
    changedTime: '2023-12-19T17:59:57.4225083Z'
    api: {
      name: 'office365'
      displayName: 'Office 365 Outlook'
      description: 'Microsoft Office 365 is a cloud-based service that is designed to help meet your organization\'s needs for robust security, reliability, and user productivity.'
      iconUri: 'https://connectoricons-prod.azureedge.net/releases/v1.0.1669/1.0.1669.3522/office365/icon.png'
      brandColor: '#0078D4'
      id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/office365'
      type: 'Microsoft.Web/locations/managedApis'
    }
    testLinks: [
      {
        requestUri: 'https://management.azure.com:443/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/RG-Sentinel-Playbooks/providers/Microsoft.Web/connections/${connections_office365_Block_EntraIDUser_Incident_name}/extensions/proxy/testconnection?api-version=2016-06-01'
        method: 'get'
      }
    ]
  }
}