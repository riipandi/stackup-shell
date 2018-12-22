#!/usr/bin/env bash

if [[ $EUID -ne 0 ]]; then echo -e 'This script must be run as root' ; exit 1 ; fi

apt -y install composer php5.6 php5.6-{common,cli,cgi,fpm,mbstring,opcache,xmlrpc,gmp} \
php5.6-{bcmath,zip,sqlite3,intl,json,xml,imap,gd,curl,readline,zip,mysql,pgsql}

crudini --set /etc/php/5.6/fpm/php-fpm.conf  'www' 'listen' '/var/run/php/php5.6-fpm.sock'
systemctl restart php5.6-fpm
