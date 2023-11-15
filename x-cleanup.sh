#!/bin/bash

rm -R /srv/www/
a2dissite carolinatech.org.conf >/dev/null
a2ensite 000-default.conf >/dev/null
rm /etc/apache2/sites-available/carolinatech.org.conf
systemctl reload apache2