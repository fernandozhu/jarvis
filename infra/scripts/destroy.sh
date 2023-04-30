#!/bin/bash

source ../config/azure.sh

az group delete --name $resourceGroupName
