#!/bin/bash
source ../config/variables.sh

pushd ./$funcJarvis
# Deploy Azure Function code to Function App
npm run build
func azure functionapp publish $funcAppName
popd 