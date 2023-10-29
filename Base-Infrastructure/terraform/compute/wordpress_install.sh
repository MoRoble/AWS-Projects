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
sudo mysql -e "CREATE DATABASE arday_db"
sudo mysql -e "CREATE USER 'arday_user'@'localhost' IDENTIFIED BY 'p3rsonalPlu5'"
sudo mysql -e "GRANT ALL ON arday_db.* TO 'arday_user'@'localhost' IDENTIFIED BY 'p3rsonalPlu5'"
sudo mysql -e "FLUSH PRIVILEGES"

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

# STEP 5 - Configure Wordpress
sudo cp ./wp-config-sample.php ./wp-config.php
sudo sed -i "s/'database_name_here'/'arday_db'/g" wp-config.php
sudo sed -i "s/'username_here'/'arday_user'/g" wp-config.php
sudo sed -i "s/'password_here'/'p3rsonalPlu5'/g" wp-config.php
sudo chown -R ubuntu:www-data wp-config.php

###--fix-up permissions 
# sudo chown -R www-data:www-data /var/www/html/wp-content/uploads/
# sudo chown -R ubuntu:www-data /var/www/html/
# cd /var/www/html

# STEP 6 COWSAY
cd
sudo apt install cowsay -y
sudo chown -R ubuntu:ubuntu /etc/default
sudo echo "#!/bin/sh" > /etc/default/motd-news
sudo echo 'cowsay "Ubuntu Linux 2 AMI - ArdayOfEngineers"' >> /etc/default/motd-news
sudo chmod 755 /etc/update-motd.d/motd-news
cowsay "Ubuntu On-prem Server --- Arday of Engineers"
sudo rm /etc/update-motd.d/30-banner
sudo update-motd

<<comment
block lines of comment
comment
