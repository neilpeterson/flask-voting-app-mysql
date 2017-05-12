#!/bin/bash

# Configuration values
user=$1
password=$2

Echo "----------: Installing MySQL : ----------"
sudo apt-get update
echo "mysql-server mysql-server/root_password password $password" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $password" | sudo debconf-set-selections
sudo apt-get -y install mysql-server

Echo "----------: Creating azurevote database : ----------"
mysqladmin -u root -p$password create azurevote
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf

Echo "----------: Creating user and application tables : ----------"
mysql -u root -p$password -Bse "CREATE USER $user@'localhost' IDENTIFIED BY '$password';"
mysql -u root -p$password -Bse "GRANT ALL PRIVILEGES ON *.* TO $user@'localhost' WITH GRANT OPTION;"
mysql -u root -p$password -Bse "CREATE USER $user@'%' IDENTIFIED BY '$password';"
mysql -u root -p$password -Bse "GRANT ALL PRIVILEGES ON *.* TO $user@'%' WITH GRANT OPTION;"
mysql -u root -p$password -Bse "FLUSH PRIVILEGES;"
mysql -u root -p$password -Bse 'CREATE TABLE `azurevote`.`azurevote` (`voteid` INT NOT NULL AUTO_INCREMENT,`votevalue` VARCHAR(45) NULL,PRIMARY KEY (`voteid`));'

Echo "----------: Restart MySQL : ----------"
sudo service mysql restart

Echo "----------: Script complete : ----------"