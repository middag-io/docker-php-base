# AGENTS.md — docker-php-base

`middagtec/php-base` — shared PHP-FPM base image with common extensions for MIDDAG WordPress and Moodle projects. Matrix builds for PHP 8.2/8.3/8.4/8.5, production (`-fpm`, OPcache JIT) and development (`-fpm-dev`, + Xdebug) tags, published to Docker Hub via GitHub Actions (`.github/workflows/build.yml`).

**What this repo is NOT:**

- App stacks (`docker-wp-*`, `docker-moodle-*`) CONSUME this image — app config lives there.
- Proxy/network is `infra-traefik`; org doctrine is `docs-middag-ops`; planning in `tool-middag-planning`.

## Git

- Conventional Commits; **never** `Co-Authored-By`.
- Base branch: `main` trunk-based — push to `main` triggers the CI matrix build+push.

## Language

Docs and commits in EN (public repo).

## Quality gates

Green before delivering: local `docker build .` sanity for the touched PHP version; CI matrix (all 4 versions × prod/dev) must pass before the change is real.

## Inherited rules (pointers, do not copy)

- Org doctrine via docs-MCP (alias `ops`) or `docs-middag-ops`.

## NOT in scope / do not do without permission

- Pushing images manually to Docker Hub (`middagtec`) — publishing is CI's job (`DOCKERHUB_USERNAME`/`DOCKERHUB_TOKEN` secrets).
- Dropping a PHP version tag or changing tag semantics — consumers pin these tags.

## Gotchas — READ before touching

1. Everything in `config/` (healthcheck, `opcache.ini`, `xdebug.ini`) is baked into the image — a change here ripples into EVERY consumer stack on their next pull.
2. `latest` follows `8.4-fpm` — bumping the default version is a consumer-visible change, not a housekeeping edit.
