#!/usr/bin/env bash

cd /var/www/8x

echo '
{
  "repositories": [
    {
      "type": "composer",
      "url": "https://composer.typo3.org"
    }
  ],
  "require": {
    "typo3/cms": "^8.7"
  },
  "extra": {
    "typo3/cms": {
      "cms-package-dir": "{$vendor-dir}/typo3/cms",
      "web-dir": "web"
    },
    "helhum/typo3-console": {
        "install-binary": false,
        "install-extension-dummy": false
    }
  }
}
' >composer.json

composer install --no-interaction

composer require "helhum/typo3-console:^4.6"
ln -s vendor/bin/typo3cms
chmod +x typo3cms

composer require "typo3-ter/introduction:^2.3"
composer require "dmitryd/typo3-realurl:^2.2.0"

./typo3cms install:setup --non-interactive  \
 --database-user-name="root"  \
 --database-user-password="vagrant"  \
 --database-host-name="localhost"  \
 --database-port="3306"  \
 --database-name="t3_8x"  \
 --admin-user-name="dev-admin"  \
 --admin-password="admin123"  \
 --site-name="TYPO3 8x"

./typo3cms extension:activate beuser
./typo3cms extension:activate rte_ckeditor
./typo3cms extension:activate context_help
./typo3cms extension:activate viewpage
./typo3cms extension:activate func
./typo3cms extension:activate wizard_crpages
./typo3cms extension:activate wizard_sortpages
./typo3cms extension:activate info
./typo3cms extension:activate info_pagetsconfig
./typo3cms extension:activate tstemplate
./typo3cms extension:activate fluid_styled_content
./typo3cms extension:activate cshmanual
./typo3cms extension:activate documentation
./typo3cms extension:activate about
./typo3cms extension:activate t3editor
./typo3cms extension:activate sys_note
./typo3cms extension:activate rsaauth
./typo3cms extension:activate reports
./typo3cms extension:activate recycler
./typo3cms extension:activate reports
./typo3cms extension:activate opendocs
./typo3cms extension:activate setup
./typo3cms extension:activate lowlevel
#./typo3cms extension:activate taskcenter
#./typo3cms extension:activate sys_action
#./typo3cms extension:activate impexp

./typo3cms extension:activate bootstrap_package
./typo3cms extension:activate introduction

./typo3cms extension:activate scheduler
./typo3cms extension:activate realurl

cp vendor/typo3/cms/_.htaccess web/.htaccess

./typo3cms autocomplete
./typo3cms database:updateschema '*.*'
./typo3cms cleanup:updatereferenceindex
./typo3cms cache:flush

echo "8x ready"
