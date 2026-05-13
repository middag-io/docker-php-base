# middagtec/php-base

Shared PHP-FPM base image with common extensions for WordPress and Moodle projects.

## Tags

Builds for PHP 8.2, 8.3, 8.4, and 8.5.

| Tag                                           | Description                                  |
|-----------------------------------------------|----------------------------------------------|
| `8.4-fpm`, `latest`                           | Production: PHP 8.4-FPM, OPcache JIT enabled |
| `8.4-fpm-dev`                                 | Development: production + Xdebug             |
| `8.2-fpm` / `8.3-fpm` / `8.5-fpm`             | Production for other PHP versions            |
| `8.2-fpm-dev` / `8.3-fpm-dev` / `8.5-fpm-dev` | Development for other PHP versions           |

## Extensions

### Core (built-in)

bcmath, curl, dom, exif, gd (freetype + jpeg + webp + avif), gmp, intl, ldap,
mbstring, mysqli, opcache, pdo_mysql, pdo_pgsql, pgsql, soap, sodium, xml, zip

### PECL

redis, decimal

### Dev only (*-dev tags)

xdebug

## Usage

```dockerfile
# WordPress project
FROM middagtec/php-base:8.4-fpm AS production
COPY --from=builder /build/ /var/www/html/
COPY docker/wordpress/php.ini /usr/local/etc/php/conf.d/app.ini

# Moodle project (PostgreSQL)
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

The dev tags set `validate_timestamps = 1` automatically.

## Xdebug defaults (dev tags)

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

GitHub Actions matrix builds all 4 PHP versions (8.2-8.5) in parallel and pushes
both production and dev tags on every push to `main`.

The `latest` tag always points to `8.4-fpm`.

### Docker Hub secrets required

| Type     | Name                 | Description                       |
|----------|----------------------|-----------------------------------|
| Variable | `DOCKERHUB_USERNAME` | Docker Hub username (`middagtec`) |
| Secret   | `DOCKERHUB_TOKEN`    | Docker Hub access token           |

## Building locally

```bash
# Production (specific version)
docker build --build-arg PHP_VERSION=8.4 --target production -t middagtec/php-base:8.4-fpm .

# Development
docker build --build-arg PHP_VERSION=8.4 --target development -t middagtec/php-base:8.4-fpm-dev .

# All versions
for v in 8.2 8.3 8.4 8.5; do
  docker build --build-arg PHP_VERSION=$v --target production -t middagtec/php-base:$v-fpm .
  docker build --build-arg PHP_VERSION=$v --target development -t middagtec/php-base:$v-fpm-dev .
done
```
