#!/bin/bash

echo "Show all databases (before)"
mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"

mysql mysql -uroot -p"My9d0gly!" -e "show databases" | grep -v Database | grep -v mysql| grep -v information_schema| grep -v performance_schema| gawk '{print "drop database `" $1 "`;select sleep(0.1);"}' | mysql -uroot -p"My9d0gly!"

echo -e "\nShow all databases (after)"
mysql --defaults-extra-file=config.cnf -e "SHOW DATABASES;"