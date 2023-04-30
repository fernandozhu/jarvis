param storageAccountName string
param funcAppName string

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' existing = {
  name: storageAccountName

}

resource eventSubscription 'Microsoft.EventGrid/eventSubscriptions@2022-06-15' = {
  name: 'evgs-jarvis'
  scope: storageAccount
  properties: {

    eventDeliverySchema: 'EventGridSchema'
    destination: {
      endpointType: 'AzureFunction'
      properties: {
        resourceId: resourceId('Microsoft.Web/sites/functions', funcAppName, 'CatDetectionHandler')
        maxEventsPerBatch: 1
        preferredBatchSizeInKilobytes: 64
      }
    }

    filter: {
      includedEventTypes: [
        'Microsoft.Storage.BlobCreated'
      ]
      enableAdvancedFilteringOnArrays: true
    }
  }
}
