#!/bin/bash -xe
# System Updates
sudo apt -y update
sudo apt -y upgrade


# STEP 4 - Install Wordpress
cd /var/www/html
wget https://wordpress.org/latest.tar.gz  #-P /var/www/html
sudo chown -R ubuntu:www-data /var/www/html
sudo tar -xvf latest.tar.gz
# sudo cp -R wordpress /var/www/html/
sudo rm -rf index*
sudo cp -rvf wordpress/* .
sudo rm -R wordpress
sudo rm latest.tar.gz

# Step 4a - permissions   
sudo usermod -a -G www-data ubuntu
sudo chown -R ubuntu:www-data /var/www/html
sudo chmod -R 2755 /var/www/html
sudo mkdir /var/www/html/wp-content/uploads
sudo chown -R www-data:www-data /var/www/html/wp-content/uploads/
sudo find /var/www/html/ -type d -exec chmod 2750 {} \;
sudo find /var/www/html/ -type f -exec chmod 0664 {} \;

# <<configs
# the configuration of WordPress on the cloud will be carried out manually
# this will follow the use of secure copy via VPC peering connection
# configs

# STEP 6 COWSAY
cd
sudo apt install cowsay -y

cowsay "Ubuntu On-cloud Server --- Arday of Engineers"

<<c
# Configure Wordpress
cd /var/www/html
cp ./wp-config-sample.php ./wp-config.php
sed -i "s/'localhost'/'${private-ip4}'/g" wp-config.php
sed -i "s/'database_name_here'/'${dbname}'/g" wp-config.php
sed -i "s/'username_here'/'${dbuser}'/g" wp-config.php
sed -i "s/'password_here'/'${dbpassword}'/g" wp-config.php

/home/ubuntu/update_wp_ip.sh
c
