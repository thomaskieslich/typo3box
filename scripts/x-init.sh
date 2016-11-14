#!/usr/bin/env bash

PROJECT=$1
HOST=$2

# mkdir /var/www/8x.local.typo3.org
#  rm -rf /var/www/8x.local.typo3.org/*
#  sudo mysqladmin -uroot -pvagrant drop t3_8x_local;

cd /var/www/$PROJECT.$HOST

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
  "require": {
    "typo3/cms": "^8.4.0"
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
    --database-name="$PROJECT" \
    --admin-user-name="cms-admin" \
    --admin-password="admin123" \
    --site-name="$PROJECT"

./typo3cms extension:activate bootstrap_package
./typo3cms extension:activate introduction

./typo3cms extension:activate scheduler
./typo3cms extension:activate realurl
cp vendor/typo3/cms/_.htaccess web/.htaccess

./typo3cms autocomplete
./typo3cms database:updateschema '*.*'
./typo3cms cleanup:updatereferenceindex
./typo3cms cache:flush

echo "$PROJECT.$HOST is ready"
