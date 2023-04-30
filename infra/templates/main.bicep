param location string = resourceGroup().location
param tenantId string = subscription().tenantId
param funcAppName string = 'func-jarvis'

var config = loadJsonContent('../config/ios.json')
var apnsToken = loadTextContent('../config/apnsToken.txt')

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: 'kv-jarvis'
  location: location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    tenantId: tenantId
    sku: {
      name: 'standard'
      family: 'A'
    }
    accessPolicies: []
  }
}

module cosmosDb './modules/cosmos-db.bicep' = {
  name: 'cosmosDb'
  params: {
    location: location
    keyVaultName: keyVault.name
  }
}

module funcApp './modules/function-app.bicep' = {
  name: 'functionApp'
  params: {
    location: location
    cosmosDbConnection: keyVault.getSecret('cosmosdb-connection')
    funcAppName: funcAppName
  }
}

module storageAccount './modules/storage-account.bicep' = {
  name: 'storageAccount'
  params: {
    location: location
    keyVaultName: keyVault.name
  }
}

module notificationHub './modules/notification-hub.bicep' = {
  name: 'notificationHub'
  params: {
    location: location
    keyVaultName: keyVault.name
    apnsToken: apnsToken
    appleAppBundleId: 'io.fernandozhu.Jarvis'
    appleTeamId: config.appleTeamId
    apnsAuthKey: config.apnsAuthKey
  }
}

resource keyVaultAccess 'Microsoft.KeyVault/vaults/accessPolicies@2023-02-01' = {
  parent: keyVault
  name: 'add'
  properties: {
    accessPolicies: [
      {
        objectId: config.administratorId
        tenantId: subscription().tenantId
        permissions: {
          keys: [ 'all' ]
          secrets: [ 'all' ]
        }
      }
      {
        objectId: funcApp.outputs.principalId
        tenantId: subscription().tenantId
        permissions: {
          secrets: [ 'get', 'set', 'list' ]
        }
      }
    ]
  }
}

module eventGrid './modules/event-grid.bicep' = {
  name: 'eventGrid'
  params: {
    funcAppName: funcAppName
    storageAccountName: storageAccount.outputs.name
  }
}
