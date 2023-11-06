#!/bin/bash

echo "============================================"
echo "Download WordPress"
echo "============================================"

# Create new Dir for web site files
echo "Create new Dir for web site files"
mkdir -p /srv/www

# Set Dir ownership to www-data
echo "Set Dir ownership to www-data"
chown www-data: /srv/www

echo "============================================"
echo "Configure Apache"
echo "============================================"

# Create Apache site .conf file and inject VirtualHost site configuration
echo "Create Apache site .conf file and inject VirtualHost site configuration"
echo "<VirtualHost *:80>
    ServerName carolinatech.io
    ServerAlias www.carolinatech.io
    DocumentRoot /srv/www/carolinatech.io
    <Directory /srv/www/carolinatech.io>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/carolinatech.io/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>" > /etc/apache2/sites-available/carolinatech.io.conf

# Enable new site
echo "Enable new site"
a2ensite carolinatech.io

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