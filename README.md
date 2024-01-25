# AWS Flask microservice example
This repo is a simple example of a calculator micro service where you submit your numbers to request_service. You can then pick up your result from calculator_service. for simplicity, services are created as an AWS lambda


## setup
you will need terraform and python3.9 to deploy this example. If you want to use a different version of python, adjust the code accordingly.

to install all python packages run this command in `services/request_service` and `services/calculator_serivce`:
```
pip3 install -r requirements.txt -t ./
```

commands to deploy:
```
terraform init
terraform plan
terraform apply -auto-approve
```



## basic architecture
request_service will receive 2 numbers (num1,num2) as a post request.
it will return a request_id which will be used later to get the result.

request_service will send an event to eventbridge(request_bus) of num1,num2,request_id

eventbridge will send over the event to calculator_service.
calculator service will find sum of num1+num2 and then save the result into dynamodb.

if a http request is made to calculator_service_url/result/<request_id> it will find the result
from dynamodb and return it to the user.


