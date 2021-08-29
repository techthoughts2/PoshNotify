// ------
// Scopes
// ------

targetScope = 'resourceGroup'

// ---------
// Parameters
// ---------

param location string
param projectName string
param owner string
@allowed([
  'dev'
  'prod'
])
param environmentType string

// ---------
// Variables
// ---------

var uniqueResourceGroupName_var = uniqueString(projectName, location)
var businessCriticality = (environmentType == 'prod') ? 'Medium' : 'Low'
// var location = resourceGroup().location

// ---------
// Resources
// ---------

// example of how to create a resource group in the main
// // https://docs.microsoft.com/en-us/azure/templates/microsoft.resources/resourcegroups?tabs=bicep
// resource resource_group 'Microsoft.Resources/resourceGroups@2021-01-01' = {
//   name: '${projectName}-${uniqueResourceGroupName_var}'
//   location: location
//   tags: {
//     ProjectName: projectName
//     Environment: environmentType
//     Criticality: businessCriticality
//     Owner: owner
//     Location: location
//   }
//   // properties:{
//   // }
// }

// ---------
// Modules
// ---------

// this format can be re-used to deploy multiple sub-module resource files
module PoshNotifyResources 'poshnotify.bicep' = {
  name: 'PoshNotifyResources-${environmentType}'
  // scope: resource_group
  params: {
    projectName: projectName
    location: location
    owner: owner
    environmentType: environmentType
  }
}

// ---------
// Outputs
// ---------

// To reference module outputs
output storageAccountName string = PoshNotifyResources.outputs.storageAccountName
output storageAccountID string = PoshNotifyResources.outputs.storageAccountID

output containerName string = PoshNotifyResources.outputs.containerName
output containerID string = PoshNotifyResources.outputs.containerID

output tableName string = PoshNotifyResources.outputs.tableName
output tableID string = PoshNotifyResources.outputs.tableID

output keyVaultName string = PoshNotifyResources.outputs.keyVaultName
output keyVaultID string = PoshNotifyResources.outputs.keyVaultID

output planName string = PoshNotifyResources.outputs.planName
output planId string = PoshNotifyResources.outputs.planId

output functionAppName string = PoshNotifyResources.outputs.functionAppName
output functionAppID string = PoshNotifyResources.outputs.functionAppID

output appInsightsName string = PoshNotifyResources.outputs.appInsightsName
output appInsightsID string = PoshNotifyResources.outputs.appInsightsID

output saPermName string = PoshNotifyResources.outputs.saPermName
output saPermID string = PoshNotifyResources.outputs.saPermID

output conPermName string = PoshNotifyResources.outputs.conPermName
output conPermID string = PoshNotifyResources.outputs.conPermID

output tablePermName string = PoshNotifyResources.outputs.tablePermName
output tablePermID string = PoshNotifyResources.outputs.tablePermID
