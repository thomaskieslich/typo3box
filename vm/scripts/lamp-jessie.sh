#!/bin/bash
echo "deb http://ftp.de.debian.org/debian/ jessie contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.de.debian.org/debian/ jessie contrib non-free" >> /etc/apt/sources.list
echo "deb http://security.debian.org/ jessie/updates contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates contrib non-free" >> /etc/apt/sources.list
echo "deb http://ftp.de.debian.org/debian/ jessie-updates contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.de.debian.org/debian/ jessie-updates contrib non-free" >> /etc/apt/sources.list

## add php packages
echo "deb http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list
echo "deb-src http://packages.dotdeb.org jessie all" >> /etc/apt/sources.list

apt-get update
apt-get -y --force-yes upgrade
apt-get -y install graphicsmagick imagemagick git-core unzip python-setuptools graphviz curl

##base mysql user
debconf-set-selections <<< 'mysql-server mysql-server/root_password password vagrant'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password vagrant'

##base lamp
apt-get -y --force-yes install apache2-mpm-worker libapache2-mod-fastcgi mysql-server
echo "ServerName localhost" | tee /etc/apache2/httpd.conf > /dev/null
a2enmod rewrite deflate expires headers actions alias

echo "
<IfModule mod_fastcgi.c>
  AddHandler fastcgi-script .fcgi
  FastCgiIpcDir /var/lib/apache2/fastcgi
</IfModule>
" > /etc/apache2/mods-available/fastcgi.conf

a2enmod fastcgi

service apache2 restart

## conf mysql
sed -i 's/\[mysql\]/[mysql] \
default-character-set=utf8 /' /etc/mysql/my.cnf

sed -i 's/\[client\]/[client] \
default-character-set=utf8 /' /etc/mysql/my.cnf

sed -i 's/\[mysqld\]/[mysqld] \
collation-server = utf8_unicode_ci \
init-connect='\''SET NAMES utf8'\'' \
character-set-server = utf8 /' /etc/mysql/my.cnf

service mysql restart

## sys php
apt-get -y --force-yes install php-zip php-mbstring php-pear php-bz2 php-curl php-xml php-soap
apt-get -y --force-yes install php5-fpm php5-cli php5-gd php5-mysql php5-pgsql php5-sqlite php5-curl php5-mcrypt php5-imap php5-xmlrpc php5-xsl php5-ldap

sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php5/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php5/fpm/php.ini
sed -i "s/;always_populate_raw_post_data = .*/always_populate_raw_post_data=-1/" /etc/php5/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php5/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php5/fpm/php.ini
sed -i "s/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/mailhog sendmail/" /etc/php5/fpm/php.ini

service php5-fpm restart

## php 7.0 dotdeb
apt-get -y --force-yes install php7.0-fpm php7.0-cli php7.0-gd php7.0-mysql php7.0-pgsql php7.0-sqlite php7.0-curl php7.0-mcrypt php7.0-imap php7.0-xmlrpc php7.0-xsl php7.0-ldap

sed -i "s/max_execution_time = .*/max_execution_time = 240/" /etc/php/7.0/fpm/php.ini
sed -i "s/; max_input_vars = .*/max_input_vars = 1500/" /etc/php/7.0/fpm/php.ini
sed -i "s/post_max_size = .*/post_max_size = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/upload_max_filesize = .*/upload_max_filesize = 128M/" /etc/php/7.0/fpm/php.ini
sed -i "s/;sendmail_path =/sendmail_path = \/usr\/local\/bin\/mailhog sendmail/" /etc/php/7.0/fpm/php.ini

service php7.0-fpm restart

# Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer

##MailHog
wget -q https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64
mv MailHog_linux_amd64 /usr/local/bin/mailhog
chmod +x /usr/local/bin/mailhog

echo "@reboot root mailhog" >> /etc/crontab


#prepare www dir and user
rm -r /var/www/*
mkdir -p /var/www

echo "www-data:www123" | chpasswd
chsh -s /bin/bash www-data
sudo usermod -aG sudo www-data
sed -i 's|[#]*PasswordAuthentication no|PasswordAuthentication yes|g' /etc/ssh/sshd_config
sed -i 's/PermitRootLogin without-password/PermitRootLogin no/g' /etc/ssh/sshd_config
service sshd restart

chown www-data.www-data /var/www -R
service apache2 restart
