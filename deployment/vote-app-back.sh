#!/bin/bash

# Configuration values
password=Password12

sudo apt-get update
echo "mysql-server mysql-server/root_password password $password" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $password" | sudo debconf-set-selections
sudo apt-get -y install mysql-server
mysqladmin -u root -p$password create azurevote
sudo sed -i 's/bind-address/#bind-address/g' /etc/mysql/mysql.conf.d/mysqld.cnf
mysql -u root -p$password -Bse "CREATE USER 'dbuser'@'localhost' IDENTIFIED BY '$password';"
mysql -u root -p$password -Bse "GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'localhost' WITH GRANT OPTION;"
mysql -u root -p$password -Bse "CREATE USER 'dbuser'@'%' IDENTIFIED BY '$password';"
mysql -u root -p$password -Bse "GRANT ALL PRIVILEGES ON *.* TO 'dbuser'@'%' WITH GRANT OPTION;"
mysql -u root -p$password -Bse "FLUSH PRIVILEGES;"
mysql -u root -p$password -Bse 'CREATE TABLE `azurevote`.`azurevote` (`voteid` INT NOT NULL AUTO_INCREMENT,`votevalue` VARCHAR(45) NULL,PRIMARY KEY (`voteid`));'
sudo service mysql restart