#!/bin/bash

echo "============================================"
echo "Configure database"
echo "============================================"

# Database variables
user="wp_user01"
pass="vxe8MXN-yvh6vet.qvk"
dbname="wp_db01"

# Error checking that can be used later
RESULT_VARIABLE="$(mysql --defaults-extra-file=config.cnf -sse "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$user')")"

if [ "$RESULT_VARIABLE" = 1 ]; then
echo "WARNING: The DB user name $user already exist in the DB"
else
  echo "The DB user name $user does not exist in the DB"
fi

echo "Creating database..."
mysql --defaults-extra-file=config.cnf -e "CREATE DATABASE $dbname;"
echo "Creating new user..."
mysql --defaults-extra-file=config.cnf -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';"
# echo "User successfully created!"
echo "Setting user privileges..."
mysql --defaults-extra-file=config.cnf -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'localhost';"
mysql --defaults-extra-file=config.cnf -e "FLUSH PRIVILEGES;"
echo "Success :)"

bold=$(tput bold)
normal=$(tput sgr0)
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${RED}###############################################${NC}"
echo -e "${bold}Configuration Info${normal}"
echo -e "Database name: $dbname"
echo -e "Database user name: $user"
echo -e "Database user passowrd: $pass"
echo -e "${RED}###############################################${NC}"