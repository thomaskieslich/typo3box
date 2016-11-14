#!/usr/bin/env bash

echo "
<VirtualHost *:80>
DocumentRoot /var/www/$PROJECT.$HOST/web
ServerName $PROJECT.$HOST
ServerAlias $PROJECT.*.xip.io

<Directory /var/www/$PROJECT.$HOST/>
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
Alias /php-fcgi /usr/lib/cgi-bin/php-$PROJECT
FastCgiExternalServer /usr/lib/cgi-bin/php-$PROJECT -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/$PROJECT.conf

a2ensite $PROJECT.conf

mkdir /var/www/$PROJECT.$HOST

chown www-data.www-data /var/www -R

service apache2 restart

echo "x host init"

su -c "source /vagrant/scripts/x-init.sh $PROJECT $HOST" www-data