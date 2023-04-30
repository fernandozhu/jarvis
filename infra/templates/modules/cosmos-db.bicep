param location string = resourceGroup().location
param keyVaultName string

resource noSqlAccount 'Microsoft.DocumentDB/databaseAccounts@2022-11-15' = {
  name: 'cosno-jarvis'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    databaseAccountOfferType: 'Standard'
  }
}

resource noSqlDatabase 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2022-11-15' = {
  parent: noSqlAccount
  name: 'cosmos-jarvis'
  properties: {
    resource: {
      id: 'cosmos-jarvis'
    }
  }
}

resource noSqlContainer 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2022-11-15' = {
  parent: noSqlDatabase
  name: 'jarvis-nosql-db'
  properties: {
    resource: {
      id: 'jarvis-nosql-db'
      partitionKey: {
        paths: [
          '/date'
        ]
        kind: 'Hash'
      }
    }
  }
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' existing = {
  name: keyVaultName
}

resource cosmosConnectionString 'Microsoft.KeyVault/vaults/secrets@2023-02-01' = {
  name: 'cosmosdb-connection'
  parent: keyVault
  properties: {
    value: noSqlAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}
