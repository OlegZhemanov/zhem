import json
import boto3
import os

def lambda_handler(event, context):
    # Get SNS topic ARN from environment variables
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    try:
        # Parse the input - could come directly from event or event body
        if 'body' in event:
            # API Gateway proxy integration sends JSON in body
            message_data = json.loads(event['body'])
        else:
            # Direct invocation case
            message_data = event
        
        # Validate required fields
        required_fields = ['name', 'email', 'message']
        for field in required_fields:
            if field not in message_data:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': f'Missing required field: {field}'})
                }
        
        # Create SNS client
        sns_client = boto3.client('sns')
        
        # Publish message
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=json.dumps(message_data),
            Subject=f"New message from {message_data['name']}"
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully published to SNS',
                'messageId': response['MessageId']
            })
        }
    
    except json.JSONDecodeError:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'Invalid JSON format'})
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }