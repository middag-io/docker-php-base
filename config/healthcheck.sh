#!/bin/sh
# PHP-FPM health check: real FastCGI request to the /ping endpoint.
# Requires cgi-fcgi (libfcgi-bin, shipped in the image). Fails when FPM is
# not answering; there is no config-only fallback (php-fpm -t would report
# healthy even with the pool dead).
# Default target is loopback only: the check runs inside the container.
set -eu

FCGI_CONNECT="${FCGI_CONNECT:-127.0.0.1:9000}"

if ! command -v cgi-fcgi >/dev/null 2>&1; then
    echo "healthcheck: cgi-fcgi not found" >&2
    exit 1
fi

if SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET \
    cgi-fcgi -bind -connect "$FCGI_CONNECT" 2>/dev/null | grep -q "pong"; then
    exit 0
fi

echo "healthcheck: no pong from PHP-FPM at $FCGI_CONNECT" >&2
exit 1
