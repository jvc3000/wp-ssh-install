#!/bin/bash

# Create random DB name
PRE_DB="db-"
PRE_USR="usr-"

var1="$PRE_DB$(tr -dc 'a-z0-9' < /dev/urandom | head -c 8)"
echo -e "\n    Database name: $var1"

# Create random DB username
var2="$PRE_USR$(tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c 5)"
echo -e "Database username: $var2"

# Create random DB user password
var3=$(tr -dc 'a-zA-Z0-9~`!@#$%^&*_+={[}]|\:;<,>.?/' < /dev/urandom | head -c 15)
echo -e "Database password: $var3"