# middagtec/php-base

Shared PHP 8.4-FPM base image with common extensions for WordPress and Moodle projects.

## Tags

| Tag | Description |
|-----|-------------|
| `8.4-fpm`, `latest` | Production: PHP 8.4-FPM with all extensions, OPcache JIT enabled |
| `8.4-fpm-dev` | Development: production + Xdebug, OPcache timestamp validation |

## Extensions

### Core (built-in)

bcmath, curl, dom, exif, gd (freetype + jpeg + webp + avif), gmp, intl, ldap,
mbstring, mysqli, opcache, pdo_mysql, pdo_pgsql, pgsql, soap, sodium, xml, zip

### PECL

redis, decimal

### Dev only (8.4-fpm-dev)

xdebug

## Usage

```dockerfile
# WordPress project
FROM middagtec/php-base:8.4-fpm AS production
COPY --from=builder /build/ /var/www/html/
COPY docker/wordpress/php.ini /usr/local/etc/php/conf.d/app.ini

# Moodle project
FROM middagtec/php-base:8.4-fpm AS production
COPY --from=builder /build/ /var/www/html/
COPY docker/moodle/php.ini /usr/local/etc/php/conf.d/app.ini
```

### Development

```dockerfile
FROM middagtec/php-base:8.4-fpm-dev AS development
COPY docker/app/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini
```

## OPcache defaults

The image ships sensible OPcache defaults in `opcache-defaults.ini`:

- 256 MB memory, 16 MB interned strings
- 20,000 max accelerated files
- JIT tracing mode with 128 MB buffer
- `validate_timestamps = 0` (production)

Override by mounting or copying your own `.ini` file with higher priority (e.g., `zz-app.ini`).

The dev tag sets `validate_timestamps = 1` automatically.

## Xdebug defaults (dev tag)

- Mode: `debug`
- Start with request: `trigger`
- Client host: `host.docker.internal`
- Port: `9003`
- IDE key: `PHPSTORM`

Override with your own `xdebug.ini`.

## System tools

- `mariadb-client` (mysql CLI)
- `redis-tools` (redis-cli)

## CI/CD

GitHub Actions workflow builds and pushes both tags on every push to `main` that changes `Dockerfile`, `config/`, or the workflow file.

### Docker Hub secrets required

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Docker Hub username (`middagtec`) |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

## Building locally

```bash
# Production
docker build --target production -t middagtec/php-base:8.4-fpm .

# Development
docker build --target development -t middagtec/php-base:8.4-fpm-dev .
```
