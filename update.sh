#!/bin/bash

set -e

##############################################################################
#                   Version 2, December 2004
# 
# Copyright (C) 2004 adrea/dxqt
#
# Everyone is permitted to copy and distribute verbatim or modified
# copies of this license document, and changing it is allowed as long
# as the name is changed.
# 
#           DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#  TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
# 
# 0. You just DO WHAT THE FUCK YOU WANT TO.
##############################################################################

echo "Welcome to this shitty install script WOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO!!!!11!!!1"

############# Variables #############

# Default MySQL Credentials
MYSQL_DB="namelessmc"
MYSQL_USER="nameless"

############# MySQL Password #############

echo -n " Please enter your strongly preferred MySQL password:"
read MYSQL_PASSWORD

echo ""
echo "Before starting this installation script, you should have set the DNS record. (I'm so bad at english)"

echo "Starting the installation process..."

############# Dependencies Installation #############

# PHP 7.4

sudo apt -y install software-properties-common
sudo add-apt-repository ppa:ondrej/php
sudo apt-get update

# Web Server and Dependencies

sudo apt-get install curl apache2 zip unzip -y
sudo apt-get install php7.4 php7.4-curl php7.4-exif php7.4-gd php7.4-mbstring php7.4-mysql php7.4-pdo php7.4-xml -y

# MariaDB Setup

sudo apt install mariadb-server

echo "Before proceeding, complete these secure MySQL installation steps."
sudo mysql_secure_installation

############# NamelessMC Installation #############

mkdir -p /var/www/html/
cd /var/www/html/

curl -o NamelessMC.zip https://github.com/NamelessMC/Nameless/archive/refs/tags/v2.0.0-pr12.zip
unzip NamelessMC.zip

cd Nameless-2.0.0-pr12

# Move all files to the root folder.

mv *.* /var/www/html/
mv * /var/www/html/

cd /etc/apache2
a2enmod rewrite

systemctl restart apache2

# Some stuffs that are required for this shit to run.
sed "$(grep -n "AllowOverride None" /etc/apache2/apache2.conf |cut -f1 -d:)s/.*/AllowOverride All/" /etc/apache2/apache2.conf > /etc/apache2/apache2.conf
sed "$(grep -n "/bind-address 127.0.0.1/" /etc/mysql/mysql.conf.d/mysqld.cnf |cut -f1 -d:)s/.*/bind-address 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf > /etc/mysql/mysql.conf.d/mysqld.cnf

# Creating the MySQL database.

echo "Creating MySQL user...";
mysql -u root -p -e "CREATE USER '${MYSQL_USER}'@'localhost' IDENTIFIED BY '${MYSQL_PASSWORD}';"

echo "Creating MySQL database...";
mysql -u root -p -e "CREATE DATABASE ${MYSQL_DB};"

echo "Granting database privileges...";
mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'localhost' WITH GRANT OPTION;"

echo "Flushing privileges..."
mysql -u root -p -e "FLUSH PRIVILEGES;"

echo "MySQL database created & configured!"

# Uhhhh stuffs
chown www-data:www-data /var/www/html/ -R
rm -rf /var/www/html/index.html/
systemctl restart apache2

echo "Finished! Go to your website and configure everything as you want it to be! (again, totally not english skills issue)"

