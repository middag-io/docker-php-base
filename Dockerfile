# syntax=docker/dockerfile:1
# =============================================================================
# middagtec/php-base — Shared PHP-FPM base image
#
# Build arg:
#   PHP_VERSION  (default: 8.4)
#
# Tags per version:
#   middagtec/php-base:<ver>-fpm       (production)
#   middagtec/php-base:<ver>-fpm-dev   (production + Xdebug)
#
# Usage:
#   FROM middagtec/php-base:8.4-fpm
#   COPY --from=builder /build/ /var/www/html/
# =============================================================================

ARG PHP_VERSION=8.4

# =============================================================================
# Stage 1: production — PHP-FPM with all common extensions
# =============================================================================
FROM php:${PHP_VERSION}-fpm AS production

ARG PHP_VERSION

LABEL maintainer="MIDDAG <paulo@middag.com.br>"
LABEL org.opencontainers.image.source="https://github.com/middag-io/php-base"
LABEL org.opencontainers.image.description="PHP ${PHP_VERSION}-FPM base image with common extensions for WordPress and Moodle"

# System dependencies for PHP extensions + tools
RUN apt-get update && apt-get install -y --no-install-recommends \
        # PHP extension build deps
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libicu-dev \
        libjpeg62-turbo-dev \
        libmpc-dev \
        libonig-dev \
        libpng-dev \
        libsodium-dev \
        libxml2-dev \
        libzip-dev \
        libwebp-dev \
        libavif-dev \
        libgmp-dev \
        libmpdec-dev \
        libpq-dev \
        libldap2-dev \
        libmagickwand-dev \
        # Runtime tools
        ghostscript \
        graphviz \
        mariadb-client \
        redis-tools \
    # GD with full format support
    && docker-php-ext-configure gd \
        --with-freetype \
        --with-jpeg \
        --with-webp \
        --with-avif \
    && docker-php-ext-configure ldap \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath \
        curl \
        dom \
        exif \
        gd \
        gmp \
        intl \
        ldap \
        mbstring \
        mysqli \
        opcache \
        pcntl \
        pdo_mysql \
        pdo_pgsql \
        pgsql \
        soap \
        sodium \
        xml \
        zip \
    # PECL extensions
    && pecl install redis decimal imagick apcu xdebug \
    && docker-php-ext-enable redis decimal imagick apcu \
    && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

# OPcache defaults (projects can override via their own .ini)
COPY config/opcache.ini /usr/local/etc/php/conf.d/opcache-defaults.ini

# PHP-FPM ping/status for health checks
RUN echo "[www]" > /usr/local/etc/php-fpm.d/zz-healthcheck.conf \
    && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-healthcheck.conf \
    && echo "ping.path = /ping" >> /usr/local/etc/php-fpm.d/zz-healthcheck.conf \
    && echo "ping.response = pong" >> /usr/local/etc/php-fpm.d/zz-healthcheck.conf

# Health check script
COPY config/healthcheck.sh /usr/local/bin/healthcheck
RUN chmod +x /usr/local/bin/healthcheck

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD ["healthcheck"]

WORKDIR /var/www/html

# =============================================================================
# Stage 2: development — adds Xdebug (pre-compiled in production stage)
# =============================================================================
FROM production AS development

RUN docker-php-ext-enable xdebug

# Xdebug defaults (projects can override via their own xdebug.ini)
COPY config/xdebug.ini /usr/local/etc/php/conf.d/xdebug-defaults.ini

# OPcache: validate timestamps in dev (pick up file changes without restart)
RUN echo "opcache.validate_timestamps = 1" > /usr/local/etc/php/conf.d/opcache-dev.ini
