#### Phase II

During the Phase II of this project, we have taken a major step towards streamlining our infrastructure deployment process by leveraging the power of Terraform. By automating the provisioning of pre-configured EC2 instances on both sites and MariaDB in the AWS cloud RDS, we have significantly reduced the manual effort required to set up and manage our infrastructure.

Terraform's declarative approach to infrastructure-as-code has enabled us to define our infrastructure requirements in a clear and concise manner, making it easier to manage and maintain our resources. With Terraform's robust ecosystem of plugins and modules, we have also been able to configure other critical components of our infrastructure, such as networking resources, security groups, and load balancers, across multiple regions.

before we go to DMS I have encountered an issues arisen while on this project, go back to onprem server and configure these settings on MariaDB:

`sudo nano /etc/mysql/mariadb.conf.d/50-server.cnf`
Change the value of the bind-address from 127.0.0.1 to 0.0.0.0 so that MariaDB server accepts connections on all host IPv4 interfaces.
`bind-address = 0.0.0.0`
Save and close the file when you are finished. Then, restart the MariaDB service to apply the changes:
`sudo systemctl restart mariadb`

If you encounter the "host is not allowed to connect to this host" error and need to grant access by copying the onprem server public IP and replication instance's private IPv4, the following command can help resolve the issue:
`sudo mysql -e "GRANT ALL ON wordpress_db.* TO 'wp_user'@'<IPv4-of-host-REPLACEME>' IDENTIFIED BY '$dbpassword'"`
For example:
`sudo mysql -e "GRANT ALL ON wordpress_db.* TO 'wp_user'@'53.23.140.184' IDENTIFIED BY 'dbpassword'"`
and
`sudo mysql -e "GRANT ALL ON wordpress_db.* TO 'wp_user'@'10.16.140.184' IDENTIFIED BY 'dbpassword'"`

thanks to [Webdock](https://webdock.io/en/docs/how-guides/database-guides/how-enable-remote-access-your-mariadbmysql-database) & [techmint](https://www.tecmint.com/fix-error-1130-hy000-host-not-allowed-to-connect-mysql/)

#### DMS steps  

CREATE THE DMS SUBNET GROUP

https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#subnetGroup 
Click `Create Subnet Group`  
For Name and Description use `arday-dms-sng`
for `VPC` choose `cloudVPC`  
for `Add Subnets` choose `db-sn-1`, `db-sn-2` and `db-sn-3`  
Click `Create subnet group` 

CREATE THE DMS REPLICATION INSTANCE

Move to the DMS Console https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#replicationInstances
Click `create Replication Instance`  
for name enter `arday-mig`
use the `Description` for `arday migration instance` 
for `Instance Class` choose `dms.t3.micro`  
For `MultiAZ` make sure it's set to `dev or test workload (single AZ)`  
for `VPC` choose `clouodVPC`  
Ensure `arday-dms-sng` is selected in `Replication subnet group`  
and for `Pubicly Accessible` uncheck the box  
Expand `Advanced settings and network configuration`  
For `VPC security group(s)` choose `dev-db-sg`  
Click `Create Replication Instance`


CREATE THE DMS SOURCE ENDPOINT

Move to https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#endpointList 
Click `Create Endpoint`  
For `Endpoint type` choose `Source Endpoint` and make sure that `Select RDS DB Instance` is UNCHECKED  
Under `Endpoint configuration` set `Endpoint identifier` to be `Onprem-source`  
Under `Source Engine` set `mariadb`  
Under `Access to endpoint database` choose `Provide access information manually`  
Under `Server name` use the privateIPv4 address of `onprem-server-1` (get it from EC2 console)  
For port `3306`  
For username `arday_user`  
for password user the DBPassword you noted down in bootstrap  
click `create endpoint`  

CREATE THE DMS DESTINATION ENDPOINT (mariaDB RDS)  

Move to https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#endpointList 
Click `Create Endpoint`  
For `Endpoint type` choose `Target Endpoint`  
Check `Select RDS DB Instance`  
Select `arday-db-id` in the dropdown  
It will prepopulate the boxes 
Set `Endpoint identifier` to be `cloud-source` 
Under `Access to endpoint database` choose `Provide access information manually`  
For `Password` enter the DBPassword you noted down in bootstrap  
Scroll down and click `Create Endpoint`  

TEST THE ENDPOINTS

**make sure the replication instance is ready**
Verify by going to `Replication Instances` and make sure the status is `Available`  
Go back to `Endspoints`  

Select the `Onprem-source` endpoint, click `Actions` and then `Test Connections`  
Click `Run Test` and make sure after a few minutes the status moves to `successful`  
Go back to `Endpoints`  
Select the `cloud-source` endpoint, click `Actions` and then `Test Connections`  
Click `Run Test` and make sure after a few minutes the status moves to `successful`  

If both of these are successful you can continue to the next step, if there's issues grant permissions by following the steps in beginning of phase II.  

#### Migrate
Move to migration tasks https://us-west-1.console.aws.amazon.com/dms/v2/home?region=us-west-1#tasks 
Click `Create task`  
for `Task identifier` enter `arday-onprem-to-cloud-task`
for `Replication instance` pick the replication instance you just created  
for `Source database endpoint` pick `Onprem-source`  
for `Target database endpoint` pick `cloud-source`  
for `Migration type` pick `migrate existing data` **you could pick and replicate changes here if this were a high volume production DB**  
for `Table mappings` pick `Wizard`  
Click `Add new selection rule`  
in `Schema` box select `Enter a Schema`  
in `Schema Name` type `arday-db`  
Scroll down and click `Create Task`  

This starts the replication task and does a full load from `onprem-server-db` to the RDS Instance.  
It will create the task  
then start the task  
then it will be in the `Running` State until it moves into `Load complete`  


At this point the data has been migrated into the RDS instance  


Move to the EC2 running instances console https://console.aws.amazon.com/ec2/v2/home?region=us-east-1#Instances:  
Select the `cloud_server-1` instance  
copy down its `public IPv4 DNS` into your clipboard and open it in a new tab  
if working, this Web Instance (aws) is now loading using the on-premises database.

> this project will be re-deployed to different architecture
for now it will be on Version II

＼(^ o ^)／
