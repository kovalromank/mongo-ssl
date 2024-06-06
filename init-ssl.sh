#!/bin/bash

SSL_DIR="/data/db/certs"

mkdir -p "$SSL_DIR"

# Generate Root CA
openssl req -new -x509 -days "${SSL_CERT_DAYS:-820}" -nodes -text -out "$SSL_DIR/root.crt" -keyout "$SSL_DIR/root.key" -subj "/CN=root-ca" 2>/dev/null
cat "$SSL_DIR/root.key" "$SSL_DIR/root.crt" > "$SSL_DIR/root.pem"

# Generate Server Certificates
openssl req -new -nodes -text -out "$SSL_DIR/server.csr" -keyout "$SSL_DIR/server.key" -subj "/CN=localhost" 2>/dev/null
openssl x509 -req -in "$SSL_DIR/server.csr" -text -out "$SSL_DIR/server.crt" -CA "$SSL_DIR/root.crt" -CAkey "$SSL_DIR/root.key" -CAcreateserial -days "${SSL_CERT_DAYS:-820}" 2>/dev/null
cat "$SSL_DIR/server.key" "$SSL_DIR/server.crt" > "$SSL_DIR/server.pem"

echo "### ROOT CA CERTIFICATE ###"
cat "$SSL_DIR/root.pem"
