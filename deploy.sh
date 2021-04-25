#!/bin/bash
# Thie script requires the following env variables 
# LAMBDA_LAYER_ARN=
# LAMBDA_FUNCTION_ARN=
set -e

# Check if required commands are available

aws --version $? -eq 0 || echo "aws cli not installed exiting" ; exit 1
jq --version $? -eq 0 || echo "jq not found exiting" ; exit 1

if [[ -z "$LAMBDA_FUNCTION_ARN" ]]; then
    echo "LAMBDA_FUNCTION_ARN is not set"
    exit 1
elif [[ -z "$LAMBDA_LAYER_ARN" ]]; then
    echo "LAMBDA_LAYER_ARN is not set"
    exit 1
fi

echo "zipping node_modules"
mkdir -p nodejs && cp -r node_modules nodejs/. && zip -r nodejs.zip nodejs && rm -r nodejs
echo "Done zipping node_modules"

echo "uploading layer"
layer_result=$(aws lambda publish-layer-version --layer-name "${LAMBDA_LAYER_ARN}" --zip-file fileb://nodejs.zip)
LAYER_VERSION=$(jq '.Version' <<< "$layer_result")
echo "$LAYER_VERSION"
rm -rf nodejs.zip
echo "Done Uploading Layer"

echo "updating Function"
zip -r function.zip . -x "*.ts" "*.git/*" "*.zip" "node_modules/*"
RESULT=$(aws lambda update-function-code --function-name "${LAMBDA_FUNCTION_ARN}" --zip-file fileb://function.zip)
jq '.State' <<< $RESULT
echo "Done Updating Function"


echo "Update layer version"
RESULT=$(aws lambda update-function-configuration --function-name "${LAMBDA_FUNCTION_ARN}" --layers "${LAMBDA_LAYER_ARN}:${LAYER_VERSION}")
jq '.State' <<< $RESULT
echo "Done updating layer version"
echo "Finished"
