# Laravel Project Config

This repository provides a single setup script that applies opinionated Laravel tooling and CI defaults to an existing Laravel application. It downloads configuration files, installs dev dependencies, and sets up formatting/static analysis.

## Quick Start
Run from the root of an existing Laravel project:

```bash
curl -fsSL https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/setup.sh | bash
```

Or clone this repo and run locally:

```bash
bash setup.sh
```

You will be prompted to choose between API-only setup (no Node.js tooling) or a full app setup.

Non-interactive usage (for CI or scripting) can set the project type explicitly:

```bash
PROJECT_TYPE=1 curl -fsSL https://raw.githubusercontent.com/harrymahardhika/laravel-project-config/master/setup.sh | bash
```

If you are running from a local clone, you can point the script at local files:

```bash
BASE_DIR=/absolute/path/to/laravel-project-config bash setup.sh
```

## What the Script Does
- Replaces common config files: `.editorconfig`, `.gitignore`, `.env.gitlab-ci`, `.gitlab-ci.yml`, `.github/workflows/test.yml`, `phpstan.neon`, `rector.php`, `pint.json`, `.bladeformatterrc.json`, `.prettierrc.json`.
- Installs dev tools: Laravel Pint, Larastan, Pest, IDE Helper, Prettier, Blade Formatter (full app only).
- Ensures common directories exist: `app/Domains` (with `.gitkeep`) and `lang`.
- Adds or updates Composer scripts for formatting and PHPStan.

## Requirements
- PHP + Composer
- Node.js + pnpm (full app only)
- A Laravel project with `artisan` in the current directory

## Notes
- The script overwrites files listed above. Commit or back up changes before running.
- CI configuration assumes PostgreSQL and PHP 8.3 (GitLab + GitHub Actions templates are provided).
