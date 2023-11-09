#!/bin/bash

function generateDBname()
{
    PRE_DB="wp_"
    var1="$PRE_DB$(tr -dc '0-9a-z' < /dev/urandom | head -c 6)"
    echo -e "Database name: $var1"
}

generateDBname