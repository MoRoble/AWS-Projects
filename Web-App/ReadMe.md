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
Set Tier to `Standard`
Set Type to `String`
Set Data type to `text`
Set Value to `hdnwordpressuser` 
Click `Create parameter`

Create Parameter - DBName (the name of the wordpress database)

Click `Create Parameter` Set Name to `/HDN/Wordpress/DBName` Set Description to `Wordpress Database Name`
follow same way
Set Value to `hdnwordpressdb`

Create Parameter - DBEndpoint (the endpoint for the wordpress DB .. )

follow same way
Set Value to `localhost`

Create Parameter - DBPassword (the password for the DBUser)

Click `Create Parameter` Set Name to `/HDN/Wordpress/DBPassword` Set Description to `Wordpress DB Password`
Set Tier to `Standard`
Set Type to `SecureString`
Set `KMS Key Source` to `My Current Account`
Leave `KMS Key ID` as default Set `Value` to `h0d4nF1L35` Click `Create parameter`

Create Parameter - DBRootPassword (the password for the database root user, used for self-managed admin)

Click Create Parameter Set Name to /HDN/Wordpress/DBRootPassword Set Description to Wordpress DBRoot Password
Set Tier to `Standard`
Set Type to `SecureString`
Set `KMS Key Source` to `My Current Account`
Leave `KMS Key ID` as default Set `Value` to `h0d4nF1L35` Click `Create parameter`

##### Create RDS Instance
In this stage, you are going to provision an RDS instance using the subnet group to control placement within the VPC. Normally you would use multi-az for production, to keep costs low, for now you should use a single AZ as per the instructions below.

Click `Databases`
Click `Create Database
Click `Standard Create`
Click `MySql` under `Engine options`
Under `Version` select `MySQL 5.7.31` (best aurora compatibility for snapshot migrations)

Scroll down and select `Free Tier` under templates this ensures there will be no costs for the database but it will be single AZ only

under `Db instance identifier` enter `hdnWordPress` under `Master Username` enter enter the value from here https://console.aws.amazon.com/systems-manager/parameters/HDN/Wordpress/DBUser/description?region=us-east-1&tab=Table 
under `Master Password` and `Confirm Password` enter the value from here and confirm https://console.aws.amazon.com/systems-manager/parameters/HDN/Wordpress/DBPassword/description?region=us-east-1&tab=Table

Under `DB instance class`, then `Burstable classes (includes t classes)` make sure `db.t2.micro` is selected
Scroll down, under `Connectivity`, Virtual private cloud `(VPC)` select `HDNVPC` 
Subnet group `wordpressrdssubnetgroup` automatically populated
Make sure `Publicly accessible` is set to `No`
Under `Existing VPC security groups` add `HDNVPC-SGDatabase` and remove `Default`
Under `Availability Zone` set `us-east-1a`
Under `Database authentication` select `Password authentication`
Scroll down and expand `Additional configuration`
in the `Initial database name` box enter the value from here https://console.aws.amazon.com/systems-manager/parameters/HDN/Wordpress/DBName/description?region=us-`east-1&tab=Table
Scroll to the bottom and click `create Database`

** this will take anywhere up to 30 minutes to create ... it will need to be fully ready before you move to the next step - tea time !!!! **


##### Create EFS File System
EFS file system designed to store the wordpress locally stored media. This area stores any media for posts uploaded when creating the post as well as theme data. By storing this on a shared file system it means that the data can be used across all instances in a consistent way, and it lives on past the lifetime of the instance.

Move to the EFS Console https://console.aws.amazon.com/efs/home?region=us-east-1#/get-started
Click on `Create file System`
We're going to step through the full configuration options, so click on `Customize`
For Name type `HDN-WORDPRESS-CONTENT`
This is critical data so .. `ensure Enable Automatic Backups` is enabled.
for `LifeCycle management` leave as the default of `30 days since last access`
You have two performance modes to pick, choose `General Purpose` as MAX I/O is for very specific high performance scenarios.
for `Throughput mode` pick `bursting` which links performance to how much space you consume. The more consumed, the higher performance. The other option Provisioned allows for performance to be specified independent of consumption.
Untick `Enable encryption of data at rest` .. in production you would leave this on, but for now we focus on architecture it simplifies the implementation.
Click `Next`

Network Settings

In this part you will be configuring the EFS `Mount Targets` which are the network interfaces in the VPC which your instances will connect with.

In the Virtual Private Cloud `(VPC)` dropdown select `HDNVPC`
You should see 3 rows.
Make sure `us-east-1a`, `us-east-1b` & `us-east-1c` are selected in each row.
In `us-east-1a` row, select `sn-App-A` in the subnet ID drop-down, and in the security groups drop-down select `HDNVPC-SGEFS` & remove the default security group
In `us-east-1b` row, select `sn-App-B` in the subnet ID dropdown, and in the security groups dropdown select `HDNVPC-SGEFS` & remove the default security group
In `us-east-1c` row, select `sn-App-C` in the subnet ID dropdown, and in the security groups dropdown select `HDNVPC-SGEFS` & remove the default security group

Click `next`
Leave all these options as default and click `next`
We wont be setting a file system policy so click `Create`

The file system will start in the `Creating` State and then move to `Available` once it does..
Click on the file system to enter it and click `Network` tab
Scroll down and all the mount points will show as `creating` keep hitting refresh and wait for all 3 to show as available before moving on.

Note down the `fs-XXXXXXXX` file system ID once visible at the top of this screen, you will need it in the next step.

Add an fsid to parameter store

Now that the file system has been created, you need to add another parameter store value for the file system ID so that the automatically built instance(s) can load this safely.

Move to the Systems Manager console https://console.aws.amazon.com/systems-manager/home?region=us-east-1#
Click on `Parameter Store` on the left menu
Click `Create Parameter`
Under Name enter `/HDN/Wordpress/EFSFSID` Under `Description` enter `File System ID for Wordpress Content (wp-content)`
for `Tier` set `Standard`
For `Type` set `String`
for `Data Type` set `text`
for `Value` set the file system ID `fs-XXXXXXX` which you just noted down (use your own file system ID)
Click `Create Parameter`

##### Build Launch Template

Open the EC2 console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:sort=desc:tag:Name
Click `Launch Templates` under Instances on the left menu
Click `Create Launch Template`
Under `Launch Template Name` enter `Wordpress`
Under `Template version description` enter `Server DB and App`
Check the Provide guidance to help me set up a template that I can use with EC2 Auto Scaling box

Under `Amazon machine image (AMI)` - required click and locate `Amazon Linux 2 AMI (HVM)`, SSD Volume TYpe, Architecture: 64-bit (x86)From Quick Start
Under `Instance` Type select `t2.micro` (or whichever is listed as free tier eligible)
Under `Key pair` (login) select `Don't include in launch template`
Under `networking Settings` Skip Subnet make sure Under Security Groups select `HDNVPC-SGWordpress-..`
Scroll to the bottom, Expand `Advanced Details` Under IAM instance profile select `HDNVPC-WordpressInstanceProfile`
Under Credit specification select `Unlimited`

Add User-Data
```
#!/bin/bash -xe

DBPassword=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBPassword --with-decryption --query Parameters[0].Value)
DBPassword=`echo $DBPassword | sed -e 's/^"//' -e 's/"$//'`

DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBRootPassword --with-decryption --query Parameters[0].Value)
DBRootPassword=`echo $DBRootPassword | sed -e 's/^"//' -e 's/"$//'`

DBUser=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBUser --query Parameters[0].Value)
DBUser=`echo $DBUser | sed -e 's/^"//' -e 's/"$//'`

DBName=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBName --query Parameters[0].Value)
DBName=`echo $DBName | sed -e 's/^"//' -e 's/"$//'`

DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /HDN/Wordpress/DBEndpoint --query Parameters[0].Value)
DBEndpoint=`echo $DBEndpoint | sed -e 's/^"//' -e 's/"$//'`


yum -y update
yum -y upgrade

yum install -y mariadb-server httpd wget
amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2
amazon-linux-extras install epel -y
yum install stress -y

systemctl enable httpd

systemctl start httpd


wget http://wordpress.org/latest.tar.gz -P /var/www/html
cd /var/www/html
tar -zxvf latest.tar.gz
cp -rvf wordpress/* .
rm -R wordpress
rm latest.tar.gz

sudo cp ./wp-config-sample.php ./wp-config.php
sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php

usermod -a -G apache ec2-user   
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;


```

#### Create load balancer

On this stage create Load Balancer

Move to the EC2 console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Home:
Click `Load Balancers` under Load Balancing
Click `Create Load Balancer`
Click `Create` under `Application Load Balancer`
Under name enter `HDNWORDPRESSALB`
Ensure `internet-facing` is selected
ensure ipv4 selected for IP Address type

On `Network mapping`, under Mappings for VPC ensure `HDNVPC` is selected
Check boxes next to `us-east-1a`, `us-east-1b` and `us-east-1c`
Select `sn-pub-A`, `sn-pub-B` and `sn-pub-C` for each.

Under `Security Groups`
Check Select an `existing security group` and select `HDNVPC-SGLoadBalancer` it will have some random at the end and thats ok.
Unselect `'default VPC'`

Under Listeners `HTTP` and `80` should be selected for Load Balancer Protocol and Load Balancer Port

Click `Next`: Configure Routing

for `Target Group` choose `New Target Group`
for `Name` choose `HDNWORDPRESSALBTG`
for `Target` Type `choose Instance`
For `Protocol` choose `HTTP`
For `Port` choose `80`
Under `Health checks for Protocol` choose `HTTP` and for `Path` choose `/`
Click `Next`: Register Targets
We won't register any right now, click Next: `Review`
Click `Create`

Click on the `HDNWORDPRESSALB` link
Scroll down and copy the `DNS Name` into your clipboard

Now Create another `parameter store`

Set Name as `/HDN/Wordpress/ALBDNSNAME` Under Description enter DNS Name of the Application Load Balancer for wordpress
set Standardset Stringsettext
for Value set the DNS name of the load balance you copied into your clipboard Click `Create Parameter`

