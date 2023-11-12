#!/bin/bash

#
# Script to install WordPress and LAMP stack
#
# @author   Vince Campbell <vince.campbell@gmail.com>
# @website  http://www.carolinatech.io
# @version  0.1.0

################################################################################
# CORE FUNCTIONS - Do not edit
# From @author   Raj KB <magepsycho@gmail.com>
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
        -s, --site        Website Domain  (***REQUIRED***)
        -h, --host        MySQL Host      (default is localhost)
        -d, --database    MySQL Database  (If empty, auto-generated)
        -u, --user        MySQL User      (If empty, auto-generated)
        -p, --pass        MySQL Password  (If empty, auto-generated)
        -h, --help        Display this help and exit
        -v, --version     Output script version information and exit
    Example:
        $(basename $0) --site=mywebsite.com
"
    exit 1
}

function processArgs()
{
    # Parse Arguments
    for arg in "$@"
    do
        case $arg in
            -s=*|--site=*)
                WEBSITE_DOMAIN="${arg#*=}"
            ;;
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

function installApache()
{
    apt-get install apache2 -y \
            ghostscript \
            libapache2-mod-php \
            certbot \
            python3-certbot-apache -y
}

function installMySQL()
{
    apt-get install mysql-server -y
}

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

function downloadWordpress()
{
    mkdir -p /srv/www
    chown www-data: /srv/www
    curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
    mv /srv/www/wordpress /srv/www/$WEBSITE_DOMAIN
}

function configApache()
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
    a2ensite $WEBSITE_DOMAIN > /dev/null
    # Enable URL rewriting
    a2enmod rewrite > /dev/null
    # Disable default site
    a2dissite 000-default > /dev/null
    # Reload to apply changes
    service apache2 reload > /dev/null

    # Validate web server is responding
    VALID_RESPONSE="setup-config.php"
    if curl -I "http://localhost" 2>&1 | grep -w "$VALID_RESPONSE" &> /dev/null; then
        echo "Success! Wordpress install is validated."
    else
        echo "WARNING: No valid http response for WordPress setup."
    fi
}

function createMysqlDbUser()
{
    SQL1="CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
    SQL2="CREATE USER '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    SQL3="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    SQL4="FLUSH PRIVILEGES;"
    BIN_MYSQL=$(which mysql)

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

function configWordpress()
{
    #create wp config
    cp /srv/www/$WEBSITE_DOMAIN/wp-config-sample.php /srv/www/$WEBSITE_DOMAIN/wp-config.php
    chown -R www-data:www-data /srv/www/$WEBSITE_DOMAIN/wp-config.php
    #set database details with perl find and replace
    perl -pi -e "s/database_name_here/$DB_NAME/g" /srv/www/$WEBSITE_DOMAIN/wp-config.php
    perl -pi -e "s/username_here/$DB_USER/g" /srv/www/$WEBSITE_DOMAIN/wp-config.php
    perl -pi -e "s/password_here/$DB_PASS/g" /srv/www/$WEBSITE_DOMAIN/wp-config.php
    #set WP salts
    perl -i -pe'
    BEGIN {
        @chars = ("a" .. "z", "A" .. "Z", 0 .. 9);
        push @chars, split //, "!@#$%^&*()-_ []{}<>~\`+=,.;:/?|";
        sub salt { join "", map $chars[ rand @chars ], 1 .. 64 }
    }
    s/put your unique phrase here/salt()/ge
    ' /srv/www/$WEBSITE_DOMAIN/wp-config.php
    #create uploads folder and set permissions
    mkdir /srv/www/$WEBSITE_DOMAIN/wp-content/uploads
    chmod 775 /srv/www/$WEBSITE_DOMAIN/wp-content/uploads
}

function setupCert()
{
    certbot run -n --apache --agree-tos -d $WEBSITE_DOMAIN,www.$WEBSITE_DOMAIN -m admin@$WEBSITE_DOMAIN  --redirect
}

function printSuccessMessage()
{
    RED='\033[0;31m'
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    NC='\033[0m' # No Color

    _success "WordPress installation complete!"

    echo -e "${RED}###########################################################${NC}"
    echo -e " ${GREEN}Database Information${NC}"
    echo -e " Domain:    ${BLUE}$WEBSITE_DOMAIN${NC}"
    echo -e " DB Host:   ${BLUE}$DB_HOST${NC}"
    echo -e " Schema:    ${BLUE}$DB_NAME${NC}"
    echo -e " Username:  ${BLUE}$DB_USER${NC}"
    echo -e " Password:  ${BLUE}$DB_PASS${NC}"
    echo -e "${RED}###########################################################${NC}"

    echo "========================="
    echo "Installation is complete."
    echo "========================="     
}

################################################################################
# Main
################################################################################
export LC_CTYPE=C
export LANG=C

DEBUG=0 # 1|0
_debug set -x
VERSION="0.1.0"

WEBSITE_DOMAIN=
DB_HOST='localhost'
DB_NAME=$(generateDBname)
DB_USER=
DB_PASS=$(generatePassword)

function main()
{
    [[ $# -lt 1 ]] && _printUsage 0
    
    _success "Processing arguments..."
    processArgs "$@"
    _success "Done!"

    _success "Installing Apache..."
    #installApache
    _success "Done!"

    _success "Installing MySQL..."
    #installMySQL
    _success "Done!"

    _success "Installing PHP..."
    #installPhp
    _success "Done!"

    _success "Downloading WordPress..."
    downloadWordpress
    _success "Done!"

    _success "Configuring Apache Virtual Host..."
    #configApache
    _success "Done!"

    _success "Creating MySQL db and user..."
    createMysqlDbUser
    _success "Done!"

    _success "Configure WordPress..."
    configWordpress
    _success "Done!"

    _success "Installing SSL Certificate..."
    #setupCert
    _success "Done!"

    printSuccessMessage

    exit 0
}

main "$@"

_debug set +x