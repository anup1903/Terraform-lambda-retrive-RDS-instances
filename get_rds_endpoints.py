# Save this as list_rds_instances.py
import boto3
from datetime import datetime, timedelta

def lambda_handler(event, context):
    # Initialize AWS services
    dynamodb = boto3.resource('dynamodb')
    table = dynamodb.Table('RDSInstancesTable')  # Replace with your DynamoDB table name

    # List RDS instances
    rds_client = boto3.client('rds')
    response = rds_client.describe_db_instances()

    # Extract and store information in DynamoDB
    for db_instance in response['DBInstances']:
        endpoint = db_instance['Endpoint']['Address']
        instance_type = db_instance['DBInstanceIdentifier']

        table.put_item(
            Item={
                'Endpoint': endpoint,
                'InstanceType': instance_type
            }
        )

    return {
        'statusCode': 200,
        'body': 'RDS instances listed and stored in DynamoDB.'
    }
