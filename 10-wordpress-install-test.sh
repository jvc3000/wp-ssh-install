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

echo -e "\nSuccess?"