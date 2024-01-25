import boto3
import awsgi
import uuid
import json
from flask import (
    Flask,
    jsonify,
    request,
)

app = Flask(__name__)

@app.route('/')
def index():
    return jsonify(status=200, message='please check /calculate endpoint!')


@app.route('/result/<uuid>',methods = ['GET'])
def get_result(uuid):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("calculation_results")
    response = table.get_item(
        Key = {
            'request_id'     : uuid
        },
        AttributesToGet=[
            'result', 'num1', 'num2', 'request_id'
        ]
    )
    
    if (response['ResponseMetadata']['HTTPStatusCode'] != 200):
        return "uuid not found"

    return response

def lambda_handler(event, context):
    print(event)
    print(context)
    
    if "httpMethod" in event:
        return awsgi.response(app, event, context)
    else: # it is an event
        num1 = int(event['detail']['num1'])
        num2 = int(event['detail']['num2'])
        request_id = event['detail']['request_id']
        result = num1 + num2
        
        dynamodb = boto3.resource("dynamodb")
        table = dynamodb.Table("calculation_results")
        
        item_data = {
            "num1":num1,
            "num2":num2,
            "result":result,
            "request_id": request_id
        }
        response = table.put_item(Item=item_data)

        return response
        
