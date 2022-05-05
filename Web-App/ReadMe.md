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

Login to an AWS account using a user with admin privileges and ensure your region is set to `us-east-1` `N. Virginia`

Use One-Click Deployment to auto configure the VPC which WordPress will run from

Wait for the STACK to move into the 'CREATE_COMPLETE' state before continuing.

Or get this yaml file and upload on your CloudFormation Stack.

##### Automatic Build
I will be using bootstrap to provision MariaDB, WordPress, install EFS, mount EFS file system to WordPress and populate values from AWS Parameter Store.

Then create Load Balancer
