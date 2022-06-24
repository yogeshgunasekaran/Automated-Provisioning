#!/bin/bash

# Variables
DB_PASSWORD='admin123'

# Installing MySQL
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y


# Starting & Enabling Mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
git clone -b <branch-name> <repository-link>
# Restore the dump file for the application
# Since it is a fresh installation of MariaDB server, To set MySQL root password through mysqladmin utility
sudo mysqladmin -u root password "$DB_PASSWORD"
# Update password for the root user
sudo mysql -u root -p"$DB_PASSWORD" -e "UPDATE mysql.user SET Password=PASSWORD('$DB_PASSWORD') WHERE User='root'"
# Remove all access from remote hosts for the root user. Root should only be allowed to connect from localhost
sudo mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
# Remove the anonymous user account in MariaDB so that no-one can log into MariaDB without having a user account created for them.
sudo mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.user WHERE User=''"
# Remove default test database and access to it
sudo mysql -u root -p"$DB_PASSWORD" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
# Flush privileges in order to reload the grant tables
sudo mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES"
# Create a database named accounts
sudo mysql -u root -p"$DB_PASSWORD" -e "create database accounts"
# Allow full control over the accounts database for the user admin with password for admin as admin123
sudo mysql -u root -p"$DB_PASSWORD" -e "grant all privileges on accounts.* TO 'admin'@'localhost' identified by 'admin123'"
# Allow user admin to access accounts database remotely from any hosts
sudo mysql -u root -p"$DB_PASSWORD" -e "grant all privileges on accounts.* TO 'admin'@'%' identified by 'admin123'"
# Importing an SQL file that has been cloned to the newly created accounts database
sudo mysql -u root -p"$DB_PASSWORD" accounts < /tmp/project-name/src/main/resources/db_backup.sql
# Flush privileges in order to reload the grant tables
sudo mysql -u root -p"$DB_PASSWORD" -e "FLUSH PRIVILEGES"

# Restart mariadb-server
sudo systemctl restart mariadb


# Starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
