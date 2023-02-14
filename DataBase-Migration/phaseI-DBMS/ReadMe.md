### Phase I

Use the Terraform Code in This Repository to Provision Base Infrastructure which consists of: 2 VPC's one for onprem and one for cloud AWS, EC2 ...

Create RDS instance on AWS side

Launch EC2 instance on AWS side, install WordPress requirements and start migrating

follow this link to step-by-tep guide for mariaDB installation to your ubuntu instance

[Digital ocean MariaDB](https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-20-04)

and follow this link for installing WordPress to ubuntu EC2 instance

[Digital Ocean WordPress](https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-on-ubuntu-20-04-with-a-lamp-stack)
& [for Ubuntu 18.04](https://www.digitalocean.com/community/tutorials/install-wordpress-on-ubuntu)

Once Deployment of terraform is successfully finished then follow these steps

#### - CREATE THE RDS INSTANCE

Move to the RDS Console https://us-west-1.console.aws.amazon.com/rds/home?region=us-west-1  
Click `Subnet Groups`  
Click `Create DB Subnet Group`  
For `Name` call it `ArdaySG`
enter the same for description or `Arday subnet group`
in the `VPC` dropdown, choose `cloudVPC`  
Under availability zones, choose `us-west-1a` and `us-west-1b`  
for subnets check the box next to `10.16.144.0/20` which is privateA and `10.16.128.0/20` which is db-sn-1 & db-sn-2  
Scroll down and click `Create`  
Click on `Databases`  
Click `create Database`  
Choose `Standard Create`  
Choose `MariaDB`
Choose `Free Tier` for `Templates`  

You will be using the same database names and credentials to keep things simple for this project, but note that in production this could be different.

for `DB instance identifier` enter `arday-db`  
for `Master username` choose `wp_user`  
for `Masterpassword` enter the DBPassword from bootstrap
enter that same password in the `Confirm password` box  
Leave defaults and Scroll down to `Connectivity`  
for `Virtual private cloud (VPC)` choose `cloudVPC`  
make sure `Subnet Groups` is set to `ArdaySG`  
for `public access` choose `No`  
for `VPC security groups` select `Choose Existing` and choose  `db-sg` (from terraform deployment)  
remove the `Default` security group by clicking the `X`    
Scroll down and expand `Additional configuration`  
Under `Initial database name` enter `wordpress_db`  
Scroll down and click `Create Database`  

This will take some time... and keep this for the next phase of this project 

and you can continue to create `new EC2 instance` manually until the database is in a ready state.

##### * Create EC2 instance

Move to the EC2 Console https://us-west-1.console.aws.amazon.com/ec2/home?region=us-west-1#LaunchInstances:  
Click `Instances`  
Click `Launch Instances`  
Enter `cloud_server_1` for the Name of the instance.  
Click `ubuntu` and ensure `Ubuntu Server 22.04 LTS (HVM) ...... SSD Volume Type` is selected.  
Ensuring the architecture is set to `64-bit (x86)` below.    
Choose the `Free Tier eligible` instance (should be t2.micro or t3.micro)  
Scroll down and choose `Proceed without key pair (not recommended)` in the dropdown  
Next to `Network Settings` click `Edit`  
For `VPC` pick `cloudVPC`  
For `Subnet` pick `pub-sn-1`  
Select `Select an existing security group`  
Choose `***-dev-sg-***` (*** might change for next terraform proof writing)  
Scroll down past Storage and expand `Advanced Details` (don't confuse this with `Advanced Network Configuration` in the current area)  
for `IAM Instance Profile` pick `***-ec2_profile` (*** name will be fixed)  
Click `Launch Instance`  
Click `View All Instances`  

Wait for the `cloud_server_1` instance to be in a `Running` state with `2/2 checks` before continuing.

##### INSTALL WORDPRESS Requirements

Select the `cloud_server_1` instance, right click, `Connect`  
Select `EC2 instance connect` and click `Connect`  
When connected type `check` you have a privileged bash shell
then update the instance with a `sudo apt -y update` and wait for it to complete.  
Then install the apache web server with `sudo apt -y install appache2 mariadb-server mariadb-client`  (the mariadb part is for the mysql tools)
Then install php with `sudo apt install -y php php-mysql`  
then make sure apache is running and set to run at startup with 

```
sudo systemctl enable mariadb.service
sudo systemctl start apache2.service

### --- create and configure MariaDB for the WordPress
sudo mysql -e "CREATE DATABASE wordpress_db"
sudo mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'somalistudentsplu5'"
sudo mysql -e "GRANT ALL ON wordpress_db.* TO 'wp_user'@'localhost' IDENTIFIED BY 'somalistudentsplu5'"
sudo mysql -e "FLUSH PRIVILEGES"
```

You now have a running apache web server with the ability to connect to the wordpress database (currently running onpremises)

#### - MIGRATE WORDPRESS Content over

You're going to edit the SSH config on this machine to allow password authentication on a temporary basis.  
You will use this to copy the wordpress data across to the cloud_Server-1 machine from the on-premises server Machine  

run a `sudo nano /etc/ssh/sshd_config`  
locate `PasswordAuthentication no` and change to `PasswordAuthentication yes` , then `ctrl+o` to save and `ctrl+x` to exit.  
then set a password on the ec2-user user  
run a `sudo passwd ubuntu` and enter the `DBPassword` you noted down at bootstrap shebang process.  
**this is only temporary.. we're using the same password throughout the project to make things easier and less prone to mistakes**

restart SSHD to make those changes with `service sshd restart`  or `systemctl restart sshd`
> note: use `sudo` for both commands or authenticate `ubuntu` user using the password you just setup

Return back to the EC2 console https://us-west-1.console.aws.amazon.com/ec2/home?region=us-west-1#Instances: 
with the `cloud_server_1` instance selected, note down its `Private IPV4 Address` you will need this in a moment.  

Select the `onprem_server_1` instance, right click, `Connect`  
Select `EC2 instance connect` and click `Connect`  

move to the webroot folder by typing `cd /var/www/`  

run a `scp -rp html ubuntu@privateIPofawsCatWeb:/home/ubuntu` and answer `yes` to the authenticity warning.  
this will copy the wordpress local files from `onprem_server_1` (on-premises) to `cloud_server_1` (aws)

**now move back to the `cloud_server_1` server, if you dont have it open still, reconnect as per below**

Select the `cloud_server_1` instance, right click, `Connect`  
Select `EC2 instance connect` and click `Connect`  
When connected a privilege bash shell or use `sudo`

move to the `ubuntu` home folder by doing a `cd /home/ubuntu`  
then do an `ls -la` and you should see the html folder you just copied.  
`cd html`  
check `/var/www/html` is created and empty, or use in case `sudo rm /var/www/html/*`
next copy all of these files into the web-root of `cloud_serve-1` by doing a `sudo cp * -R /var/www/html/`

#### - Fix Up Permissions & verify `cloud_server-1` works

run the following commands to enforce the correct permissions on the files you've just copied across

```
##--- www-data is webserver user on ubuntu (apache, nginx...)
sudo usermod -a -G www-data ubuntu
sudo chown -R ubuntu:www-data /var/www
sudo chmod 2775 /var/www
sudo find /var/www -type d -exec chmod 2775 {} \;
sudo find /var/www -type f -exec chmod 0664 {} \;
sudo systemctl restart apache2
sudo chown -R www-data:www-data  /var/www/html/wp-content/uploads
```

Move to the EC2 running instances console https://us-west-1.console.aws.amazon.com/ec2/home?region=us-west-1#Instances:
Select the `cloud_server-1` instance  
copy down its `public IPv4 DNS` into your clipboard and open it in a new tab  
if working, this Web Instance (aws) is now loading using the on-premises database.

--

> this project will be re-deployed to different architecture <br>
for now this is the end of Phase I


---
<em>reference</em>:

* [1] : [acantrill](https://github.com/acantril/learn-cantrill-io-labs/tree/master/aws-dms-database-migration)
* [2] : [MTC Terraform](https://github.com/morethancertified/mtc-terraform)
