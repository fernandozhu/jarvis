param location string = resourceGroup().location
param keyVaultName string
param appleTeamId string
param appleAppBundleId string
param apnsAuthKey string
@secure()
param apnsToken string

resource notificationNamespace 'Microsoft.NotificationHubs/namespaces@2017-04-01' = {
  name: 'ntfns-jarvis'
  location: location
  sku: {
    name: 'Free'
  }
}

resource notificationHub 'Microsoft.NotificationHubs/namespaces/notificationHubs@2017-04-01' = {
  name: 'ntf-jarvis'
  location: location
  parent: notificationNamespace
  properties: {
    apnsCredential: {
      properties: {
        appId: appleTeamId
        appName: appleAppBundleId
        token: apnsToken
        keyId: apnsAuthKey
        endpoint: 'https://api.development.push.apple.com:443/3/device' // Sandbox
      }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource pushNotificationListenConnection 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'push-notification-connection-listen'
  parent: keyVault
  properties: {
    value: listKeys(resourceId('Microsoft.NotificationHubs/namespaces/notificationHubs/authorizationRules', notificationNamespace.name, notificationHub.name, 'DefaultListenSharedAccessSignature'), '2020-01-01-preview').primaryConnectionString
  }
}

resource pushNotificationFullAccessConnection 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'push-notification-connection-full'
  parent: keyVault
  properties: {
    value: listKeys(resourceId('Microsoft.NotificationHubs/namespaces/notificationHubs/authorizationRules', notificationNamespace.name, notificationHub.name, 'DefaultFullSharedAccessSignature'), '2020-01-01-preview').primaryConnectionString
  }
}
