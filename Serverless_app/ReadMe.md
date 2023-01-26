# Serverless App - Arday-Of-Engineers

In this project we are going to implement a simple serverless application using S3, API Gateway, Lambda, Step Functions, SNS & SES.  

The project consists of 3 stages :-

[Design](https://bit.ly/3W3NqQc) 



##### Text based instructions 

## STAGE 1 - Set up Simple Email Service (SES) and add a Lambda function to use SES in order to send emails for the serverless application.

The Arday-Of-Engineers application is going to send reminder messages via SMS and Email.  It will use the simple email service or SES. In production, it could be configured to allow sending from the application email, to any users of the application. SES starts off in sandbox mode, which means you can only sent to verified addresses (to avoid you spamming). 

There is a whole [process to get SES out of sandbox mode](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/request-production-access.html), which you could do, but for this project we keep things quick - we will verify the sender address and the receiver address. 

Ensure you are logged into our AWS account, have admin privileges and are in the `us-east-2` / `Ohio` Region  
Move to the `SES` console  https://us-east-2.console.aws.amazon.com/ses/home?region=us-east-2#/homepage 
Click on `Verified Identities` under Configuration 
Click `Create Identity`  
Check the 'Email Address' checkbox  
*Ideally you will need a `sending` email address for the application and a `receiving email address` for your test customer. But you can use the same email for both.*  
For my application email ... the email the app will send from i'm going to use `my_email+arday@outlook.com`   
Click `Create Identity`  
  
Record this address somewhere save as the `ArdayOfEngineers Sending Address`  

If you want to use a different email address for the test customer (recommended), follow the steps below  
Click `Create Identity`  
Check the 'Email Address' checkbox 
For my application email ... the email for my test customer is  `my_email+ardaycustomer@outlook.com`   
Click `Create Identity`   
You will receive an email to this address containing a link to click  
Click that link   
You should see a `Congratulations!` message  
Return to the SES console and refresh your browser, the verification status should now be `verified`  
Record this address somewhere save as the `ArdayOfEngineers Customer Address`


**Next**, we need to create an IAM role which the email_reminder_lambda will use to interact with other AWS services.  
You could create this manually, but its easier to do this step using HCL-terraform to speed things up.  

Once apply succeeded Move to the IAM https://console.aws.amazon.com/iam/home?#/roles and review the execution role  
Notice that it provides SES, SNS and Logging permissions to whatever assumes this role.    
This is what gives lambda the permissions to interact with those services    

Next create the lambda function for the serverless application to create an email and then send it using `SES`  
Move to the lambda console https://us-east-2.console.aws.amazon.com/lambda/home?region=us-east-2#/functions

Click on `Create Function`  
Select `Author from scratch`  
For `Function name` enter `email_reminder_lambda`  
and for runtime click the dropdown and pick `Python 3.9`  
Expand `Change default execution role`  
Pick to `Use an existing Role`  
Click the `Existing Role` dropdown and pick `LambdaRole` (there will be randomness and thats ok)  
Click `Create Function` 

Scroll down, to `Function code`  
in the `lambda_function` code box, select all the code and delete it  

Paste in this code

```
import boto3, os, json

FROM_EMAIL_ADDRESS = 'REPLACE_ME'

ses = boto3.client('ses')

def lambda_handler(event, context):
    # Print event data to logs .. 
    print("Received event: " + json.dumps(event))
    # Publish message directly to email, provided by EmailOnly or EmailPar TASK
    ses.send_email( Source=FROM_EMAIL_ADDRESS,
        Destination={ 'ToAddresses': [ event['Input']['email'] ] }, 
        Message={ 'Subject': {'Data': 'Ardayda Commands You to attend!'},
            'Body': {'Text': {'Data': event['Input']['message']}}
        }
    )
    return 'Success!'
  
```

This function will send an email to an address it's supplied with (by step functions) and it will be FROM the email address we specify.    
Select `REPLACE_ME` and replace with the `ArdayOfEngineers Sending Address` which you noted down    
Click `Deploy` to configure the lambda function  


> at this point you have whitelisted 2 email addresses for use with SES.  
>
> - the `ArdayOfEngineers Sending Address`. 
> - the `ardayOfEngineers Customer Address`. 
>
> These will be configured and used by the application. 
> Also, you have configured the lambda function which will be used eventually to send emails on behalf of the serverless application. 




### STAGE 2 - CREATE STATE MACHINE & API gateway

State machine is the main component of the serverless application, it will manage the follow of the application, so this is an end-to-end serverless application where the state machine waits certain amount of time and then uses a lambda function to send notification to customer (ArdayOfEngineers customer)

Check Roles applied from Terraform are there.

Move to the AWS Step Functions Console https://us-east-2.console.aws.amazon.com/states/home?region=us-east-2#/homepage  
Click the `Menu` at the top left and click `State Machines`  
Click `Create State Machine`  
Select `Write your workflow in code` which will allow you to use Amazon States Language  
Scroll down
for `type` select `standard`  

this is the Amazon States Language (ASL) file for the `arday-of-engineers` state machine  
Copy the contents into your clipboard
```
{
  "Comment": "Aray Of Engineers - using Lambda for email.",
  "StartAt": "Timer",
  "States": {
    "Timer": {
      "Type": "Wait",
      "SecondsPath": "$.waitSeconds",
      "Next": "Email"
    },
    "Email": {
      "Type" : "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Parameters": {
        "FunctionName": "EMAIL_LAMBDA_ARN",
        "Payload": {
          "Input.$": "$"
        }
      },
      "Next": "NextState"
    },
    "NextState": {
      "Type": "Pass",
      "End": true
    }
  }
}
```
   
Select all of the code snippet delete it and Paste in your clipboard  

Click the `Refresh` icon on the right side area ... next to the visual map of the state machine.  
Look through the visual overview and the ASL .. and make sure you understand the flow through the state machine.  

The state machine starts ... and then waits for a certain time period based on the `Timer` state. This is controlled by the web front end we will deploy soon. Then the `email` is used Which sends an email reminder

The state machine will control the flow through the serverless application.. once stated it will coordinate other AWS services as required.

#### CONFIGURE STATE MACHINE 
In the state machine ASL (the code on the left) locate the `EmailOnly` definition.  
Look for `EMAIL_LAMBDA_ARN` which is a placeholder, replace this with the email_reminder_lambda ARN you noted down in the previous step. 

Scroll down to the bottom and click `next` 
For `State machine name` use `ArdayOfEngineers`  
Scroll down and under `Permissions` select `Choose an existing role` and select `StateMachineRole` from the dropdown 
Scroll down, under `Logging`, change the `Log Level` to `All`  
Scroll down to the bottom and click `Create state machine`  

Locate the `ARN` for the state machine... note this down somewhere safe as `State Machine ARN` 

#### CREATE API LAMBDA FUNCTION WHICH SUPPORTS APIGATEWAY

Move to the Lambda console https://us-east-2.console.aws.amazon.com/lambda/home?region=us-east-2#/functions 
Click on `Create Function`  
for `Function Name` use `arday_api_lambda`  
for `Runtime` use `Python 3.9`  
Expand `Change default execution role`  
Select `Use an existing role`  
Choose the `LambdaRole` from the dropdown  
Click `Create Function`  

This is the lambda function which will support the API Gateway

Scroll down, and remove all the code from the `lambda_function` text box

```
import boto3, json, os, decimal

SM_ARN = 'YOUR_STATEMACHINE_ARN'

sm = boto3.client('stepfunctions')

def lambda_handler(event, context):
    # Print event data to logs .. 
    print("Received event: " + json.dumps(event))

    # Load data coming from APIGateway
    data = json.loads(event['body'])
    data['waitSeconds'] = int(data['waitSeconds'])
    
    # Sanity check that all of the parameters we need have come through from API gateway
    # Mixture of optional and mandatory ones
    checks = []
    checks.append('waitSeconds' in data)
    checks.append(type(data['waitSeconds']) == int)
    checks.append('message' in data)

    # if any checks fail, return error to API Gateway to return to client
    if False in checks:
        response = {
            "statusCode": 400,
            "headers": {"Access-Control-Allow-Origin":"*"},
            "body": json.dumps( { "Status": "Success", "Reason": "Input failed validation" }, cls=DecimalEncoder )
        }
    # If none, start the state machine execution and inform client of 2XX success :)
    else: 
        sm.start_execution( stateMachineArn=SM_ARN, input=json.dumps(data, cls=DecimalEncoder) )
        response = {
            "statusCode": 200,
            "headers": {"Access-Control-Allow-Origin":"*"},
            "body": json.dumps( {"Status": "Success"}, cls=DecimalEncoder )
        }
    return response

# This is a workaround for: http://bugs.python.org/issue16535
# Solution discussed on this thread https://stackoverflow.com/questions/11942364/typeerror-integer-is-not-json-serializable-when-serializing-json-in-python
# https://stackoverflow.com/questions/1960516/python-json-serialize-a-decimal-object
# Credit goes to the group :)
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, decimal.Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)
```

copy it all into your clipboard
Move back to the Lambda console.  
Select the existing skeleton lambda code and delete it.  
Paste the code into the lambda fuction.  

> This is the function which will provide compute to API Gateway.  
> It's job is to be called by API Gateway when its used by the serverless front end part of the application (loaded by S3)
> It accepts some information from you, via API Gateway and then it starts a state machine execution - which is the logic of the application.  

You need to locate the `YOUR_STATEMACHINE_ARN` placeholder and replace this with the State Machine ARN you noted down earlier.  
Click `Deploy` to save the lambda function and configuration.     

#### CREATE API

The next step is to create the API Gateway, API and Method which the front end part of the serverless application will communicate with.  
Move to the API Gateway console https://us-east-2.console.aws.amazon.com/apigateway/main/apis?region=us-east-2 
Click `APIs` on the menu on the left  
Locate the `REST API` box, and click `Build` (being careful not to click the build button for any of the other types of API ... REST API is the one you need)
If you see a popup dialog `Create your first API` dismiss it by clicking `OK`  
Under `Create new API` ensure `New API` is selected.  

For `API name*` enter `ardayofengineers`  
for `Endpoint Type` pick `Regional` 
Click `create API`  

#### CREATE RESOURCE

Click the `Actions` dropdown and Click `Create Resource`  
Under resource name enter `ardayofengineers`  
make sure that `Configure as proxy resource` is **NOT** ticked - this forwards everything as is, through to a lambda function, because we want some control, we **DONT** want this ticked.  
Towards the bottom **MAKE SURE TO TICK** `Enable API Gateway CORS`.  
> This relaxes the restrictions on things calling on our API with a different DNS name, it allows the code loaded from the S3 bucket to call the API gateway endpoint. 

**if you DONT check this box, the API will fail**   
Click `Create Resource`  

#### CREATE METHOD

Ensure you have the `/ardayofengineers` resource selected, click `Actions` dropdown and click `create method`  
In the small dropdown box which appears below `/ardayofengineers` select `POST` and click the `tick` symbol next to it.  
> this method is what the front end part of the application will make calls to.  
> Its what the api_lambda will provide services for.  

Ensure for `Integration Type` that `Lambda Function` is selected.  
Make sure `us-east-2` is selected for `Lambda Region`  
In the `Lambda Function` box.. start typing `arday_api_lambda` and it should autocomplete, click this auto complete (**Make sure you pick arday_api_lambda and not email reminder lambda**)  

Make sure that `Use Default Timeout` box **IS** ticked.  
Make sure that `Use Lambda Proxy integration` box **IS** ticked, this makes sure that all of the information provided to this API is sent on to lambda for processing in the `event` data structure.  
**if you don't tick this box, the API will fail**  
Click `Save`  
You may see a dialogue stating `You are about to give API Gateway permission to invoke your Lambda function:`. AWS is asking for your OK to adjust the `resource policy` on the lambda function to allow API Gateway to invoke it.  This is a different policy to the `execution role policy` which controls the permissions lambda gets.  

<img width="1486" alt="image" src="https://user-images.githubusercontent.com/66903895/213867753-9dfac0ac-9f3b-4964-a5ab-d8485fd0fc80.png">


### - DEPLOY API  

Now the API, Resource and Method are configured - you now need to deploy the API out to API gateway, specifically an API Gateway STAGE.  
Click `Actions` Dropdown and `Deploy API`  
For `Deployment Stage` select `New Stage`  
for stage name and stage description enter `prod`  
Click `Deploy`  

At the top of the screen will be an `Invoke URL` .. note this down somewhere safe.  
> This URL will be used by the client side component of the serverless application. 


At this point you have configured:
The state machine which is the core part of the serverless application.
The state machine controls the flow through the application and is responsible for interacting with other AWS products and services.  
created the API Gateway and Lambda function which will act as the front end for the application.

Remeber that You now have :-

- SES Configured
- An Email Lambda function to send email using SES
- A State Machine configured which can send EMAIL after a certain time period when invoked.
- An API, Resource & Method, which use a lambda function for backing deployed out to the PROD stage of API Gateway

### STAGE 5 - CREATE THE S3 BUCKET

This is the final stage where we will deploy the Client side application
The application will load from an S3 bucket and run in browser
.. communicating with Lambda and Step functions via an API Gateway Endpoint
Using the application you will be able to configure reminders for 'arday engineers' to be sent using email.

Move to the S3 Console https://s3.console.aws.amazon.com/s3/buckets?region=us-east-2
Click `Create bucket`  
Choose a unique bucket name `arday-engineers`
Ensure the region is set to `US East (Ohio) us-east-2`  
Scroll Down and **UNTICK** `Block all public access`  
Tick the box under `Turning off block all public access might result in this bucket and the objects within becoming public` to acknowledge you understand that you can make the bucket public.  
Scroll Down to the bottom and click `Create bucket`  

**SET THE BUCKET AS PUBLIC**

Go into the bucket you just created.  
Click the `Permissions` tab.  
Scroll down and in the `Bucket Policy` area, click `Edit`. 


in the box, paste the code below

```
{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Sid":"PublicRead",
        "Effect":"Allow",
        "Principal": "*",
        "Action":["s3:GetObject"],
        "Resource":["REPLACEME_ARDAY_ENGINEERS_BUCKET_ARN/*"]
      }
    ]
  }

```
Replace the `REPLACEME_ARDAY_ENGINEERS_BUCKET_ARN` (being careful NOT to include the `/*`) with the bucket ARN, which you can see near to `Bucket ARN `
Click `Save Changes`  

**ENABLE STATIC HOSTING**
Next you need to enable static hosting on the S3 bucket so that it can be used as a front end website.  
Click on the `Properties Tab`  
Scroll down and locate `Static website hosting`  
Click `Edit`  
Select `Enable` 
Select `Host a static website`  
For both `Index Document` and `Error Document` enter `index.html` 
Click `Save Changes`  
Scroll down and locate `Static website hosting` again.  
Under `Bucket Website Endpoint` copy and note down the bucket endpoint URL. 

**DOWNLOAD AND EDIT THE FRONT END FILES**

make folder, name it as serverless_frontend then Download these files https://github.com/DevOps-cloudguru/arday-terraform/tree/serverless_app/serverless_app 
Inside the serverless_frontend folder are the front end files for the serverless website :-

- index.html .. the main index page
- main.css .. the stylesheet for the page
- cat.png .. an image of amazing cat !!
- serverless.js .. the JS code which runs in your browser. It responds when buttons are clicked, and passes and text from the boxes when it calls the API Gateway endpoint.  

Open the `serverless.js` in your favorite code/text editor.
Locate the placeholder `REPLACEME_API_GATEWAY_INVOKE_URL` . replace it with your API Gateway Invoke URL
at the end of this URL.. add `/ardayofengineers`
it should look something like this `https://somethingsomething.execute-api.us-east-1.amazonaws.com/prod/ardayofengineers` 
Save the file.  

**UPLOAD AND TEST**

Return to the S3 console
Click on the `Objects` Tab.  
Click `Upload`  
Drag the 4 files from the serverless_frontend folder onto this tab, including the serverless.js file you just edited.
**MAKE SURE ITS THE EDITED VERSION**

Click `Upload` and wait for it to complete.  
Click `Exit`  
Verify All 4 files are in the `Objects` area of the bucket.  


Open the `ArdayOfEngineers URL` you just noted down from S3.  
What you are seeing is a simple HTML web page created by the HTML file itself and the `main.css` stylesheet.
When you click buttons .. that calls the `.js` file which is the starting point for the serverless application

Ok to test the application
Enter an amount of time until the next call ...I suggest `120` seconds
Enter a message, i suggest `ARDAY COME to Class NOW`  
then enter the `ArdayOfEngineers Customer Address` in the email box, this is the email which you verified right at the start as the customer for this application.  

**before you do the next step and click the button on the application, if you want to see how the application works do the following**
open a new tab to the `Step functions console` https://us-east-2.console.aws.amazon.com/states/home?region=us-east-2#/statemachines  
Click on `ArdayOfEngineers`  
Click on the `Logging` tab, you will see no logs
CLick on the `Executions` tab, you will see no executions..

Move back to the web application tab (s3 bucket)  
then click on `Email Arday` Button to send an email.  

Got back to the Step functions console
make sure the `Executions` Tab is selected
click the `Refresh` Icon
Click the `execution`  
Watch the graphic .. see how the `Timer state` is highlighted
The step function is now executing and it has its own state ... its a serverless flow.
Keep waiting, and after 120 seconds the visual will update showing the flow through the state machine

- Timer .. waits 120 seconds
- `Email` invokes the lambda function to send an email
- `NextState` in then moved through, then finally `END`

Scroll to the top, click `ExeuctionInput` and you can see the information entered on the webpage.
This was send it, via the `JS` running in browser, to the API gateway, to the `arday_api_lambda` then through to the `statemachine`

Click `ArdayOfEngineers` at the top of the page  
Click on the `Logging` Tab  
Because the roles you created had `CWLogs` permissions the state machine is able to log to CWLogs
Review the logs and ensure you are happy with the flow. 

!! Success Screenshots

<img width="600" alt="Screenshot 2023-01-25 at 16 54 44" src="https://user-images.githubusercontent.com/66903895/214628500-a21ed81f-1084-4980-afd8-4e9768ed7136.png">



<em> Reference:<br>
Here's the refence: [acantril](https://github.com/acantril/learn-cantrill-io-labs/tree/master/aws-serverless-pet-cuddle-o-tron)
[^bignote]: [acantril's GitHub](https://github.com/acantril/learn-cantrill-io-labs/tree/master/aws-serverless-pet-cuddle-o-tron)
</em>
