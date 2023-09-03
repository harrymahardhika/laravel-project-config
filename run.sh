#!/usr/bin/env bash

rm .php_cs.dist
rm .php_cs.dist.php
rm php-cs-fixer

rm .editorconfig
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.editorconfig

rm .gitignore
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/gitignore
mv gitignore .gitignore

rm .env.gitlab-ci
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.env.gitlab-ci

rm .gitlab-ci.yml
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.gitlab-ci.yml

rm build_helper
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/build_helper
chmod +x build_helper

rm phpstan.neon
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/phpstan.neon

rm pint.json
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/pint.json

rm .bladeformatterrc.json
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.bladeformatterrc.json

rm .prettierrc.json
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.prettierrc.json

chmod +x artisan

composer require --dev barryvdh/laravel-debugbar barryvdh/laravel-ide-helper nunomaduro/larastan laravel/pint nunomaduro/phpinsights
composer require pestphp/pest --dev -W
composer require pestphp/pest-plugin-laravel --dev

npm install --save-dev blade-formatter prettier prettier-plugin-organize-attributes prettier-plugin-organize-imports @vue/typescript
npm uninstall lodash postcss

tmp=$(mktemp)
jq '.scripts |= (.phpstan = "vendor/bin/phpstan analyse")' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts |= (.format = [])' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["vendor/bin/pint --verbose"]' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["node_modules/.bin/prettier -w -l resources/js"]' composer.json > "$tmp" && mv "$tmp" composer.json
jq --indent 2 '.scripts.format |= .+["node_modules/.bin/blade-formatter -w -d resources/views/**/*.blade.php"]' composer.json > "$tmp" && mv "$tmp" composer.json

composer run format
