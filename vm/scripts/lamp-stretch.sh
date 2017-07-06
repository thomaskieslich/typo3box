#!/bin/bash

echo "deb http://ftp.de.debian.org/debian/ jessie contrib non-free" >>/etc/apt/sources.list
echo "deb-src http://ftp.de.debian.org/debian/ jessie contrib non-free" >>/etc/apt/sources.list
echo "deb http://security.debian.org/ jessie/updates contrib non-free" >>/etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates contrib non-free" >>/etc/apt/sources.list
echo "deb http://ftp.de.debian.org/debian/ jessie-updates contrib non-free" >>/etc/apt/sources.list
echo "deb-src http://ftp.de.debian.org/debian/ jessie-updates contrib non-free" >>/etc/apt/sources.list

## add php packages
apt-get -y install apt-transport-https lsb-release ca-certificates
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg -q
sh -c 'echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'

apt-get update
apt-get -y --force-yes upgrade
apt-get -y install graphicsmagick imagemagick git-core unzip python-setuptools graphviz curl virtualbox-guest-utils

##base mysql user
debconf-set-selections <<<'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<<'mysql-server mysql-server/root_password_again password vagrant'

##base lamp
apt-get -y --force-yes install apache2-mpm-worker libapache2-mod-fastcgi mysql-server
echo "ServerName localhost" | tee /etc/apache2/httpd.conf >/dev/null
a2enmod rewrite deflate expires headers actions alias

sed -i 's/\[mysql\]/[mysql] \
default-character-set=utf8 /' /etc/mysql/my.cnf

sed -i 's/\[client\]/[client] \
default-character-set=utf8 /' /etc/mysql/my.cnf

sed -i 's/\[mysqld\]/[mysqld] \
collation-server = utf8_unicode_ci \
init-connect='\''SET NAMES utf8'\'' \
character-set-server = utf8 /' /etc/mysql/my.cnf

service mysql restart

# Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

## MailHog
wget https://github.com/mailhog/MailHog/releases/download/v0.2.1/MailHog_linux_amd64 -q
mv MailHog_linux_amd64 /usr/local/bin/mailhog
chmod +x /usr/local/bin/mailhog

echo "@reboot root mailhog" >>/etc/crontab

echo "
<IfModule mod_fastcgi.c>
  AddHandler fastcgi-script .fcgi
  FastCgiIpcDir /var/lib/apache2/fastcgi
</IfModule>
" >/etc/apache2/mods-available/fastcgi.conf

a2enmod fastcgi

## php 5.6
apt-get -y --force-yes install php5.6-fpm php5.6-cli php5.6-gd php5.6-mysql php5.6-pgsql php5.6-sqlite php5.6-curl php5.6-mcrypt php5.6-imap php5.6-xmlrpc php5.6-xsl php5.6-ldap
##php ini
sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php/5.6/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php/5.6/fpm/php.ini
sed -i "s/;always_populate_raw_post_data = .*/always_populate_raw_post_data=-1/" /etc/php/5.6/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/5.6/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/5.6/fpm/php.ini

sed -i "s/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/mailhog sendmail/" /etc/php/5.6/fpm/php.ini


service php5.6-fpm restart

##php 7.0
apt-get -y --force-yes install php7.0-fpm php7.0-cli php7.0-gd php7.0-mysql php7.0-pgsql php7.0-sqlite php7.0-curl php7.0-mcrypt php7.0-imap php7.0-xmlrpc php7.0-xsl php7.0-ldap
sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php/7.0/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.0/fpm/php.ini

sed -i "s/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/mailhog sendmail/" /etc/php/7.0/fpm/php.ini

service php7.0-fpm restart

##php7.1
apt-get -y --force-yes install php7.1-fpm php7.1-cli php7.1-gd php7.1-mysql php7.1-pgsql php7.1-sqlite php7.1-curl php7.1-mcrypt php7.1-imap php7.1-xmlrpc php7.1-xsl php7.1-ldap
sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php/7.1/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php/7.1/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.1/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.1/fpm/php.ini

sed -i "s/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/mailhog sendmail/" /etc/php/7.1/fpm/php.ini

service php7.1-fpm restart

service apache2 restart

## prepare www dir and user
rm -r /var/www/*
mkdir -p /var/www

echo "www-data:www123" | chpasswd
chsh -s /bin/bash www-data
sudo usermod -aG sudo www-data
sed -i 's|[#]*PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config

chown www-data.www-data /var/www -R
service apache2 restart