#!/bin/bash

# This is a testing cleanup script to reset Apache and delete WP dir.
# Setup wp-install to easily retest over and over without reloading all the apps.
# In wp-install.sh comment out the following:
#       #installApache
#       #installMySQL
#       #installPhp
# Run this cleanup script before each new main script test run

rm -R /srv/www/
a2dissite carolinatech.org.conf
a2ensite 000-default.conf
rm /etc/apache2/sites-available/carolinatech.org.conf
systemctl reload apache2

#mysql -e "SHOW DATABASES;"
#mysql -e "DROP DATABASE wp_db01;"
#mysql -e "SHOW DATABASES;"

#mysql -e "SELECT user FROM mysql.user;"
#mysql -e "DROP USER 'wp_user01'@'localhost';"
#mysql -e "SELECT user FROM mysql.user;"