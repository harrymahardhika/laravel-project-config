#!/usr/bin/env bash

set -euo pipefail

echo "Select project type:"
echo "1) API only (no Node.js tooling)"
echo "2) Full app (includes Node.js tooling)"
if [ -n "${PROJECT_TYPE:-}" ]; then
  PROJECT_TYPE_INPUT="$PROJECT_TYPE"
elif [ -t 0 ]; then
  read -r -p "Enter 1 or 2 [2]: " PROJECT_TYPE_INPUT
else
  read -r -p "Enter 1 or 2 [2]: " PROJECT_TYPE_INPUT </dev/tty || PROJECT_TYPE_INPUT=""
fi

USE_NODE=true
if [ "${PROJECT_TYPE_INPUT:-2}" = "1" ]; then
  USE_NODE=false
fi

ensure_pnpm() {
  if command -v pnpm >/dev/null 2>&1; then
    return
  fi

  if command -v corepack >/dev/null 2>&1; then
    corepack enable >/dev/null 2>&1 || true
    corepack prepare pnpm@latest --activate
    return
  fi

  echo "pnpm is required for the full app setup. Install pnpm or enable corepack."
  exit 1
}

rm -f .php_cs.dist .php_cs.dist.php php-cs-fixer

rm -f .editorconfig
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.editorconfig

rm -f .gitignore
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/gitignore
mv gitignore .gitignore

rm -f .env.gitlab-ci
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.env.gitlab-ci

rm -f .gitlab-ci.yml
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.gitlab-ci.yml

mkdir -p .github/workflows
rm -f .github/workflows/test.yml
wget -O .github/workflows/test.yml https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/test.yaml

rm -f build_helper
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/build_helper
chmod +x build_helper

rm -f phpstan.neon
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/phpstan.neon

rm -f rector.php
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/rector.php

rm -f pint.json
wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/pint.json

if [ "$USE_NODE" = true ]; then
  rm -f .bladeformatterrc.json
  wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.bladeformatterrc.json

  rm -f .prettierrc.json
  wget https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/.prettierrc.json
else
  rm -f .bladeformatterrc.json .prettierrc.json
fi

chmod +x artisan

mkdir -p app/Domains

touch app/Domains/.gitkeep

if [ -f .env ]; then
  cp .env .env.testing
fi

for env_file in .env .env.testing .env.example; do
  if [ -f "$env_file" ]; then
    sed -i.bak \
      -e 's/^CACHE_STORE=database$/CACHE_STORE=redis/' \
      -e 's/^QUEUE_CONNECTION=database$/QUEUE_CONNECTION=redis/' \
      -e 's/^SESSION_DRIVER=database$/SESSION_DRIVER=redis/' \
      "$env_file"
    rm -f "${env_file}.bak"
  fi
done

composer require --dev barryvdh/laravel-debugbar barryvdh/laravel-ide-helper larastan/larastan laravel/pint rector/rector driftingly/rector-laravel

if [ "$USE_NODE" = true ]; then
  ensure_pnpm
  pnpm add -D blade-formatter prettier prettier-plugin-organize-attributes prettier-plugin-organize-imports
  pnpm remove lodash postcss
fi

tmp=$(mktemp)
jq '.scripts |= (.phpstan = "vendor/bin/phpstan analyse")' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts |= (.format = [])' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["vendor/bin/rector"]' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["vendor/bin/pint --verbose"]' composer.json > "$tmp" && mv "$tmp" composer.json
if [ "$USE_NODE" = true ]; then
  jq --indent 4 '.scripts.format |= .+["node_modules/.bin/blade-formatter -w -d resources/views/**/*.blade.php"]' composer.json > "$tmp" && mv "$tmp" composer.json
fi

composer run format
