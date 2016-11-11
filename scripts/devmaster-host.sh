#!/usr/bin/env bash

echo "
<VirtualHost *:80>
DocumentRoot /var/www/dev-master.local.typo3.org/web
ServerName dev-master.local.typo3.org
ServerAlias dev-master.*.xip.io

<Directory /var/www/dev-master.local.typo3.org/>
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
Alias /php-fcgi /usr/lib/cgi-bin/php-dev-master
FastCgiExternalServer /usr/lib/cgi-bin/php-dev-master -appConnTimeout 10 -idle-timeout 250 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/dev-master.conf

a2ensite dev-master.conf

mkdir /var/www/dev-master.local.typo3.org

chown www-data.www-data /var/www -R

service apache2 restart

echo "dev-master host init"

su -c "source /vagrant/scripts/dev-master-init.sh" www-data