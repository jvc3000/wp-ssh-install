
# Install and Configure WordPress

Built from online guide: [Ubuntu Tutorials - Install and configure WordPress](https://ubuntu.com/tutorials/install-and-configure-wordpress)

## Overview

### Pre Build Requirements
Script files and private key staged on the push (jump) linux server
### Old Build cleanup (for testing only)
1. In GCP console, change old server to an Ephemeral IP to free up the reserved static IP used by our DNS
https://console.cloud.google.com/compute/instances?project=carolinatech-io
2. Delete push server's .ssh/known_hosts file (or entry), so a new host key can be accepted for the DNS name.
3. Delete desktop .ssh/known_hosts file (or entry). Used by MySQl Wrokbench.
```
ssh-keygen -f "/home/vcampbell3/.ssh/known_hosts" -R "carolinatech.org"
```

### New GCP VM build
Server will be built from the GCP admin console using a pre defined Instance Template. Then need to QA, install latest updates, and reboot server.
1. **VM Build -** Create new Ubuntu 22.04.3 LTS virtual machine from GCP Compute Engine Instance template. Be sure to map Reserved External IP in build template.
2. **Route DNS -** Update DNS to new build's External IP **OR** map VM to a Reserved Static External IP (used by the old VM).
3. **Updates -** DO NOT SKIP - Check for and apply any updates, then reboot.
```
sudo apt update && sudo apt upgrade -y
sudo reboot now
```
4. **Scripts -** Stage script and config file  
```
scp 00-wordpress-install.sh config.cnf vcampbell3@carolinatech.org:
```

### Application Install Outline
High level steps to install and configure WordPress in a new server.
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