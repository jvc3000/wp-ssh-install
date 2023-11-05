#!/bin/bash

echo "============================================"
echo "Configure database"
echo "============================================"

# Database variables
user="wp_user"
pass="wordpress123513"
dbname="wp_db"
echo "Creating database..."
mysql -e "CREATE DATABASE $dbname;"
echo "Creating new user..."
mysql -e "CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
echo "User successfully created!"
echo "Setting user privileges..."
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'%';"
mysql -e "FLUSH PRIVILEGES;"
echo "Success :)"