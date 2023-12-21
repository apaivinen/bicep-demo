param o365connectorName string = 'office365-Email-Automation'
param location string = resourceGroup().location

resource o365connector 'Microsoft.Web/connections@2016-06-01' existing = {
  name: o365connectorName
}

param workflows_Block_EntraIDUser_EntityTrigger_name string = 'Block-EntraIDUser-EntityTrigger-bicep'
param connections_azuread_Block_EntraIDUser_EntityTrigger_externalid string = '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/RG-Sentinel-Playbooks/providers/Microsoft.Web/connections/azuread-Block-EntraIDUser-EntityTrigger'
param connections_microsoftsentinel_Block_EntraIDUser_EntityTrigger_externalid string = '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/resourceGroups/RG-Sentinel-Playbooks/providers/Microsoft.Web/connections/microsoftsentinel-Block-EntraIDUser-EntityTrigger'


resource workflows_Block_EntraIDUser_EntityTrigger_name_resource 'Microsoft.Logic/workflows@2016-06-01' ={
  name: workflows_Block_EntraIDUser_EntityTrigger_name
  location: location
  dependsOn:[
    o365connector
  ]
  tags: {
    LogicAppsCategory: 'security'
    'hidden-SentinelTemplateName': 'Block-AADUser-EntityTrigger'
    'hidden-SentinelTemplateVersion': '1.1'
  }
  identity: {
    type: 'SystemAssigned'
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
        Microsoft_Sentinel_entity: {
          type: 'ApiConnectionWebhook'
          inputs: {
            body: {
              callback_url: '@{listCallbackUrl()}'
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'microsoftsentinel\'][\'connectionId\']'
              }
            }
            path: '/entity/@{encodeURIComponent(\'Account\')}'
          }
        }
      }
      actions: {
        Condition: {
          actions: {
            'Condition_-_if_user_have_manager': {
              actions: {
                Condition_2: {
                  actions: {
                    'Add_comment_to_incident_-_with_manager_-_no_admin': {
                      runAfter: {}
                      type: 'ApiConnection'
                      inputs: {
                        body: {
                          incidentArmId: '@triggerBody()?[\'IncidentArmID\']'
                          message: '<p>User @{triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\']} &nbsp;(UPN - @{variables(\'AccountDetails\')}) was disabled in AAD via playbook Block-AADUser. Manager (@{body(\'Parse_JSON_-_get_user_manager\')?[\'userPrincipalName\']}) is notified.</p>'
                        }
                        host: {
                          connection: {
                            name: '@parameters(\'$connections\')[\'microsoftsentinel\'][\'connectionId\']'
                          }
                        }
                        method: 'post'
                        path: '/Incidents/Comment'
                      }
                    }
                  }
                  runAfter: {
                    'Get_user_-_details': [
                      'Succeeded'
                    ]
                  }
                  expression: {
                    and: [
                      {
                        not: {
                          equals: [
                            '@triggerBody()?[\'IncidentArmID\']'
                            '@null'
                          ]
                        }
                      }
                    ]
                  }
                  type: 'If'
                }
                'Get_user_-_details': {
                  runAfter: {}
                  type: 'ApiConnection'
                  inputs: {
                    host: {
                      connection: {
                        name: '@parameters(\'$connections\')[\'azuread\'][\'connectionId\']'
                      }
                    }
                    method: 'get'
                    path: '/v1.0/users/@{encodeURIComponent(variables(\'AccountDetails\'))}'
                  }
                }
                'Send_an_email_-_to_manager_-_no_admin': {
                  runAfter: {
                    Condition_2: [
                      'Succeeded'
                    ]
                  }
                  type: 'ApiConnection'
                  inputs: {
                    body: {
                      Body: '<p>Security notification! This is automated email sent by Microsoft Sentinel Automation!<br>\n<br>\nYour direct report @{triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\']} has been disabled in Azure AD due to the security incident. Can you please notify the user and work with him to reach&nbsp;our support.<br>\n<br>\nDirect report details:<br>\nFirst name: @{body(\'Get_user_-_details\')?[\'displayName\']}<br>\nSurname: @{body(\'Get_user_-_details\')?[\'surname\']}<br>\nJob title: @{body(\'Get_user_-_details\')?[\'jobTitle\']}<br>\nOffice location: @{body(\'Get_user_-_details\')?[\'officeLocation\']}<br>\nBusiness phone: @{body(\'Get_user_-_details\')?[\'businessPhones\']}<br>\nMobile phone: @{body(\'Get_user_-_details\')?[\'mobilePhone\']}<br>\nMail: @{body(\'Get_user_-_details\')?[\'mail\']}<br>\n<br>\nThank you!</p>'
                      Importance: 'High'
                      Subject: '@{triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\']}  has been disabled in Azure AD due to the security risk!'
                      To: '@body(\'Parse_JSON_-_get_user_manager\')?[\'userPrincipalName\']'
                    }
                    host: {
                      connection: {
                        name: '@parameters(\'$connections\')[\'office365\'][\'connectionId\']'
                      }
                    }
                    method: 'post'
                    path: '/v2/Mail'
                  }
                }
              }
              runAfter: {
                'Parse_JSON_-_get_user_manager': [
                  'Succeeded'
                ]
              }
              else: {
                actions: {
                  Condition_3: {
                    actions: {
                      'Add_comment_to_incident_-_no_manager_-_no_admin': {
                        runAfter: {}
                        type: 'ApiConnection'
                        inputs: {
                          body: {
                            incidentArmId: '@triggerBody()?[\'IncidentArmID\']'
                            message: '<p>User @{triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\']} (UPN - @{variables(\'AccountDetails\')}) was disabled in AAD via playbook Block-AADUser. Manager has not been notified, since it is not found for this user!</p>'
                          }
                          host: {
                            connection: {
                              name: '@parameters(\'$connections\')[\'microsoftsentinel\'][\'connectionId\']'
                            }
                          }
                          method: 'post'
                          path: '/Incidents/Comment'
                        }
                      }
                    }
                    runAfter: {}
                    expression: {
                      and: [
                        {
                          not: {
                            equals: [
                              '@triggerBody()?[\'IncidentArmID\']'
                              '@null'
                            ]
                          }
                        }
                      ]
                    }
                    type: 'If'
                  }
                }
              }
              expression: {
                and: [
                  {
                    not: {
                      equals: [
                        '@body(\'Parse_JSON_-_get_user_manager\')?[\'userPrincipalName\']'
                        '@null'
                      ]
                    }
                  }
                ]
              }
              type: 'If'
            }
            'HTTP_-_get_user_manager': {
              runAfter: {}
              type: 'Http'
              inputs: {
                authentication: {
                  audience: 'https://graph.microsoft.com/'
                  type: 'ManagedServiceIdentity'
                }
                method: 'GET'
                uri: 'https://graph.microsoft.com/v1.0/users/@{variables(\'AccountDetails\')}/manager'
              }
            }
            'Parse_JSON_-_get_user_manager': {
              runAfter: {
                'HTTP_-_get_user_manager': [
                  'Succeeded'
                  'Failed'
                ]
              }
              type: 'ParseJson'
              inputs: {
                content: '@body(\'HTTP_-_get_user_manager\')'
                schema: {
                  properties: {
                    userPrincipalName: {
                      type: 'string'
                    }
                  }
                  type: 'object'
                }
              }
            }
          }
          runAfter: {
            'Update_user_-_disable_user': [
              'Succeeded'
              'Failed'
            ]
          }
          else: {
            actions: {
              'Add_comment_to_incident_-_error_details': {
                runAfter: {}
                type: 'ApiConnection'
                inputs: {
                  body: {
                    incidentArmId: '@triggerBody()?[\'IncidentArmID\']'
                    message: '<p>Block-AADUser playbook could not disable user @{triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\']}.<br>\nError message: @{body(\'Update_user_-_disable_user\')[\'error\'][\'message\']}<br>\nNote: If user is admin, this playbook don\'t have privilages to block admin users!</p>'
                  }
                  host: {
                    connection: {
                      name: '@parameters(\'$connections\')[\'microsoftsentinel\'][\'connectionId\']'
                    }
                  }
                  method: 'post'
                  path: '/Incidents/Comment'
                }
              }
            }
          }
          expression: {
            and: [
              {
                equals: [
                  '@body(\'Update_user_-_disable_user\')'
                  '@null'
                ]
              }
            ]
          }
          type: 'If'
        }
        Initialize_variable_Account_Details: {
          runAfter: {}
          type: 'InitializeVariable'
          inputs: {
            variables: [
              {
                name: 'AccountDetails'
                type: 'string'
              }
            ]
          }
        }
        Set_variable: {
          runAfter: {
            Initialize_variable_Account_Details: [
              'Succeeded'
            ]
          }
          type: 'SetVariable'
          inputs: {
            name: 'AccountDetails'
            value: '@{concat(triggerBody()?[\'Entity\']?[\'properties\']?[\'Name\'],\'@\',triggerBody()?[\'Entity\']?[\'properties\']?[\'UPNSuffix\'])}'
          }
        }
        'Update_user_-_disable_user': {
          runAfter: {
            Set_variable: [
              'Succeeded'
            ]
          }
          type: 'ApiConnection'
          inputs: {
            body: {
              accountEnabled: false
            }
            host: {
              connection: {
                name: '@parameters(\'$connections\')[\'azuread\'][\'connectionId\']'
              }
            }
            method: 'patch'
            path: '/v1.0/users/@{encodeURIComponent(variables(\'AccountDetails\'))}'
          }
        }
      }
      outputs: {}
    }
    parameters: {
      '$connections': {
        value: {
          azuread: {
            connectionId: connections_azuread_Block_EntraIDUser_EntityTrigger_externalid
            connectionName: 'azuread-${workflows_Block_EntraIDUser_EntityTrigger_name}'
            id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/azuread'
          }
          microsoftsentinel: {
            connectionId: connections_microsoftsentinel_Block_EntraIDUser_EntityTrigger_externalid
            connectionName: 'microsoftsentinel-${workflows_Block_EntraIDUser_EntityTrigger_name}'
            id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/azuresentinel'
            connectionProperties: {
              authentication: {
                type: 'ManagedServiceIdentity'
              }
            }
          }
          office365: {
            connectionId: o365connector.id
            connectionName: o365connector.name
            id: '/subscriptions/d781400b-6ce7-4b68-aaf2-6b71a353b7fc/providers/Microsoft.Web/locations/westeurope/managedApis/office365'
          }
        }
      }
    }
  }
}
