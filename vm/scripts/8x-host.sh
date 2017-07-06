#!/usr/bin/env bash

echo "
<VirtualHost *:80>
DocumentRoot /var/www/8x/web
ServerName 8x.t3b.example.org
ServerAlias 8x.*.xip.io

<Directory /var/www/8x/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule mod_fastcgi.c>
 AddType application/x-httpd-fastphp .php
 Action application/x-httpd-fastphp /php-fcgi

# PHP7
Alias /php-fcgi /usr/lib/cgi-bin/php-8x
FastCgiExternalServer /usr/lib/cgi-bin/php-8x -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/8x.conf

a2ensite 8x.conf

mkdir /var/www/8x

chown www-data.www-data /var/www -R

service apache2 restart

echo "8x host init"

su -c "source /vagrant/scripts/8x-init.sh" www-data