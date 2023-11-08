#!/bin/bash

# Output to screen and file. Big performance hit
# exec > >(tee "debug2.log") 2>&1

# Domain (DNS) variable
WEBSITE_DOMAIN="carolinatech.org"

# Database variables
#DB_NAME="wp_db01"
#DB_USER="wp_user01"
#DB_PASS="vxe8MXN-yvh6vet.qvk"

DB_PRE='db-'
USR_PRE='usr-'

# Create random DB name
DB_NAME='db-'$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)
#DB_NAME=$PRE_DB$DB_NAME2
echo -e "\n    Database name: $DB_NAME"

# Create random DB username
DB_USER=$USR_PRE$(tr -dc 'a-z0-9' < /dev/urandom | head -c 5)
echo -e "Database username: $DB_USER"

# Create random DB user password
DB_PASS=$(tr -dc 'a-zA-Z0-9~`!@#$%^&*_+={[}]|\:;<,>.?/' < /dev/urandom | head -c 15)
echo -e "Database password: $DB_PASS"

# Database variables
DB_NAME="db-mrzng8s3"
#DB_USER="wp_user01"
#DB_PASS="vxe8MXN-yvh6vet.qvk"

echo "============================================"
echo "Configure database"
echo "============================================"

echo "Creating database..."
mysql -u root -e "CREATE DATABASE $DB_NAME;"

echo "Creating new user..."
mysql -u root -e "CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"

echo "Setting user privileges..."
mysql -u root -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "============================================"
echo "Configure WordPress"
echo "============================================"

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${RED}################################################${NC}"
echo -e "${GREEN}Database Information${NC}"
echo -e "Schema:   ${BLUE}$DB_NAME${NC}"
echo -e "Username: ${BLUE}$DB_USER${NC}"
echo -e "Password: ${BLUE}$DB_PASS${NC}"
echo -e "${RED}################################################${NC}"

echo "========================="
echo "Installation is complete."
echo "=========================" 