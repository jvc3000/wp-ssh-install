#!/bin/bash

# Output to screen and file. Big performance hit
exec > >(tee "debug.log") 2>&1

# Domain (DNS) variable
WEBSITE_DOMAIN="carolinatech.org"

# Database variables
DB_NAME="wp_db01"
DB_USER="wp_user01"
DB_PASS="vxe8MXN-yvh6vet.qvk"

echo "============================================"
echo "Install Dependencies"
echo "============================================"

# Install Apache2 web server
echo "Install Apache2 web server"
apt install apache2 -y \
            ghostscript \
            libapache2-mod-php

# Install MySQL database
echo "Install MySQL database"
apt install mysql-server -y

# Install php & modules
echo "Install php & modules"
apt install php -y \
            php-bcmath \
            php-curl \
            php-imagick \
            php-intl \
            php-json \
            php-mbstring \
            php-mysql \
            php-xml \
            php-zip


echo "============================================"
echo "Download WordPress"
echo "============================================"

# Create new Dir for web site files
echo "Create new Dir for web site files"
mkdir -p /srv/www

# Set Dir ownership to www-data
echo "Setting /srv/www ownership to www-data"
chown www-data: /srv/www

echo "Downloading Wordpress files..."
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

echo "Change installation defaul directory 'wordpress' to '$WEBSITE_DOMAIN'"
mv /srv/www/wordpress /srv/www/$WEBSITE_DOMAIN

echo "============================================"
echo "Configure Apache"
echo "============================================"

# Create Apache site .conf file and inject VirtualHost site configuration
echo "Create Apache site .conf file and inject VirtualHost site configuration"
echo "<VirtualHost *:80>
    ServerName $WEBSITE_DOMAIN
    ServerAlias www.$WEBSITE_DOMAIN
    DocumentRoot /srv/www/$WEBSITE_DOMAIN
    <Directory /srv/www/$WEBSITE_DOMAIN>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/$WEBSITE_DOMAIN/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$WEBSITE_DOMAIN.conf

# Enable new site
echo "Enable new site"
a2ensite $WEBSITE_DOMAIN

# Enable URL rewriting
echo "Enable URL rewriting"
a2enmod rewrite

# Disable default site
echo "Disable default site"
a2dissite 000-default

# Reload to apply changes
echo "Reload to apply changes"
service apache2 reload

# Validate web server is responding
VALID_RESPONSE="setup-config.php"
if curl -I "http://localhost" 2>&1 | grep -w "$VALID_RESPONSE" ; then
    echo "Success! Wordpress install is validated. localhost is up. :)"
else
    echo "WARNING: No valid http response for WordPress setup. localhost is down :("
fi

echo -e "\nSuccess!"

echo "============================================"
echo "Configure database"
echo "============================================"

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

#create wp config
cp /srv/www/carolinatech.org/wp-config-sample.php /srv/www/carolinatech.org/wp-config.php
chown -R www-data:www-data /srv/www/carolinatech.org/wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$DB_NAME/g" /srv/www/carolinatech.org/wp-config.php
perl -pi -e "s/username_here/$DB_USER/g" /srv/www/carolinatech.org/wp-config.php
perl -pi -e "s/password_here/$DB_PASS/g" /srv/www/carolinatech.org/wp-config.php
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

# Install SSL Cert
echo "SSL generate with certbot"
apt install certbot python3-certbot-apache -y
certbot run -n --apache --agree-tos -d $WEBSITE_DOMAIN,www.$WEBSITE_DOMAIN -m admin@$WEBSITE_DOMAIN  --redirect

RED='\033[0;31m'
BLUE='\033[0;34m'
GREEN='\033[0;32m'
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

echo -e "${RED}################################################${NC}"
echo -e "${GREEN}Database Information${NC}"
echo -e "Schema:   ${BLUE}$DB_NAME${NC}"
echo -e "Username: ${BLUE}$DB_USER${NC}"
echo -e "Password: ${BLUE}$DB_PASS${NC}"
echo -e "${RED}################################################${NC}"

echo "========================="
echo "Installation is complete."
echo "=========================" 