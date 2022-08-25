#!/usr/bin/env bash

rm .php_cs.dist
rm .php_cs.dist.php
# wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.php_cs.dist.php

rm .editorconfig
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.editorconfig

rm .gitignore
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/gitignore
mv gitignore .gitignore

rm .env.gitlab-ci
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/env.gitlab-ci
mv env.gitlab-ci .env.gitlab-ci

rm .gitlab-ci.yml
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/gitlab-ci.yml
mv gitlab-ci.yml .gitlab-ci.yml

rm build_helper
# wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/build_helper
# chmod +x build_helper

rm phpstan.neon
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/phpstan.neon

rm php-cs-fixer

chmod +x artisan

composer require --dev barryvdh/laravel-debugbar
composer require --dev nunomaduro/larastan
composer require --dev laravel/pint

tmp=$(mktemp)
jq '.scripts |= (.phpstan = "vendor/bin/phpstan analyse")' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts |= (.pint = "vendor/bin/pint")' composer.json > "$tmp" && mv "$tmp" composer.json

composer run pint
