#!/bin/bash

USERID="adminuser"
PASSWD="pw62892663"

echo "Show current users:"
mysql -e "SELECT user,plugin,host FROM mysql.user;"

echo "Adding superuser..."
# Create local user with password
mysql -e "CREATE USER '$USERID'@'localhost' IDENTIFIED BY '$PASSWD';"

# Assign superuser
mysql -e "GRANT ALL ON *.* TO '$USERID'@'localhost' WITH GRANT OPTION;"

# 6. To double check the privileges given to the new user, run SHOW GRANTS command:
# mysql -e "SHOW GRANTS FOR $USERID;"

echo "Show user list after add:"
mysql -e "SELECT user,plugin,host FROM mysql.user;"

# 7. Finally, when everything is settled, reload all the privileges:
mysql -e "FLUSH PRIVILEGES;"