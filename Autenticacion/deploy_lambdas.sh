#!/bin/bash

export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_REGION=us-east-1

# Nombre del bucket S3 para las funciones Lambda
BUCKET_NAME="my-lambda-bucket"

# Nombres de los archivos ZIP en el bucket S3
REGISTER_ZIP="register.zip"
LOGIN_ZIP="loginUser.zip"
AUTHORIZATION_ZIP="Authorization.zip"

# Funciones Lambda
REGISTER_FUNCTION_NAME="registerUser"
LOGIN_FUNCTION_NAME="loginUser"
AUTHORIZATION_FUNCTION_NAME="Authorization"

echo "Creating Table User..."
awslocal dynamodb create-table \
    --table-name Users \
    --attribute-definitions \
        AttributeName=userId,AttributeType=S \
        AttributeName=email,AttributeType=S \
    --key-schema \
        AttributeName=userId,KeyType=HASH \
    --provisioned-throughput \
        ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --global-secondary-indexes \
        "IndexName=email-index,KeySchema=[{AttributeName=email,KeyType=HASH}],Projection={ProjectionType=ALL},ProvisionedThroughput={ReadCapacityUnits=5,WriteCapacityUnits=5}"

echo "Creating Table Orders..."
awslocal dynamodb create-table --table-name Orders \
  --attribute-definitions AttributeName=OrderID,AttributeType=S \
  --key-schema AttributeName=OrderID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

echo "Creating Table Products..."
awslocal dynamodb create-table --table-name Products \
  --attribute-definitions AttributeName=ProductID,AttributeType=S \
  --key-schema AttributeName=ProductID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

echo "Insert Data Table Products"
aws dynamodb put-item \
    --endpoint-url=http://localhost:4566 \
    --table-name Products \
    --item '{"ProductID": {"S": "001"}, "ProductName": {"S": "Laptop"}, "ProductPrice": {"N": "999.99"}, "Description": {"S": "High-performance laptop with 16GB RAM and 512GB SSD."}}'
aws dynamodb put-item \
    --endpoint-url=http://localhost:4566 \
    --table-name Products \
    --item '{"ProductID": {"S": "002"}, "ProductName": {"S": "Smartphone"}, "ProductPrice": {"N": "499.99"}, "Description": {"S": "Latest model smartphone with a 48MP camera."}}'
aws dynamodb put-item \
    --endpoint-url=http://localhost:4566 \
    --table-name Products \
    --item '{"ProductID": {"S": "003"}, "ProductName": {"S": "Wireless Mouse"}, "ProductPrice": {"N": "29.99"}, "Description": {"S": "Ergonomic wireless mouse with long battery life."}}'
aws dynamodb put-item \
    --endpoint-url=http://localhost:4566 \
    --table-name Products \
    --item '{"ProductID": {"S": "004"}, "ProductName": {"S": "Bluetooth Headphones"}, "ProductPrice": {"N": "89.99"}, "Description": {"S": "Noise-cancelling Bluetooth headphones with built-in microphone."}}'

# API Gateway
API_NAME="AuthAPI"

# Crear el bucket S3
echo "Creating S3 bucket..."
awslocal s3 mb s3://$BUCKET_NAME

# Subir archivos ZIP a S3
echo "Uploading ZIP files to S3..."
awslocal s3 cp $REGISTER_ZIP s3://$BUCKET_NAME/
awslocal s3 cp $LOGIN_ZIP s3://$BUCKET_NAME/
awslocal s3 cp $AUTHORIZATION_ZIP s3://$BUCKET_NAME/

# Crear funciones Lambda
echo "Creating Lambda functions..."
awslocal lambda create-function --function-name $REGISTER_FUNCTION_NAME \
    --runtime nodejs18.x \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --handler registerUser.handler \
    --code S3Bucket=$BUCKET_NAME,S3Key=$REGISTER_ZIP \
    --region us-east-1

awslocal lambda create-function --function-name $LOGIN_FUNCTION_NAME \
    --runtime nodejs18.x \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --handler loginUser.handler \
    --code S3Bucket=$BUCKET_NAME,S3Key=$LOGIN_ZIP \
    --region us-east-1

awslocal lambda create-function --function-name $AUTHORIZATION_FUNCTION_NAME \
    --runtime nodejs18.x \
    --role arn:aws:iam::000000000000:role/lambda-role \
    --handler Authorization.handler \
    --code S3Bucket=$BUCKET_NAME,S3Key=$AUTHORIZATION_ZIP \
    --region us-east-1

# Crear la API Gateway
echo "Creating API Gateway..."
API_ID=$(awslocal apigateway create-rest-api --name "$API_NAME" --query 'id' --output text)
echo "API_ID: $API_ID"

# Obtener el ID del API Gateway
API_ID=$(awslocal apigateway get-rest-apis --query "items[?name=='$API_NAME'].id" --output text)
echo "API_ID: $API_ID"

echo "Current directory: $(pwd)"
cd ecomerce-frontend/public || { echo "Directory not found"; exit 1; }
echo "Changed to directory: $(pwd)"

# Crear el archivo con el ID
echo $API_ID > api-gateway-id.txt

# Volver al directorio original si es necesario
cd ../..

# Obtener el ID del recurso raíz
PARENT_ID=$(awslocal apigateway get-resources --rest-api-id $API_ID --query "items[0].id" --output text)
echo "PARENT_ID: $PARENT_ID"

# Crear recursos en el API Gateway
echo "Creating resources in API Gateway..."
REGISTER_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part "register" --query "id" --output text)
LOGIN_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part "login" --query "id" --output text)
AUTHORIZE_ID=$(awslocal apigateway create-resource --rest-api-id $API_ID --parent-id $PARENT_ID --path-part "authorize" --query "id" --output text)
echo "REGISTER_ID: $REGISTER_ID"
echo "LOGIN_ID: $LOGIN_ID"
echo "AUTHORIZE_ID: $AUTHORIZE_ID"

# Configurar métodos para los recursos
echo "Configuring methods for resources..."
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method POST --authorization-type NONE
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method POST --authorization-type NONE
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method POST --authorization-type NONE

# Configurar integración para los métodos
echo "Configuring integration for methods..."
REGISTER_FUNCTION_ARN=$(awslocal lambda get-function --function-name $REGISTER_FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)
LOGIN_FUNCTION_ARN=$(awslocal lambda get-function --function-name $LOGIN_FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)
AUTHORIZATION_FUNCTION_ARN=$(awslocal lambda get-function --function-name $AUTHORIZATION_FUNCTION_NAME --query 'Configuration.FunctionArn' --output text)

echo "REGISTER_FUNCTION_ARN: $REGISTER_FUNCTION_ARN"
echo "LOGIN_FUNCTION_ARN: $LOGIN_FUNCTION_ARN"
echo "AUTHORIZATION_FUNCTION_ARN: $AUTHORIZATION_FUNCTION_ARN"

awslocal apigateway put-integration --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method POST --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$REGISTER_FUNCTION_ARN/invocations
awslocal apigateway put-integration --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method POST --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$LOGIN_FUNCTION_ARN/invocations
awslocal apigateway put-integration --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method POST --type AWS_PROXY --integration-http-method POST --uri arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/$AUTHORIZATION_FUNCTION_ARN/invocations

# Crear la integración de método para la autorización de la API
echo "Creating method response..."
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"

# Configurar los encabezados de CORS en la integración
echo "Configuring CORS headers..."
awslocal apigateway put-integration-response --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": "'*'", "method.response.header.Access-Control-Allow-Headers": "'*'", "method.response.header.Access-Control-Allow-Methods": "'OPTIONS,GET,PUT,POST,DELETE'"}'
awslocal apigateway put-integration-response --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": "'*'", "method.response.header.Access-Control-Allow-Headers": "'*'", "method.response.header.Access-Control-Allow-Methods": "'OPTIONS,GET,PUT,POST,DELETE'"}'
awslocal apigateway put-integration-response --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method POST --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": "'*'", "method.response.header.Access-Control-Allow-Headers": "'*'", "method.response.header.Access-Control-Allow-Methods": "'OPTIONS,GET,PUT,POST,DELETE'"}'

# Configurar el método OPTIONS para manejar CORS
echo "Configuring OPTIONS method for CORS..."
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method OPTIONS --authorization-type NONE --request-parameters method.request.header.Origin=true
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method OPTIONS --authorization-type NONE --request-parameters method.request.header.Origin=true
awslocal apigateway put-method --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method OPTIONS --authorization-type NONE --request-parameters method.request.header.Origin=true

# Configurar respuesta de OPTIONS
echo "Configuring OPTIONS method response..."
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $REGISTER_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $LOGIN_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"
awslocal apigateway put-method-response --rest-api-id $API_ID --resource-id $AUTHORIZE_ID --http-method OPTIONS --status-code 200 --response-parameters '{"method.response.header.Access-Control-Allow-Origin": true, "method.response.header.Access-Control-Allow-Headers": true, "method.response.header.Access-Control-Allow-Methods": true}' --response-models "{}"

# Desplegar la API
echo "Deploying API..."
awslocal apigateway create-deployment --rest-api-id $API_ID --stage-name dev

echo "Deployment complete."
