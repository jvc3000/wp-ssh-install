#!/bin/bash

dbname="wp_db01"
user="wp_user01"
pass="vxe8MXN-yvh6vet.qvk"

#create wp config
cp /srv/www/carolinatech.org/wp-config-sample.php /srv/www/carolinatech.org/wp-config.php
chown -R www-data:www-data /srv/www/carolinatech.org/wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" /srv/www/carolinatech.org/wp-config.php
perl -pi -e "s/username_here/$user/g" /srv/www/carolinatech.org/wp-config.php
perl -pi -e "s/password_here/$pass/g" /srv/www/carolinatech.org/wp-config.php
#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' /srv/www/carolinatech.org/wp-config.php
#create uploads folder and set permissions
mkdir /srv/www/carolinatech.org/wp-content/uploads
chmod 775 /srv/www/carolinatech.org/wp-content/uploads