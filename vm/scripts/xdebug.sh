#!/usr/bin/env bash

apt-get -y --force-yes install php5-xdebug php5.6-xdebug php7.0-xdebug php7.1-xdebug

echo "zend_extension=xdebug.so
xdebug.remote_enable = on
xdebug.remote_handler = dbgp
xdebug.remote_host = 10.0.0.22
xdebug.remote_port = 9001

xdebug.max_nesting_level = 500

xdebug.profiler_enable = 0
xdebug.profiler_append = 0
xdebug.profiler_enable_trigger = 1
#xdebug.profiler_output_dir = /var/www/webtools/profiles
#xdebug.profiler_output_name = callgrind.out.%s
" > /etc/php5/mods-available/xdebug.ini

rm /etc/php5/cli/conf.d/20-xdebug.ini

echo "zend_extension=xdebug.so
xdebug.remote_enable = on
xdebug.remote_handler = dbgp
xdebug.remote_host = 10.0.0.22
xdebug.remote_port = 9001

xdebug.max_nesting_level = 500

xdebug.profiler_enable = 0
xdebug.profiler_append = 0
xdebug.profiler_enable_trigger = 1
#xdebug.profiler_output_dir = /var/www/webtools/profiles
#xdebug.profiler_output_name = callgrind.out.%s
" > /etc/php/5.6/mods-available/xdebug.ini

rm /etc/php5.6/cli/conf.d/20-xdebug.ini

echo "zend_extension=xdebug.so
xdebug.remote_enable = on
xdebug.remote_handler = dbgp
xdebug.remote_host = 10.0.0.22
xdebug.remote_port = 9001

xdebug.max_nesting_level = 500

xdebug.profiler_enable = 0
xdebug.profiler_append = 0
xdebug.profiler_enable_trigger = 1
#xdebug.profiler_output_dir = /var/www/webtools/profiles
#xdebug.profiler_output_name = callgrind.out.%s
" > /etc/php/7.0/mods-available/xdebug.ini

rm /etc/php/7.0/cli/conf.d/20-xdebug.ini

echo "zend_extension=xdebug.so
xdebug.remote_enable = on
xdebug.remote_handler = dbgp
xdebug.remote_host = 10.0.0.22
xdebug.remote_port = 9001

xdebug.max_nesting_level = 500

xdebug.profiler_enable = 0
xdebug.profiler_append = 0
xdebug.profiler_enable_trigger = 1
#xdebug.profiler_output_dir = /var/www/webtools/profiles
#xdebug.profiler_output_name = callgrind.out.%s
" > /etc/php/7.1/mods-available/xdebug.ini

rm /etc/php/7.1/cli/conf.d/20-xdebug.ini

mkdir /var/www/webtools
cd /var/www/webtools

composer create-project jokkedk/webgrind=dev-master --no-dev --no-interaction

chown www-data.www-data /var/www -R

echo "
<VirtualHost *:80>
DocumentRoot /var/www/webtools/webgrind
ServerName webgrind.t3b.example.org

<Directory /var/www/webtools/webgrind/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule mod_fastcgi.c>
 AddType application/x-httpd-fastphp .php
 Action application/x-httpd-fastphp /php-fcgi

# PHP7
Alias /php-fcgi /usr/lib/cgi-bin/php-webgrind
FastCgiExternalServer /usr/lib/cgi-bin/php-webgrind -appConnTimeout 10 -idle-timeout 1800 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/webgrind.conf

a2ensite webgrind.conf

service apache2 reload