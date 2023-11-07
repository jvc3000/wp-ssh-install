#!/bin/bash

# Drop users
mysql --defaults-extra-file=config.cnf -e "DROP USER 'vcampbell3'@'%';"
mysql --defaults-extra-file=config.cnf -e "DROP USER 'vcampbell3'@'localhost';"

# 6. To double check the privileges given to the new user, run SHOW GRANTS command:
mysql --defaults-extra-file=config.cnf -e "SHOW GRANTS FOR vcampbell3;"

# 7. Finally, when everything is settled, reload all the privileges:
mysql --defaults-extra-file=config.cnf -e "FLUSH PRIVILEGES;"