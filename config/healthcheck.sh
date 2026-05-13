#!/bin/sh
# PHP-FPM health check via ping endpoint
# Uses cgi-fcgi if available, falls back to checking the process
set -e

FCGI_CONNECT="${FCGI_CONNECT:-127.0.0.1:9000}"

if command -v cgi-fcgi >/dev/null 2>&1; then
    SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
        cgi-fcgi -bind -connect "$FCGI_CONNECT" 2>/dev/null | grep -q "pong"
else
    php-fpm -t 2>/dev/null
fi
