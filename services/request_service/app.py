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
    return jsonify(status=200, message='please check /submit endpoint!')

@app.route('/submit',methods = ['POST'])
def login():
    num1 = request.form['num1']
    num2 = request.form['num2']
    request_id = str(uuid.uuid4())
    
    data = {
        "num1": num1,
        "num2": num2,
        "request_id" : request_id
    }

    client = boto3.client('events')
    response = client.put_events(Entries=[ {
        # "id": request_id,
        # "account":"123456789012",
        'Source': 'request_event',
        # "time": current_datetime.strftime("%Y-%m-%dT%H:%M:%SZ"),
        # "region":"ca-central-1",
        # "resources":"",
        'DetailType': 'calculation request',
        'Detail': json.dumps(data),
        'EventBusName': 'request_bus' },])

    return jsonify(status=200, message="addition request is submitted with uuid " + request_id, request_id=request_id)

def lambda_handler(event, context):
    return awsgi.response(app, event, context)
    # return {
    #     'statusCode': 200,
    #     'body': json.dumps('Hello from Lambda!')
    # }
    