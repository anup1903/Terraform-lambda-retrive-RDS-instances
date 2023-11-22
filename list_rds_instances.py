# Save this as get_rds_endpoints.py
import boto3
import json

def lambda_handler(event, context):
    # Initialize AWS services
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('RDSInstancesTable')  # Replace with your DynamoDB table name

    # Check if the instance type parameter is provided
    instance_type = event.get('queryStringParameters', {}).get('instanceType')

    # Query DynamoDB based on the optional parameter
    if instance_type:
        response = table.query(
            IndexName='InstanceTypeIndex',  # Create an index on InstanceType for efficient querying
            KeyConditionExpression='InstanceType = :type',
            ExpressionAttributeValues={
                ':type': instance_type
            }
        )
    else:
        response = table.scan()

    # Extract endpoints from the DynamoDB response
    endpoints = [item['Endpoint'] for item in response.get('Items', [])]

    return {
        'statusCode': 200,
        'body': json.dumps({'endpoints': endpoints})
    }
