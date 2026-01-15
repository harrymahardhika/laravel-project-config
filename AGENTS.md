# Repository Guidelines

## Project Structure & Module Organization
This repository is a configuration bundle for Laravel projects. Everything lives at the root:
- `setup.sh`: bootstrap script that fetches the latest config files into a Laravel app.
- `build_helper`: helper script for generating IDE metadata via Artisan.
- `.gitlab-ci.yml`: CI template for PHP 8.3 + Node, running install, build, and tests.
- `.github/workflows/test.yml`: GitHub Actions workflow copied from `test.yaml`.
- `phpstan.neon`, `rector.php`, `pint.json`, `.prettierrc.json`, `.bladeformatterrc.json`, `.editorconfig`: linting/formatting rules.
- `.env.gitlab-ci`: CI environment defaults.
- `gitignore`: baseline ignore file for Laravel projects.

## Build, Test, and Development Commands
These scripts are intended to be run from a Laravel app that consumes this repo:
- `bash setup.sh`: downloads the latest config files and installs dev dependencies (Composer/pnpm). Prompts for API-only vs full app.
- `./build_helper`: runs `php artisan ide-helper:*` for IDE stubs (requires Laravel app + ide-helper).
- `php artisan test`: CI runs this by default (see `.gitlab-ci.yml`).
- `vendor/bin/phpstan analyse`: static analysis (configured in `phpstan.neon`).
- `vendor/bin/pint`: PHP formatting (configured in `pint.json`).
- `pnpm install` + `pnpm run build --if-present`: frontend dependencies and build (full app only).
- `node_modules/.bin/blade-formatter -w -d resources/views/**/*.blade.php`: Blade formatting (full app only).

## Coding Style & Naming Conventions
- Indentation: 4 spaces for PHP; 2 spaces for JS/CSS/Blade/Vue (see `.editorconfig`).
- PHP style: Laravel Pint preset with additional rules (`pint.json`), including `declare(strict_types=1)` and Yoda conditions.
- Frontend formatting: Prettier (`.prettierrc.json`) and Blade Formatter (`.bladeformatterrc.json`) for full apps.

## Testing Guidelines
- CI expects a standard Laravel test suite under `tests/`.
- `php artisan test` is the primary entry point; Pest is installed by `setup.sh`.
- Keep tests fast and deterministic; prefer database tests that use transactions.

## Commit & Pull Request Guidelines
- Commit messages in this repo are short, imperative, and lowercase (e.g., `update setup.sh`).
- PRs should describe which config files changed and the downstream impact on Laravel apps.
- Include before/after examples for formatting rule changes when helpful.

## Security & Configuration Tips
- Treat `.env.gitlab-ci` as a template; do not add secrets.
- Avoid committing credentials or environment-specific values to this repo.
