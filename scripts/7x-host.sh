#!/usr/bin/env bash

echo "
<VirtualHost *:80>
DocumentRoot /var/www/7x/web
ServerName 7x.t3b.example.org
ServerAlias 7x.*.xip.io

<Directory /var/www/7x/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule mod_fastcgi.c>
 AddType application/x-httpd-fastphp .php
 Action application/x-httpd-fastphp /php-fcgi

# PHP5
Alias /php-fcgi /usr/lib/cgi-bin/php5-7x
FastCgiExternalServer /usr/lib/cgi-bin/php5-7x -appConnTimeout 10 -idle-timeout 250 -socket /var/run/php5-fpm.sock -pass-header Authorization

# PHP7
#Alias /php-fcgi /usr/lib/cgi-bin/php
#FastCgiExternalServer /usr/lib/cgi-bin/php -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/7x.conf

a2ensite 7x.conf

mkdir /var/www/7x

chown www-data.www-data /var/www -R

service apache2 restart

echo "7x host init"

su -c "source /vagrant/scripts/7x-init.sh" www-data