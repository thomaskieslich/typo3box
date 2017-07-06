#!/usr/bin/env bash

cd /var/www/dev-master

echo '
{
  "repositories": [
    {
      "type": "composer",
      "url": "https://composer.typo3.org"
    }
  ],
   "minimum-stability": "dev",
  "require": {
    "typo3/cms": "dev-master as 8.7.3",
    "helhum/typo3-console": "^4.6",
    "typo3-ter/introduction": "^3.0",
    "typo3-ter/realurl": "^2.2"
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

## for typo3-console
ln -s vendor/bin/typo3cms
chmod +x typo3cms

./typo3cms install:setup --non-interactive \
    --database-user-name="root" \
    --database-user-password="vagrant" \
    --database-host-name="localhost" \
    --database-port="3306" \
    --database-name="t3_dev_master" \
    --admin-user-name="dev-admin" \
    --admin-password="admin123" \
    --site-name="TYPO3 dev-master"

./typo3cms extension:activate beuser
./typo3cms extension:activate scheduler
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
./typo3cms extension:activate realurl

cp vendor/typo3/cms/_.htaccess web/.htaccess

./typo3cms autocomplete
./typo3cms database:updateschema '*.*'
./typo3cms cleanup:updatereferenceindex
#./typo3cms cache:flush

echo "dev-master ready"
