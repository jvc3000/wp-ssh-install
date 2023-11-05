#!/bin/bash

# mysql_config_editor set --login-path=local --host=localhost --user=root --password
# mysql --login-path=local  -e "SHOW DATABASES"

# Database variables
# dbuser="wp_user_002"
dbuserpass="wordpress123513"
dbname="wp_db_003"

mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"

mysql --defaults-extra-file=config.cnf -e "CREATE DATABASE $dbname;"
mysql --defaults-extra-file=config.cnf -e "CREATE USER $dbuser@localhost IDENTIFIED BY '$dbuserpass';"
mysql --defaults-extra-file=config.cnf -e "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON carolinatechio.* TO carolinatechio@localhost;"
mysql --defaults-extra-file=config.cnf -e "FLUSH PRIVILEGES;"

mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"