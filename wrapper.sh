#!/bin/bash

SSL_DIR="/etc/mongo"
INIT_SSL_SCRIPT="/usr/local/bin/init-ssl.sh"

# Check if certificates need to be regenerated
if [ "$REGENERATE_CERTS" = "true" ] || [ ! -f "$SSL_DIR/server.pem" ] || [ ! -f "$SSL_DIR/root.pem" ]; then
    echo "Running init-ssl.sh to generate new certificates..."
    bash "$INIT_SSL_SCRIPT"
else
    echo "Certificates already exist and REGENERATE_CERTS is not set to true. Skipping certificate generation."
fi

/usr/local/bin/docker-entrypoint.sh "$@"
