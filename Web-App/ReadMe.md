# Hodan School Web-Application
#### Skeleton Architecture

Following our project scenario ‘Hodan School’ we are going to implement highly available 3 tier architecture implemented on AWS. We are going to evolve web application WordPress, compute options, load balancing and database services until it's a scalable and resilient architecture.

In their 3 tier architecture applications are organized into three logical tiers: the presentation layer, the business logic layer and the data storage layer. Our web application will be used in a client-server application that has frontend, the backend and the database. The prime drivers for three-tier architecture are:

* Decoupling
* Independent scalability
* Separately developed, managed and maintained by different teams

Amazon Web Service (AWS) is a cloud platform that provides different cloud computing services. We shall be using AWS services to design and build a three-tier cloud infrastructure such as EC2, Auto Scalling Group (ASG), VPC and Elastic Load Balancer (ELB) aming to be highly available and fault tolerant.

Web-App template

![Hodan School](https://github.com/MoRoble/AWS-Projects/blob/5c4db3364639e00d867ad703b06bd6147d60d229/Web-App/Web-App.jpeg)

This project consists of different stages, each implementing additional components of the architecture.

Login to an `AWS account` using a user with admin privileges and ensure your region is set to `us-east-1` `N. Virginia`

Use One-Click Deployment to auto configure the VPC which WordPress will run from

Wait for the STACK to move into the `CREATE_COMPLETE` state before continuing.

Or get this yaml file and upload on your CloudFormation Stack.

##### Automatic Build
I will be using bootstrap to provision MariaDB, WordPress, install EFS, mount EFS file system to WordPress and populate values from AWS Parameter Store.

Create SSM Parameter Store values for WordPress
In this stage we will start storing configuration information within the SSM parameter store which scales much better than attempting to script them.
Select AWS System Manager from services then Click on Parameter Store under Application Management on the menu on the left

Create Parameter - DBUser (the login for the specific wordpress DB)
Click `Create Parameter` Set Name to `/HDN/Wordpress/DBUser` Set Description to `Wordpress Database User`
Set Tier to Standard
Set Type to String
Set Data type to text
Set Value to hdnwordpressuser
Click Create parameter

Create Parameter - DBName (the name of the wordpress database)
Click Create Parameter Set Name to /HDN/Wordpress/DBName Set Description to Wordpress Database Name
Set Tier to Standard
Set Type to String
Set Data type to text
Set Value to hdnwordpressdb
Click Create parameter

Create Parameter - DBEndpoint (the endpoint for the wordpress DB .. )
Click Create Parameter Set Name to /HDN/Wordpress/DBEndpoint Set Description to Wordpress Endpoint Name
Set Tier to Standard
Set Type to String
Set Data type to text
Set Value to localhost
Click Create parameter

Create Parameter - DBPassword (the password for the DBUser)
Click Create Parameter Set Name to /HDN/Wordpress/DBPassword Set Description to Wordpress DB Password
Set Tier to Standard
Set Type to SecureString
Set KMS Key Source to My Current Account
Leave KMS Key ID as default Set Value to h0d4nF1L35 Click Create parameter

Create Parameter - DBRootPassword (the password for the database root user, used for self-managed admin)
Click Create Parameter Set Name to /HDN/Wordpress/DBRootPassword Set Description to Wordpress DBRoot Password
Set Tier to Standard
Set Type to SecureString
Set KMS Key Source to My Current Account
Leave KMS Key ID as default Set Value to h0d4nF1L35 Click Create parameter

Then create Load Balancer
