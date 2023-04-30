param location string = resourceGroup().location
param funcAppName string
@secure()
param cosmosDbConnection string

resource funcAppStorage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: 'stjarvisfuncmeta'
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
}

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: 'appi-jarvis'
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
  }
}

resource funcApp 'Microsoft.Web/sites@2022-03-01' = {
  name: 'func-jarvis'
  location: location
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    httpsOnly: true
    siteConfig: {
      appSettings: [
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcAppStorage.name};AccountKey=${funcAppStorage.listKeys().keys[0].value}'
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsights.properties.InstrumentationKey
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~18'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'node'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: funcAppName
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${funcAppStorage.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${funcAppStorage.listKeys().keys[0].value}'
        }
        {
          name: 'CosmosDbConnectionString'
          value: cosmosDbConnection
        }
      ]
    }
  }
}

@description('Function App identity')
output principalId string = funcApp.identity.principalId
