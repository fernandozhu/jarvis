param location string = resourceGroup().location
param keyVaultName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'stjarvis'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2022-09-01' = {
  name: 'default'
  parent: storageAccount
}

resource blobContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2022-09-01' = [for containerName in [ 'images' ]: {
  name: containerName
  parent: blobService
  properties: {
    publicAccess: 'None'
  }
}]

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource storageAccountConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'storage-account-connection'
  parent: keyVault
  properties: {
    value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
  }
}

output name string = storageAccount.name
