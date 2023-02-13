#!/bin/bash -xe
# System Updates
sudo apt -y update
sudo apt -y upgrade
# STEP 2 - Install system software - LAMP stack - PHP as it is pre-requist for WP - including Web and DB
sudo apt install apache2 -y
sudo apt install mariadb-server mariadb-client -y
sudo apt install php php-mysql -y 
sudo systemctl enable mariadb.service
sudo systemctl start apache2.service

# STEP 3 - Create Mariadb Database and set Root Password
sudo mysql -e "CREATE DATABASE wordpress_db"
sudo mysql -e "CREATE USER 'wp_user'@'localhost' IDENTIFIED BY 'somalistudentsplu5'"
sudo mysql -e "GRANT ALL ON wordpress_db.* TO 'wp_user'@'localhost' IDENTIFIED BY 'somalistudentsplu5'"
sudo mysql -e "FLUSH PRIVILEGES"

# STEP 6 COWSAY
cd
sudo apt install cowsay
cowsay "Ubuntu On-prem Server --- Arday of Engineers"

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
