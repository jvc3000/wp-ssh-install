#!/bin/bash

currentdir=$(ls -la /srv)
echo "The Current Directory is"
echo "${currentdir}"
rm -rf /srv/www/
#chown www-data: /srv/www
#curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
nowdir=$(ls -la /srv)
echo "The Directory is now"
echo "${nowdir}"
