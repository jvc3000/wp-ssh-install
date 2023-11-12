#!/bin/bash

# Database variables
DB_USER="wp_user01"
DB_PASS="vxe8MXN-yvh6vet.qvk"
DB_NAME="wp_db01"

# Error checking that can be used later
USER_EXIST="$(mysql -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$DB_USER')")"

if [ "$USER_EXIST" = 1 ]; then
echo "WARNING: The DB user name $DB_USER already exist in the DB"
else
  echo "The DB user name $DB_USER does not exist in the DB"
fi