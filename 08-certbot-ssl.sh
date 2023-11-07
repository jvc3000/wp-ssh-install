#!/bin/bash

echo "SSL generate with certbot"
apt install certbot python3-certbot-apache -y
certbot run -n --apache --agree-tos -d carolinatech.org,www.carolinatech.org -m admin@carolinatech.org  --redirect
echo "========================="
echo "Installation is complete."
echo "=========================" 