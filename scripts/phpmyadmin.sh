#!/usr/bin/env bash

mkdir /var/www/webtools
cd /var/www/webtools

composer create-project phpmyadmin/phpmyadmin --repository-url=https://www.phpmyadmin.net/packages.json --no-dev

chown www-data.www-data /var/www -R

echo "
<VirtualHost *:80>
DocumentRoot /var/www/webtools/phpmyadmin
ServerName phpmyadmin.t3b.example.org

<Directory /var/www/webtools/phpmyadmin/>
    Options Indexes FollowSymLinks
    AllowOverride All
    Require all granted
</Directory>

<IfModule mod_fastcgi.c>
 AddType application/x-httpd-fastphp .php
 Action application/x-httpd-fastphp /php-fcgi

# PHP7
Alias /php-fcgi /usr/lib/cgi-bin/php-phpmyadmin
FastCgiExternalServer /usr/lib/cgi-bin/php-phpmyadmin -appConnTimeout 10 -idle-timeout 1800 -socket /run/php/php7.0-fpm.sock -pass-header Authorization

 <Directory /usr/lib/cgi-bin>
  Require all granted
 </Directory>
</IfModule>
</VirtualHost>
" > /etc/apache2/sites-available/phpmyadmin.conf

a2ensite phpmyadmin.conf

service apache2 reload