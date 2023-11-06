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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# You can use these ANSI escape codes:
# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

echo -e "${RED}###############################################${NC}"
echo -e "         Configuration Information"
echo -e "   Database name: ${BLUE}$DB_NAME${NC}"
echo -e "     DB username: ${BLUE}$DB_USER${NC}"
echo -e "DB user passowrd: ${BLUE}$DB_PASS${NC}"
echo -e "${RED}###############################################${NC}"