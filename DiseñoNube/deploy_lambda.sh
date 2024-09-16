#!/bin/bash

# Crear función Lambda
aws lambda create-function \
    --function-name myLambdaFunction \
    --zip-file fileb://function.zip \
    --handler lambda_function.lambda_handler \
    --runtime python3.8 \
    --role arn:aws:iam::123456789012:role/lambda-role \
    --endpoint-url=http://localhost:4566

# Esperar 10 segundos antes de intentar invocar
sleep 10

# Crear archivo de salida y agregar encabezados
echo "Invocando Lambda con payment_amount = 100 (Caso exitoso)" > output.txt

# Caso 1: payment_amount = 100
echo "Invocando Lambda con payment_amount = 100 (Caso exitoso)" >> output.txt
aws lambda invoke \
    --function-name myLambdaFunction \
    --payload '{"payment_amount": 100}' \
    --endpoint-url=http://localhost:4566 /tmp/output_case_1.txt \
    --cli-binary-format raw-in-base64-out
echo -e "Output del caso exitoso:" >> output.txt
cat /tmp/output_case_1.txt >> output.txt
echo -e "\n" >> output.txt

# Caso 2: payment_amount = 0
echo "Invocando Lambda con payment_amount = 0 (Caso fallido)" >> output.txt
aws lambda invoke \
    --function-name myLambdaFunction \
    --payload '{"payment_amount": 0}' \
    --endpoint-url=http://localhost:4566 /tmp/output_case_2.txt \
    --cli-binary-format raw-in-base64-out
echo -e "Output del caso fallido:" >> output.txt
cat /tmp/output_case_2.txt >> output.txt
echo -e "\n" >> output.txt

# Caso 3: Sin payment_amount
echo "Invocando Lambda sin payment_amount (Caso predeterminado)" >> output.txt
aws lambda invoke \
    --function-name myLambdaFunction \
    --payload '{}' \
    --endpoint-url=http://localhost:4566 /tmp/output_case_3.txt \
    --cli-binary-format raw-in-base64-out
echo -e "Output del caso predeterminado:" >> output.txt
cat /tmp/output_case_3.txt >> output.txt
echo -e "\n" >> output.txt

# Limpiar archivos temporales
rm -f /tmp/output_case_1.txt /tmp/output_case_2.txt /tmp/output_case_3.txt
