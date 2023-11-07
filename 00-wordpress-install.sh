#!/bin/bash
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

# *************************************************************
#                     CLEAN TO HERE
#                  BEGIN NEW TEST BLOCK
# *************************************************************

###################################
#   Site Specific veriables
###################################
WEBSITE_DOMAIN="carolinatech.org"


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

echo "Show ls for directory:"
echo ll /srv/www

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

echo -e "\nSuccess?"



# *************************************************************
#                     END NEW TEST BLOCK
# *************************************************************
