#!/bin/bash

echo "The current /etc/apache2/sites-available directory is"
ls -la /etc/apache2/sites-available | sed /^total/d

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

echo "The updated /etc/apache2/sites-available directory is"
ls -la /etc/apache2/sites-available | sed /^total/d

