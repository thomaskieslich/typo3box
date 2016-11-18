#!/usr/bin/env bash

#mkdir /var/www/dev-master
cd /var/www/dev-master
#  rm -rf /var/www/dev-master/*
#  sudo mysqladmin -uroot -pvagrant drop t3_dev_master;

echo '
{
  "repositories": [
    {
      "type": "composer",
      "url": "https://composer.typo3.org"
    },
    {
      "type": "git",
      "url": "https://github.com/dmitryd/typo3-realurl.git"
    },
    {
      "type": "git",
      "url": "https://github.com/TYPO3-Console/typo3_console.git"
    }
  ],
   "minimum-stability": "dev",
  "require": {
    "typo3/cms": "dev-master as 8.4.0"
  },
  "extra": {
    "typo3/cms": {
      "cms-package-dir": "{$vendor-dir}/typo3/cms",
      "web-dir": "web"
    }
  }
}
' > composer.json

composer install --no-interaction

composer require "helhum/typo3-console:^4.0"
ln -s vendor/bin/typo3cms
chmod +x typo3cms

composer require "typo3-ter/introduction:^2.3"

composer require "dmitryd/typo3-realurl:^2.1.0"

./typo3cms install:setup --non-interactive \
    --database-user-name="root" \
    --database-user-password="vagrant" \
    --database-host-name="localhost" \
    --database-port="3306" \
    --database-name="t3_dev_master" \
    --admin-user-name="cms-admin" \
    --admin-password="admin123" \
    --site-name="TYPO3 dev-master"

./typo3cms extension:activate bootstrap_package
./typo3cms extension:activate introduction

./typo3cms extension:activate scheduler
./typo3cms extension:activate realurl
cp vendor/typo3/cms/_.htaccess web/.htaccess

./typo3cms autocomplete
./typo3cms database:updateschema '*.*'
./typo3cms cleanup:updatereferenceindex
./typo3cms cache:flush

echo "dev-master ready"
