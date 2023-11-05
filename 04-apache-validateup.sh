#!/bin/bash
if curl -I "http://localhost" 2>&1 | grep -w "200\|301" ; then
    echo "localhost is up"
else
    echo "localhost is down"
fi
