#!/bin/bash

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
if curl -I "http://localhost" 2>&1 | grep -w "200\|301" ; then
    echo "Success! localhost is up! :)"
else
    echo "WARNING: localhost is down :("
fi

echo -e "\nSuccess?"