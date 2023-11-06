#!/bin/bash

# mysql_config_editor set --login-path=local --host=localhost --user=root --password
# mysql --login-path=local  -e "SHOW DATABASES"

# Database variables
# dbuser="wp_user_004"
# dbuserpass="wordpress123513"
# dbname="wp_db_004"

while getopts d:u:p: flag
do
    case "${flag}" in
        d) dbname=${OPTARG};;
        u) dbuser=${OPTARG};;
        p) dbuserpass=${OPTARG};;
    esac
done

echo "Show all databases (before)"
mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"

echo -e "\nShow users"
mysql --defaults-extra-file=config.cnf -e "SELECT DISTINCT user FROM mysql.user;"

mysql --defaults-extra-file=config.cnf -e "CREATE DATABASE $dbname;"
mysql --defaults-extra-file=config.cnf -e "CREATE USER $dbuser@localhost IDENTIFIED BY '$dbuserpass';"
mysql --defaults-extra-file=config.cnf -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON $dbname.* TO $dbuser@localhost;"
mysql --defaults-extra-file=config.cnf -e "FLUSH PRIVILEGES;"

echo -e "\nShow all databases (after)"
mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"

echo -e "\nShow users"
mysql --defaults-extra-file=config.cnf -e "SELECT DISTINCT user FROM mysql.user;"

echo -e "\nNew database name: $dbname"
echo "New user name: $dbuser"
echo "New user password: $dbuserpass"

# var1=$(cat /dev/urandom | tr -cd 'a-zA-Z0-9~`!@#$%^&*_+={[}]|\:;<,>.?/' | fold -w 15 | head -n 1)

# Create random DB name
db_pre="db-"
var1="wp_$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 8)"
#var4="$var3$var2"
echo -e "\nRandom generated database name: $var1"

# Create random DB user password
var5=$(tr -dc 'a-zA-Z0-9~`!@#$%^&*_+={[}]|\:;<,>.?/' < /dev/urandom | head -c 15)
echo -e "\nRandom generated password: $var5"

# Create random DB username
var2=$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 5)
var3="dbuser-"
var4="${var3}${var2}"
echo -e "\nRandom generated username: $var4"