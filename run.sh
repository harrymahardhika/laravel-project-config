#!/usr/bin/env bash

rm .php_cs.dist
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.php_cs.dist

rm .editorconfig
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.editorconfig

rm .gitignore
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/gitignore
mv gitignore .gitignore

rm build_helper
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/build_helper
chmod +x build_helper

rm php-cs-fixer
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/php-cs-fixer
chmod +x php-cs-fixer

chmod +x artisan
