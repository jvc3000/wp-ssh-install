#!/bin/bash

# Validate web server is responding
VALID_RESPONSE="install.php"
if curl -I "http://localhost" 2>&1 | grep -w "$VALID_RESPONSE" &> /dev/null; then
    echo "Success! Wordpress install is validated. localhost is up. :)"
else
    echo "WARNING: No valid http response for WordPress setup. localhost is down :("
fi

echo -e "\n****************************"
curl -I "http://localhost" 2>&1