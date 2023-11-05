#!/bin/bash
echo "============================================"
echo "Install Dependencies"
echo "============================================"

# Install Apache2 web server
echo "Install Apache2 web server"
apt install apache2

# Install MySQL database
echo "Install MySQL database"
apt install mysql-server -y

# Install php & modules
echo "Install php & modules"
apt install php \
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

echo "============================================"
echo "Configure database"
echo "============================================"

# Database variables
user="wp_user"
pass="wordpress123513"
dbname="wp_db"
echo "Creating database..."
mysql -e "CREATE DATABASE $dbname;"
echo "Creating new user..."
mysql -e "CREATE USER '$user'@'%' IDENTIFIED BY '$pass';"
echo "User successfully created!"
echo "Setting user privileges..."
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'%';"
mysql -e "FLUSH PRIVILEGES;"
echo "Success :)"

echo "============================================"
echo "Install WordPress menggunakan Bash Script   "
echo "============================================"
#download wordpress
curl -O https://wordpress.org/latest.tar.gz
#unzip wordpress
tar -zxvf latest.tar.gz
#Change owner & chmod
chown -R www-data:www-data wordpress/
chmod -R 755 wordpress/
#change dir to wordpress
cd wordpress
#create wp config
cp wp-config-sample.php wp-config.php
chown -R www-data:www-data wp-config.php
#set database details with perl find and replace
perl -pi -e "s/database_name_here/$dbname/g" wp-config.php
perl -pi -e "s/username_here/$user/g" wp-config.php
perl -pi -e "s/password_here/$pass/g" wp-config.php
#set WP salts
perl -i -pe'
  BEGIN {
    @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
    push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
    sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
  }
  s/put your unique phrase here/salt()/ge
' wp-config.php
#create uploads folder and set permissions
mkdir wp-content/uploads
chmod 775 wp-content/uploads


#enable apache2
a2ensite wordpress.conf
a2enmod rewrite
a2dissite 000-default.conf
systemctl restart apache2
echo "Restart service Apache2"
systemctl restart apache2
echo "SSL generate with certbot"
apt install certbot python3-certbot-apache -y
certbot run -n --apache --agree-tos -d wp.igunawan.com -m admin@igunawan.com  --redirect
echo "========================="
echo "Installation is complete."
echo "=========================" 