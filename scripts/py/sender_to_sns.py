import json
import boto3
import os

def lambda_handler(event, context):
    # Get SNS topic ARN from environment variables
    sns_topic_arn = os.environ['SNS_TOPIC_ARN']
    
    try:
        # Parse the input
        if 'body' in event:
            message_data = json.loads(event['body'])
        else:
            message_data = event
        
        # Validate required fields
        required_fields = ['name', 'email', 'message']
        for field in required_fields:
            if field not in message_data:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': f'Missing required field: {field}'})
                }
        
        # Format message as plain text
        text_message = f"""
        Name: {message_data['name']}
        Email: {message_data['email']}
        Message: {message_data['message']}
        """
        
        # Create SNS client
        sns_client = boto3.client('sns')
        
        # Publish message with custom Subject
        response = sns_client.publish(
            TopicArn=sns_topic_arn,
            Message=text_message,
            Subject=f"New message from: {message_data['name']}"  # Измененный Subject
        )
        
        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Successfully published to SNS',
                'messageId': response['MessageId'],
                'subjectUsed': f"New message from: {message_data['name']}"  # Для отладки
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