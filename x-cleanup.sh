#!/bin/bash

rm -R /srv/www/
a2dissite carolinatech.org.conf
a2ensite 000-default.conf
rm /etc/apache2/sites-available/carolinatech.org.conf
systemctl reload apache2

mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"
mysql --defaults-extra-file=config.cnf -e "DROP DATABASE wp_db01;"
mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"

mysql --defaults-extra-file=config.cnf -e "SELECT user FROM mysql.user;"
mysql --defaults-extra-file=config.cnf -e "DROP USER 'wp_user01'@'localhost';"
mysql --defaults-extra-file=config.cnf -e "SELECT user FROM mysql.user;"