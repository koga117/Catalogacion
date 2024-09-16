import json

def lambda_handler(event, context):
    try:
        # Obtener el monto del pago
        payment_amount = event.get('payment_amount', None)
        
        # Verificar si payment_amount está presente y es un número
        if payment_amount is None:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'payment_amount no proporcionado'})
            }
        
        if not isinstance(payment_amount, (int, float)):
            return {
                'statusCode': 400,
                'body': json.dumps({'error': 'payment_amount debe ser un número'})
            }
        
        # Determinar el estado del pago
        if payment_amount > 0:
            return {
                'statusCode': 200,
                'body': json.dumps({'status': 'success'})
            }
        else:
            return {
                'statusCode': 422,
                'body': json.dumps({'status': 'failure', 'message': 'payment_amount debe ser mayor que 0'})
            }
    
    except Exception as e:
        # Manejo de errores generales
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'Error interno del servidor', 'message': str(e)})
        }
