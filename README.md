# Uploads Converted Typescript files to lambda with node_modules layer

## Usage:

required packages:
1. [aws cli](https://aws.amazon.com/cli/)
2. [jq](https://stedolan.github.io/jq/)

```
# Compile typescript files with
tsc

# Provide LAMBDA ENV
LAMBDA_LAYER_ARN=XXXX
LAMBDA_FUNCTION_ARN=XXXXX

#Run deploy.sh
./deploy.sh
```