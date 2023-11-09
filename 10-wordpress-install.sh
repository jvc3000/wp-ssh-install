#!/bin/bash

#
# Script to install WordPress and LAMP stack
#
# @author   Vince Campbell <vince.campbell@gmail.com>
# @website  http://www.carolinatech.io
# @version  0.1.0

################################################################################
# CORE FUNCTIONS - Do not edit
################################################################################
#
# VARIABLES
#
_bold=$(tput bold)
_underline=$(tput sgr 0 1)
_reset=$(tput sgr0)

_purple=$(tput setaf 171)
_red=$(tput setaf 1)
_green=$(tput setaf 76)
_tan=$(tput setaf 3)
_blue=$(tput setaf 38)

#
# HEADERS & LOGGING
#
function _debug()
{
    [ "$DEBUG" -eq 1 ] && $@
}

function _header()
{
    printf "\n${_bold}${_purple}==========  %s  ==========${_reset}\n" "$@"
}

function _arrow()
{
    printf "➜ $@\n"
}

function _success()
{
    printf "${_green}✔ %s${_reset}\n" "$@"
}

function _error() {
    printf "${_red}✖ %s${_reset}\n" "$@"
}

function _warning()
{
    printf "${_tan}➜ %s${_reset}\n" "$@"
}

function _underline()
{
    printf "${_underline}${_bold}%s${_reset}\n" "$@"
}

function _bold()
{
    printf "${_bold}%s${_reset}\n" "$@"
}

function _note()
{
    printf "${_underline}${_bold}${_blue}Note:${_reset}  ${_blue}%s${_reset}\n" "$@"
}

function _die()
{
    _error "$@"
    exit 1
}

function _safeExit()
{
    exit 0
}

#
# UTILITY HELPER
#
function _seekConfirmation()
{
  printf "\n${_bold}$@${_reset}"
  read -p " (y/n) " -n 1
  printf "\n"
}

# Test whether the result of an 'ask' is a confirmation
function _isConfirmed()
{
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
        return 0
    fi
    return 1
}


function _typeExists()
{
    if [ $(type -P $1) ]; then
        return 0
    fi
    return 1
}

function _isOs()
{
    if [[ "${OSTYPE}" == $1* ]]; then
      return 0
    fi
    return 1
}

function _checkRootUser()
{
    #if [ "$(id -u)" != "0" ]; then
    if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo"
        exit 1;
    fi

}

################################################################################
# SCRIPT FUNCTIONS
################################################################################
function generatePassword()
{
    echo "$(openssl rand -base64 12)"
}

function generateDBname()
{
    PRE_DB="wp_"
    echo "$PRE_DB$(tr -dc '0-9a-z' < /dev/urandom | head -c 6)"
}


function _printUsage()
{
    echo -n "$(basename $0) [OPTION]...
Version $VERSION
    Options:
        -h, --host        MySQL Host
        -d, --database    MySQL Database
        -u, --user        MySQL User
        -p, --pass        MySQL Password (If empty, auto-generated)
        -h, --help        Display this help and exit
        -v, --version     Output version information and exit
    Example:
        $(basename $0) --database=mydbname
"
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            -h=*|--host=*)
                DB_HOST="${arg#*=}"
            ;;
            -d=*|--database=*)
                DB_NAME="${arg#*=}"
            ;;
            -u=*|--user=*)
                DB_USER="${arg#*=}"
            ;;
            -p=*|--pass=*)
                DB_PASS="${arg#*=}"
            ;;
            --debug)
                DEBUG=1
            ;;
            -h|--help)
                _printUsage
            ;;
            *)
                _printUsage
            ;;
        esac
    done
    [[ -z $DB_NAME ]] && _error "Database name cannot be empty." && exit 1
    [[ $DB_USER ]] || DB_USER=$DB_NAME
}

function createMysqlDbUser()
{
    SQL1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    SQL2="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    SQL3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    SQL4="FLUSH PRIVILEGES;"

#    if [ -f /etc/mysql/my.cnf ]; then
    if [ -f /etc/mysql/my.cnf ]; then
        $BIN_MYSQL -e "${SQL1}${SQL2}${SQL3}${SQL4}"
    else
        # If /etc/mysql/my.cnf doesn't exist then it'll ask for root password
        _arrow "Please enter root user MySQL password!"
        read rootPassword
        $BIN_MYSQL -h $DB_HOST -u root -p${rootPassword} -e "${SQL1}${SQL2}${SQL3}${SQL4}"
    fi
}

function printSuccessMessage()
{
    _success "MySQL DB / User creation completed!"

    echo "################################################################"
    echo ""
    echo " >> Host      : ${DB_HOST}"
    echo " >> Database  : ${DB_NAME}"
    echo " >> User      : ${DB_USER}"
    echo " >> Pass      : ${DB_PASS}"
    echo ""
    echo "################################################################"
}

################################################################################
# Main
################################################################################
export LC_CTYPE=C
export LANG=C

DEBUG=0 # 1|0
_debug set -x
VERSION="0.1.0"
BIN_MYSQL=$(which mysql)

WEBSITE_DOMAIN="carolinatech.org"  # Domain (DNS) variable
DB_HOST='localhost'
DB_NAME=$(generateDBname)
DB_USER=
DB_PASS=$(generatePassword)

function main()
{
#    [[ $# -lt 1 ]] && _printUsage 0
    _success "Processing arguments..."
    processArgs "$@"
    _success "Done!"

    _success "Creating MySQL db and user..."
    createMysqlDbUser
    _success "Done!"

    printSuccessMessage

    exit 0
}

# clear
main "$@"

_debug set +x



############################################################################################
#------------------------------------ Code merge ------------------------------------------#
############################################################################################

echo "============================================"
echo "Install Dependencies"
echo "============================================"

# Install Apache2 web server
function installApache()
{
    apt-get install apache2 -y \
            ghostscript \
            libapache2-mod-php \
            certbot \
            python3-certbot-apache -y
}

# Install MySQL database
function installMySQL()
{
    apt-get install mysql-server -y
}


# Install php & modules
function installPhp()
{
    apt-get install php -y \
            php-bcmath \
            php-curl \
            php-imagick \
            php-intl \
            php-json \
            php-mbstring \
            php-mysql \
            php-xml \
            php-zip
}


echo "============================================"
echo "Download WordPress"
echo "============================================"


# Download WordPress
function downloadWordpress()
{
    # Create new Dir for web site files
    mkdir -p /srv/www
    # Set Dir ownership to www-data
    chown www-data: /srv/www
    # Download latest WordPress
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
    # Change installation defaul directory 'wordpress' to '$WEBSITE_DOMAIN'"
    mv /srv/www/wordpress /srv/www/$WEBSITE_DOMAIN
}


echo "============================================"
echo "Configure Apache"
echo "============================================"



function setupApache()
{
    # Create Apache site .conf file and inject VirtualHost site configuration
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
    a2ensite $WEBSITE_DOMAIN
    # Enable URL rewriting
    a2enmod rewrite
    # Disable default site
    a2dissite 000-default
    # Reload to apply changes
    service apache2 reload

    # Validate web server is responding
    VALID_RESPONSE="setup-config.php"
    if curl -I "http://localhost" 2>&1 | grep -w "$VALID_RESPONSE" ; then
        echo "Success! Wordpress install is validated. localhost is up. :)"
    else
        echo "WARNING: No valid http response for WordPress setup. localhost is down :("
    fi
}




echo "============================================"
echo "Configure WordPress"
echo "============================================"


function setupWordpress()
{
    #create wp config
    #N# create var for 
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
}


# Install SSL Cert
function setupCert()
{
    certbot run -n --apache --agree-tos -d $WEBSITE_DOMAIN,www.$WEBSITE_DOMAIN -m admin@$WEBSITE_DOMAIN  --redirect
}



function outputOther()
{
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
}



echo "========================="
echo "Installation is complete."
echo "=========================" 