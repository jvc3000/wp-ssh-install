#!/bin/bash

# Create local user with password
mysql --defaults-extra-file=config.cnf -e "CREATE USER 'vcampbell3'@'localhost' IDENTIFIED BY 'My9d0gly!';"

# Assign superuser
mysql --defaults-extra-file=config.cnf -e "GRANT ALL PRIVILEGES ON *.* TO 'vcampbell3'@'localhost' WITH GRANT OPTION;"

# Create external hosts access user iwth password
mysql --defaults-extra-file=config.cnf -e "CREATE USER 'vcampbell3'@'%' IDENTIFIED BY 'My9d0gly!';"

# Assign superuser
mysql --defaults-extra-file=config.cnf -e "GRANT ALL PRIVILEGES ON *.* TO 'vcampbell3'@'%' WITH GRANT OPTION;"

# 6. To double check the privileges given to the new user, run SHOW GRANTS command:
mysql> SHOW GRANTS FOR vcampbell3;

# 7. Finally, when everything is settled, reload all the privileges:
mysql> FLUSH PRIVILEGES;