
# Install and Configure WordPress

Built from online guide: [Ubuntu Tutorials - Install and configure WordPress](https://ubuntu.com/tutorials/install-and-configure-wordpress)

## Overview
### Server build
Server will be built the GCP admin console from a template. Need to QA, install latest updates and reboot.
```
sudo apt update && sudo apt upgrade -y
sudo reboot now
```
### Application Install Outline
Basic outline for software install and configure.
1. Install Dependencies
2. Download WordPress
3. Configure Apache
4. Configure database
5. Configure Wordpress

Once complete, continue with WordPress setup from the browser. http://carolinatech.io

## 1. Install Dependencies
Install application packages for Apache, MySQL, PHP, and additional extensions used in WordPress.
```
sudo apt install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip
```

## 2. Download WordPress
Create the directory, set ownership, and download the files from WordPress.org:
```
#!/bin/bash

# Create the directory
mkdir -p /srv/www
# Set ownership
chown www-data: /srv/www
# Download the files from WordPress.org
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
```

## 3. Configure Apache
Create Apache site .conf file and inject VirtualHost site configuration.
```
#!/bin/bash

# Create Apache site .conf file and inject VirtualHost site configuration
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
```

Enable new site, enable rewrite mode, disable default site, and restart Apache to pick up changes.
```
#!/bin/bash

# Enable new site
a2ensite carolinatech.io

# Enable URL rewriting
a2enmod rewrite

# Disable default site
a2dissite 000-default

# Reload to apply changes
service apache2 reload
```

## 4. Configure database
Start MySQL CLI
```
$ sudo mysql -u root
```
See a list of users
```
mysql> SELECT user,host,plugin from mysql.user;
```
Set password for root
```
mysql> ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'My9d0gly!';
```
Configure the new Wordpress database and user in MySQL
```
# Configure the new Wordpress database and user in MySQL
mysql> CREATE DATABASE carolinatechio;
mysql> CREATE USER carolinatechio@localhost IDENTIFIED BY 'vxe8MXN-yvh6vet.qvk';
mysql> GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER ON carolinatechio.* TO carolinatechio@localhost;
mysql> FLUSH PRIVILEGES;
mysql> quit;
```

DB Script
```
x
```