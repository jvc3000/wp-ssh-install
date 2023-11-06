#!/bin/bash

echo "============================================"
echo "Configure database"
echo "============================================"

# Database variables
DB_USER="wp_user01"
DB_PASS="vxe8MXN-yvh6vet.qvk"
DB_NAME="wp_db01"

# Error checking that can be used later
RESULT_VARIABLE="$(mysql --defaults-extra-file=config.cnf -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$DB_USER')")"

if [ "$RESULT_VARIABLE" = 1 ]; then
echo "WARNING: The DB user name $DB_USER already exist in the DB"
else
  echo "The DB user name $DB_USER does not exist in the DB"
fi

echo "Creating database..."
mysql --defaults-extra-file=config.cnf -e "CREATE DATABASE $DB_NAME;"
echo "Creating new user..."
mysql --defaults-extra-file=config.cnf -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
# echo "User successfully created!"
echo "Setting user privileges..."
mysql --defaults-extra-file=config.cnf -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql --defaults-extra-file=config.cnf -e "FLUSH PRIVILEGES;"
echo "Success :)"

RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}###############################################"
echo -e "Configuration Information"
echo -e "Database name: $DB_NAME"
echo -e "Database user name: $DB_USER"
echo -e "Database user passowrd: $DB_PASS"
echo -e "###############################################${NC}"