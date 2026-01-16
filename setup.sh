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

fetch() {
  local url="$1"
  local output="${2:-}"

  if command -v curl >/dev/null 2>&1; then
    if [ -n "$output" ]; then
      curl -fsSL "$url" -o "$output"
    else
      curl -fsSL "$url" -O
    fi
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    if [ -n "$output" ]; then
      wget -O "$output" "$url"
    else
      wget "$url"
    fi
    return
  fi

  echo "Missing download tool. Install curl or wget." >&2
  exit 1
}

BASE_URL="${BASE_URL:-https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master}"

fetch_repo() {
  local path="$1"
  local output="${2:-}"

  if [ -n "${BASE_DIR:-}" ] && [ -f "$BASE_DIR/$path" ]; then
    if [ -n "$output" ]; then
      cp "$BASE_DIR/$path" "$output"
    else
      cp "$BASE_DIR/$path" .
    fi
    return
  fi

  fetch "${BASE_URL}/${path}" "$output"
}

rm -f .php_cs.dist .php_cs.dist.php php-cs-fixer

rm -f .editorconfig
fetch_repo .editorconfig

rm -f .gitignore
fetch_repo gitignore
mv gitignore .gitignore

rm -f .env.gitlab-ci
fetch_repo .env.gitlab-ci

rm -f .env.github-ci
fetch_repo .env.github-ci

rm -f .gitlab-ci.yml
fetch_repo .gitlab-ci.yml

mkdir -p .github/workflows
rm -f .github/workflows/test.yml
fetch_repo test.yaml .github/workflows/test.yml

rm -f build_helper
fetch_repo build_helper
chmod +x build_helper

rm -f phpstan.neon
fetch_repo phpstan.neon

rm -f rector.php
fetch_repo rector.php

rm -f pint.json
fetch_repo pint.json

if [ "$USE_NODE" = true ]; then
  rm -f .bladeformatterrc.json
  fetch_repo .bladeformatterrc.json

  rm -f .prettierrc.json
  fetch_repo .prettierrc.json
else
  rm -f .bladeformatterrc.json .prettierrc.json
fi

chmod +x artisan

mkdir -p app/Domains
mkdir -p lang

touch app/Domains/.gitkeep

if [ -f .env ]; then
  cp .env .env.testing
fi

for env_file in .env .env.example; do
  if [ -f "$env_file" ]; then
    sed -i.bak \
      -e 's/^CACHE_STORE=database$/CACHE_STORE=redis/' \
      -e 's/^QUEUE_CONNECTION=database$/QUEUE_CONNECTION=redis/' \
      -e 's/^SESSION_DRIVER=database$/SESSION_DRIVER=redis/' \
      "$env_file"
    rm -f "${env_file}.bak"
  fi
done

composer require --dev -vvv barryvdh/laravel-debugbar barryvdh/laravel-ide-helper larastan/larastan laravel/pint rector/rector driftingly/rector-laravel

if [ "$USE_NODE" = true ]; then
  ensure_pnpm
  pnpm add -D blade-formatter prettier prettier-plugin-organize-attributes prettier-plugin-organize-imports
  if [ -f package.json ]; then
    deps_to_remove=()
    if jq -e '.dependencies.lodash? // empty' package.json >/dev/null; then
      deps_to_remove+=("lodash")
    elif jq -e '.devDependencies.lodash? // empty' package.json >/dev/null; then
      deps_to_remove+=("lodash")
    fi
    if jq -e '.dependencies.postcss? // empty' package.json >/dev/null; then
      deps_to_remove+=("postcss")
    elif jq -e '.devDependencies.postcss? // empty' package.json >/dev/null; then
      deps_to_remove+=("postcss")
    fi
    if [ "${#deps_to_remove[@]}" -gt 0 ]; then
      pnpm remove "${deps_to_remove[@]}"
    fi
  fi
fi

tmp=$(mktemp)
jq '.scripts |= (.phpstan = "vendor/bin/phpstan analyse")' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts |= (.format = [])' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["vendor/bin/rector"]' composer.json > "$tmp" && mv "$tmp" composer.json
jq '.scripts.format |= .+["vendor/bin/pint --verbose"]' composer.json > "$tmp" && mv "$tmp" composer.json
if [ "$USE_NODE" = true ]; then
  jq --indent 4 '.scripts.format |= .+["node_modules/.bin/blade-formatter -w -d resources/views/**/*.blade.php"]' composer.json > "$tmp" && mv "$tmp" composer.json
fi

php artisan install:api -n

composer run format
