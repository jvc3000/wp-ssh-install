#!/bin/bash

echo "The current /srv directory is"
ls -la /srv/ | sed /^total/d

mkdir -p /srv/www
if [ $? -eq 0 ]
then
  echo -e "\nSuccessfully made /srv/www directory"
  ls -la /srv/ | sed /^total/d
else
  echo -e "\nWARNING: Could not create directory" >&2
fi

chown www-data: /srv/www
if [ $? -eq 0 ] 
then 
  echo -e "\nSuccessfully changed directory /srv/www to owner www-data"
  ls -la /srv/ | sed /^total/d
else 
  echo -e "\nWARNING: Could not update directory owner" >&2 
fi

echo -e "\n"
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
if [ $? -eq 0 ]
then
  echo -e "\nSuccessfully downloaded wordpress files"
  ls -la /srv/www/wordpress/ | sed /^total/d
else
  echo -e "\nWARNING: Could not download wordpress files" >&2
fi
