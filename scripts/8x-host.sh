#!/usr/bin/env bash

echo "
<VirtualHost *:80>
DocumentRoot /var/www/8x.local.typo3.org/web
ServerName 8x.local.typo3.org
ServerAlias 8x.*.xip.io

<Directory /var/www/8x.local.typo3.org/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule mod_fastcgi.c>
 AddType application/x-httpd-fastphp .php
 Action application/x-httpd-fastphp /php-fcgi

# PHP5
# Alias /php-fcgi /usr/lib/cgi-bin/php5-fcgi
# FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -appConnTimeout 10 -idle-timeout 250 -socket /var/run/php5-fpm.sock -pass-header Authorization

# PHP7
Alias /php-fcgi /usr/lib/cgi-bin/php
FastCgiExternalServer /usr/lib/cgi-bin/php -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/8x.conf

a2ensite 8x.conf

mkdir /var/www/8x.local.typo3.org

chown www-data.www-data /var/www -R

service apache2 restart

echo "8x host init"

su -c "source /vagrant/scripts/8x-init.sh" www-data