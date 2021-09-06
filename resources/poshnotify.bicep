// An Azure Functions deployment typically consists of these resources:
// Microsoft.Web/sites
// Microsoft.Storage/storageaccounts
// microsoft.insights/components
// Microsoft.Web/serverfarms

// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Parameters
// ---------

param projectName string
param location string = resourceGroup().location
param owner string
@allowed([
  'dev'
  'prod'
])
param environmentType string

// ---------
// Variables
// ---------

var uniqueResourceNameBase_var = uniqueString(resourceGroup().id, location, deployment().name)
var businessCriticality = (environmentType == 'prod') ? 'Medium' : 'Low'
var secretName = (environmentType == 'prod') ? 'PoshSlack' : 'TestSlack'
var projectContainer = toLower(projectName)

// ---------
// Resources
// ---------

// https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts?tabs=bicep
resource storageaccount 'Microsoft.Storage/storageaccounts@2021-02-01' = {
  name: 'sa${uniqueResourceNameBase_var}'
  sku: {
    name: 'Standard_LRS'
    tier: 'Standard'
  }
  kind: 'StorageV2'
  location: location
  // extendedLocation: {
  //   name: 'string'
  //   type: 'EdgeZone'
  // }
  tags: {
    ProjectName: projectName
    Environment: environmentType
    Criticality: businessCriticality
    Owner: owner
    Location: location
  }
  // identity: {
  //   type: 'string'
  //   userAssignedIdentities: {}
  // }
  properties: {
    //   sasPolicy: {
    //     sasExpirationPeriod: 'string'
    //     expirationAction: 'Log'
    //   }
    //   keyPolicy: {
    //     keyExpirationPeriodInDays: int
    //   }
    //   customDomain: {
    //     name: 'string'
    //     useSubDomainName: bool
    //   }
    //   encryption: {
    //     services: {
    //       blob: {
    //         enabled: bool
    //         keyType: 'string'
    //       }
    //       file: {
    //         enabled: bool
    //         keyType: 'string'
    //       }
    //       table: {
    //         enabled: bool
    //         keyType: 'string'
    //       }
    //       queue: {
    //         enabled: bool
    //         keyType: 'string'
    //       }
    //     }
    //     keySource: 'string'
    //     requireInfrastructureEncryption: bool
    //     keyvaultproperties: {
    //       keyname: 'string'
    //       keyversion: 'string'
    //       keyvaulturi: 'string'
    //     }
    //     identity: {
    //       userAssignedIdentity: 'string'
    //     }
    //   }
    //   networkAcls: {
    //     bypass: 'string'
    //     resourceAccessRules: [
    //       {
    //         tenantId: 'string'
    //         resourceId: 'string'
    //       }
    //     ]
    //     virtualNetworkRules: [
    //       {
    //         id: 'string'
    //         action: 'Allow'
    //         state: 'string'
    //       }
    //     ]
    //     ipRules: [
    //       {
    //         value: 'string'
    //         action: 'Allow'
    //       }
    //     ]
    //     defaultAction: 'string'
    //   }
    //   accessTier: 'string'
    //   azureFilesIdentityBasedAuthentication: {
    //     directoryServiceOptions: 'string'
    //     activeDirectoryProperties: {
    //       domainName: 'string'
    //       netBiosDomainName: 'string'
    //       forestName: 'string'
    //       domainGuid: 'string'
    //       domainSid: 'string'
    //       azureStorageSid: 'string'
    //     }
    //   }
    supportsHttpsTrafficOnly: true
    //   isHnsEnabled: bool
    //   largeFileSharesState: 'string'
    //   routingPreference: {
    //     routingChoice: 'string'
    //     publishMicrosoftEndpoints: bool
    //     publishInternetEndpoints: bool
    //   }
    allowBlobPublicAccess: false
    //   minimumTlsVersion: 'string'
    //   allowSharedKeyAccess: bool
    //   isNfsV3Enabled: bool
  }
  // https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?tabs=bicep
  // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type
  resource blobcontainer 'blobServices' = {
    name: 'default'
    dependsOn: [
      storageaccount
    ]
    properties: {
      // defaultEncryptionScope: 'string'
      // denyEncryptionScopeOverride: bool
      // publicAccess: 'None'
      // metadata: {}
    }
    // resources: []
  }
  // https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices?tabs=bicep
  // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type
  resource tableService 'tableServices' = {
    name: 'default'
    dependsOn: [
      storageaccount
    ]
    properties: {
      // cors: {
      //   corsRules: [
      //     {
      //       allowedHeaders: [ 'string' ]
      //       allowedMethods: [ 'string' ]
      //       allowedOrigins: [ 'string' ]
      //       exposedHeaders: [ 'string' ]
      //       maxAgeInSeconds: int
      //     }
      //   ]
      // }
    }
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/blobservices/containers?tabs=bicep
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: '${storageaccount.name}/default/${projectContainer}'
  dependsOn: [
    storageaccount
  ]
  properties: {
    // defaultEncryptionScope: 'string'
    // denyEncryptionScopeOverride: bool
    publicAccess: 'None'
    // metadata: {}
  }
  // resources: []
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts/tableservices/tables?tabs=bicep
resource versiontable 'Microsoft.Storage/storageAccounts/tableServices/tables@2021-04-01' = {
  name: '${storageaccount.name}/default/versiontable'
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults?tabs=bicep
resource keyvault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'keyvault-${uniqueResourceNameBase_var}'
  dependsOn: [
    functionapp
  ]
  location: location
  tags: {
    ProjectName: projectName
    Environment: environmentType
    Criticality: businessCriticality
    Owner: owner
    Location: location
  }
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: reference(functionapp.id, '2019-08-01', 'full').identity.principalId
        // applicationId: 'string'
        permissions: {
          // keys: [
          //   'string'
          // ]
          secrets: [
            'get'
            'list'
          ]
          // certificates: [
          //   'string'
          // ]
          // storage: [
          //   'string'
          // ]
        }
      }
    ]
    //   vaultUri: 'string'
    //   enabledForDeployment: bool
    //   enabledForDiskEncryption: bool
    //   enabledForTemplateDeployment: bool
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    //   enableRbacAuthorization: bool
    //   createMode: 'string'
    //   enablePurgeProtection: bool
    //   networkAcls: {
    //     bypass: 'string'
    //     defaultAction: 'string'
    //     ipRules: [
    //       {
    //         value: 'string'
    //       }
    //     ]
    //     virtualNetworkRules: [
    //       {
    //         id: 'string'
    //       }
    //     ]
    //   }
  }
  // https://docs.microsoft.com/en-us/azure/templates/microsoft.keyvault/vaults/secrets?tabs=bicep
  // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type
  resource storageSecret 'secrets' = {
    name: 'sa-connectionstring'
    properties: {
      value: 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};AccountKey=${listKeys(storageaccount.id, storageaccount.apiVersion).keys[1].value}'
    }
  }
  // resource slackSecret 'secrets' = {
  //   name: secretName
  //   tags: {
  //     ProjectName: projectName
  //     Environment: environmentType
  //     Criticality: businessCriticality
  //     Owner: owner
  //     Location: location
  //   }
  //   properties: {
  //     value: 'test'
  //     contentType: 'string'
  //     attributes: {
  //       enabled: true
  //       // nbf: int
  //       // exp: int
  //     }
  //   }
  // }
}

//https://docs.microsoft.com/en-us/azure/templates/microsoft.web/serverfarms?tabs=bicep
resource appplan 'Microsoft.Web/serverfarms@2020-12-01' = {
  name: 'appplan-${uniqueResourceNameBase_var}'
  dependsOn: [
    storageaccount
  ]
  kind: 'functionapp'
  location: location
  tags: {
    ProjectName: projectName
    Environment: environmentType
    Criticality: businessCriticality
    Owner: owner
    Location: location
  }
  properties: {
    //   workerTierName: 'string'
    //   hostingEnvironmentProfile: {
    //     id: 'string'
    //   }
    perSiteScaling: false
    maximumElasticWorkerCount: 1
    isSpot: false
    //   spotExpirationTime: 'string'
    //   freeOfferExpirationTime: 'string'
    reserved: false
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    //   kubeEnvironmentProfile: {
    //     id: 'string'
    //   }
  }
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
    //   skuCapacity: {
    //     minimum: int
    //     maximum: int
    //     elasticMaximum: int
    //     default: int
    //     scaleType: 'string'
    //   }
    //   locations: [
    //     'string'
    //   ]
    //   capabilities: [
    //     {
    //       name: 'string'
    //       value: 'string'
    //       reason: 'string'
    //     }
    //   ]
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites?tabs=bicep
resource functionapp 'Microsoft.Web/sites@2020-12-01' = {
  name: 'functionapp-${uniqueResourceNameBase_var}'
  dependsOn: [
    storageaccount
    appplan
    appinsights
  ]
  kind: 'functionapp'
  location: location
  tags: {
    ProjectName: projectName
    Environment: environmentType
    Criticality: businessCriticality
    Owner: owner
    Location: location
  }
  properties: {
    enabled: true
    // hostNameSslStates: [
    //   {
    //     name: 'string'
    //     sslState: 'string'
    //     virtualIP: 'string'
    //     thumbprint: 'string'
    //     toUpdate: bool
    //     hostType: 'string'
    //   }
    // ]
    serverFarmId: appplan.id
    // reserved: false
    // isXenon: bool
    // hyperV: bool
    siteConfig: {
      //   numberOfWorkers: int
      //   defaultDocuments: [
      //     'string'
      //   ]
      //   netFrameworkVersion: 'string'
      //   phpVersion: 'string'
      //   pythonVersion: 'string'
      //   nodeVersion: 'string'
      powerShellVersion: '~7'
      //   linuxFxVersion: 'string'
      //   windowsFxVersion: 'string'
      //   requestTracingEnabled: bool
      //   requestTracingExpirationTime: 'string'
      //   remoteDebuggingEnabled: bool
      //   remoteDebuggingVersion: 'string'
      //   httpLoggingEnabled: bool
      //   logsDirectorySizeLimit: int
      //   detailedErrorLoggingEnabled: bool
      //   publishingUsername: 'string'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTION_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
      //   azureStorageAccounts: {}
      //   connectionStrings: [
      //     {
      //       name: 'string'
      //       connectionString: 'string'
      //       type: 'string'
      //     }
      //   ]
      //   handlerMappings: [
      //     {
      //       extension: 'string'
      //       scriptProcessor: 'string'
      //       arguments: 'string'
      //     }
      //   ]
      //   documentRoot: 'string'
      //   scmType: 'string'
      //   use32BitWorkerProcess: bool
      //   webSocketsEnabled: bool
      //   alwaysOn: bool
      //   javaVersion: 'string'
      //   javaContainer: 'string'
      //   javaContainerVersion: 'string'
      //   appCommandLine: 'string'
      //   managedPipelineMode: 'string'
      //   virtualApplications: [
      //     {
      //       virtualPath: 'string'
      //       physicalPath: 'string'
      //       preloadEnabled: bool
      //       virtualDirectories: [
      //         {
      //           virtualPath: 'string'
      //           physicalPath: 'string'
      //         }
      //       ]
      //     }
      //   ]
      //   loadBalancing: 'string'
      //   experiments: {
      //     rampUpRules: [
      //       {
      //         actionHostName: 'string'
      //         reroutePercentage: any('number')
      //         changeStep: any('number')
      //         changeIntervalInMinutes: int
      //         minReroutePercentage: any('number')
      //         maxReroutePercentage: any('number')
      //         changeDecisionCallbackUrl: 'string'
      //         name: 'string'
      //       }
      //     ]
      //   }
      //   limits: {
      //     maxPercentageCpu: any('number')
      //     maxMemoryInMb: int
      //     maxDiskSizeInMb: int
      //   }
      //   autoHealEnabled: bool
      //   autoHealRules: {
      //     triggers: {
      //       requests: {
      //         count: int
      //         timeInterval: 'string'
      //       }
      //       privateBytesInKB: int
      //       statusCodes: [
      //         {
      //           status: int
      //           subStatus: int
      //           win32Status: int
      //           path: 'string'
      //           count: int
      //           timeInterval: 'string'
      //         }
      //       ]
      //       statusCodesRange: [
      //         {
      //           statusCodes: 'string'
      //           path: 'string'
      //           count: int
      //           timeInterval: 'string'
      //         }
      //       ]
      //       slowRequests: {
      //         timeTaken: 'string'
      //         path: 'string'
      //         count: int
      //         timeInterval: 'string'
      //       }
      //       slowRequestsWithPath: [
      //         {
      //           timeTaken: 'string'
      //           path: 'string'
      //           count: int
      //           timeInterval: 'string'
      //         }
      //       ]
      //     }
      //     actions: {
      //       actionType: 'string'
      //       customAction: {
      //         exe: 'string'
      //         parameters: 'string'
      //       }
      //       minProcessExecutionTime: 'string'
      //     }
      //   }
      //   tracingOptions: 'string'
      //   vnetName: 'string'
      //   vnetRouteAllEnabled: bool
      //   vnetPrivatePortsCount: int
      //   cors: {
      //     allowedOrigins: [
      //       'string'
      //     ]
      //     supportCredentials: bool
      //   }
      //   push: {
      //     kind: 'string'
      //     properties: {
      //       isPushEnabled: bool
      //       tagWhitelistJson: 'string'
      //       tagsRequiringAuth: 'string'
      //       dynamicTagsJson: 'string'
      //     }
      //   }
      //   apiDefinition: {
      //     url: 'string'
      //   }
      //   apiManagementConfig: {
      //     id: 'string'
      //   }
      //   autoSwapSlotName: 'string'
      //   localMySqlEnabled: bool
      //   managedServiceIdentityId: int
      //   xManagedServiceIdentityId: int
      //   keyvaultReferenceIdentity: 'string'
      //   ipSecurityRestrictions: [
      //     {
      //       ipAddress: 'string'
      //       subnetMask: 'string'
      //       vnetSubnetResourceId: 'string'
      //       action: 'string'
      //       tag: 'string'
      //       priority: int
      //       name: 'string'
      //       description: 'string'
      //       headers: {}
      //     }
      //   ]
      //   scmIpSecurityRestrictions: [
      //     {
      //       ipAddress: 'string'
      //       subnetMask: 'string'
      //       vnetSubnetResourceId: 'string'
      //       action: 'string'
      //       tag: 'string'
      //       priority: int
      //       name: 'string'
      //       description: 'string'
      //       headers: {}
      //     }
      //   ]
      //   scmIpSecurityRestrictionsUseMain: bool
      //   http20Enabled: bool
      //   minTlsVersion: 'string'
      //   scmMinTlsVersion: 'string'
      //   ftpsState: 'string'
      //   preWarmedInstanceCount: int
      //   functionappScaleLimit: int
      //   healthCheckPath: 'string'
      //   functionsRuntimeScaleMonitoringEnabled: bool
      //   websiteTimeZone: 'string'
      //   minimumElasticInstanceCount: int
    }
    // scmSiteAlsoStopped: bool
    // hostingEnvironmentProfile: {
    //   id: 'string'
    // }
    // clientAffinityEnabled: bool
    // clientCertEnabled: bool
    // clientCertMode: 'string'
    // clientCertExclusionPaths: 'string'
    // hostNamesDisabled: bool
    // customDomainVerificationId: 'string'
    // containerSize: int
    // dailyMemoryTimeQuota: int
    // cloningInfo: {
    //   correlationId: 'string'
    //   overwrite: bool
    //   cloneCustomHostNames: bool
    //   cloneSourceControl: bool
    //   sourceWebAppId: 'string'
    //   sourceWebAppLocation: 'string'
    //   hostingEnvironment: 'string'
    //   appSettingsOverrides: {}
    //   configureLoadBalancing: bool
    //   trafficManagerProfileId: 'string'
    //   trafficManagerProfileName: 'string'
    // }
    // keyvaultReferenceIdentity: 'string'
    // httpsOnly: bool
    // redundancyMode: 'string'
    // storageaccountRequired: bool
  }
  identity: {
    type: 'SystemAssigned'
    // userAssignedIdentities: {}
  }

  // https://docs.microsoft.com/en-us/azure/templates/microsoft.web/sites/config-appsettings?tabs=bicep
  // https://docs.microsoft.com/en-us/azure/azure-functions/functions-app-settings
  // https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/child-resource-name-type
    // connection string references child resource secret from keyvault
  resource functionSettings 'config' = {
    name: 'appsettings'
    dependsOn: [
      functionapp
      keyvault
    ]
    properties: {
      'FUNCTIONS_EXTENSION_VERSION': '~3'
      'FUNCTIONS_WORKER_RUNTIME': 'powershell'
      'APPINSIGHTS_INSTRUMENTATIONKEY': appinsights.properties.InstrumentationKey
      'APPLICATIONINSIGHTS_CONNECTION_STRING': appinsights.properties.ConnectionString
      'AzureWebJobsStorage': 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageaccount.id, storageaccount.apiVersion).keys[0].value}'
      'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING': 'DefaultEndpointsProtocol=https;AccountName=${storageaccount.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${listKeys(storageaccount.id, storageaccount.apiVersion).keys[0].value}'
      'WEBSITE_CONTENTSHARE': functionapp.name
      'SA_CONNECTION_STRING': '@Microsoft.KeyVault(SecretUri=https://${keyvault.name}.vault.azure.net/secrets/${keyvault::storageSecret.name}/)'
      'SLACK_ENDPOINT': '@Microsoft.KeyVault(SecretUri=https://${keyvault.name}.vault.azure.net/secrets/slack-${environmentType}/)'
      'TOKEN': '@Microsoft.KeyVault(SecretUri=https://${keyvault.name}.vault.azure.net/secrets/tttoken/)'
      'CHANNEL': '@Microsoft.KeyVault(SecretUri=https://${keyvault.name}.vault.azure.net/secrets/ttchannel/)'
      'GITHUB_API_TOKEN': '@Microsoft.KeyVault(SecretUri=https://${keyvault.name}.vault.azure.net/secrets/githubapitoken/)'
      'CONTAINER_NAME': container.name
      'RESOURCE_GROUP': '${projectName}-${environmentType}'
      'STORAGE_ACCOUNT_NAME': storageaccount.name
      'TABLE_NAME': versiontable.properties.tableName
      'STAGE': environmentType
    }
  }
}

// https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/components?tabs=bicep
resource appinsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: 'appinsights-${uniqueResourceNameBase_var}'
  dependsOn: [
    storageaccount
  ]
  location: location
  tags: {
    ProjectName: projectName
    Environment: environmentType
    Criticality: businessCriticality
    Owner: owner
    Location: location
  }
  kind: 'other'
  properties: {
    Application_Type: 'other'
    // Flow_Type: 'Bluefield'
    Request_Source: 'rest'
    // HockeyAppId: 'string'
    // SamplingPercentage: any('number')
    // DisableIpMasking: bool
    ImmediatePurgeDataOn30Days: true
    // WorkspaceResourceId: 'string'
    // publicNetworkAccessForIngestion: 'string'
    // publicNetworkAccessForQuery: 'string'
    // IngestionMode: 'string'
  }
}

// c12c1c16-33a1-487b-954d-41c89c60f349 - Reader and Data Access
// Lets you view everything but will not let you delete or create a storage account or contained resource.
// It will also allow read/write access to all data contained in a storage account via access to storage account keys.
// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource storageAccountReadPermission 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(projectName, 'storageAccountReadPermission', uniqueResourceNameBase_var, subscription().subscriptionId)
  scope: storageaccount
  properties: {
    roleDefinitionId: '${subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'c12c1c16-33a1-487b-954d-41c89c60f349')}'
    principalId: reference(functionapp.id, '2019-08-01', 'full').identity.principalId
    // principalType: 'string'
    // description: 'string'
    // condition: 'string'
    // conditionVersion: 'string'
    // delegatedManagedIdentityResourceId: 'string'
  }
}

// b24988ac-6180-42a0-ab88-20f7382dd24c - Contributor
// ba92f5b4-2d11-453d-a403-e96b0029c9fe - Storage Blob Data Contributor
// Allows for read, write and delete access to Azure Storage blob containers and data
// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
resource containerPermission 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: guid(projectName, uniqueResourceNameBase_var, subscription().subscriptionId)
  scope: container
  properties: {
    roleDefinitionId: '${subscriptionResourceId('Microsoft.Authorization/roleDefinitions', 'ba92f5b4-2d11-453d-a403-e96b0029c9fe')}'
    principalId: reference(functionapp.id, '2019-08-01', 'full').identity.principalId
    // principalType: 'string'
    // description: 'string'
    // condition: 'string'
    // conditionVersion: 'string'
    // delegatedManagedIdentityResourceId: 'string'
  }
}

// b24988ac-6180-42a0-ab88-20f7382dd24c - Contributor
// 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3 - Storage Table Data Contributor
// Allows for read, write and delete access to Azure Storage tables and entities
// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/roleassignments?tabs=bicep
// resource versiontablePermission 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   name: guid(projectName, uniqueResourceNameBase_var, subscription().subscriptionId)
//   scope: versiontable
//   properties: {
//     roleDefinitionId: '${subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3')}'
//     principalId: reference(functionapp.id, '2019-08-01', 'full').identity.principalId
//     // principalType: 'string'
//     // description: 'string'
//     // condition: 'string'
//     // conditionVersion: 'string'
//     // delegatedManagedIdentityResourceId: 'string'
//   }
// }

// ---------
// Outputs
// ---------

output storageAccountName string = storageaccount.name
output storageAccountID string = storageaccount.id

output containerName string = container.name
output containerID string = container.id

output tableName string = versiontable.name
output tableID string = versiontable.id

output keyVaultName string = keyvault.name
output keyVaultID string = keyvault.id

output planName string = appplan.name
output planId string = appplan.id

output functionAppName string = functionapp.name
output functionAppID string = functionapp.id
output functionAppIdentity object = functionapp.identity

output appInsightsName string = appinsights.name
output appInsightsID string = appinsights.id

output saPermName string = storageAccountReadPermission.name
output saPermID string = storageAccountReadPermission.id

output conPermName string = containerPermission.name
output conPermID string = containerPermission.id

// output tablePermName string = versiontablePermission.name
// output tablePermID string = versiontablePermission.id
