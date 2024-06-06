# SSL-enabled Mongo image

Copied from https://github.com/railwayapp-templates/postgres-ssl.

This repository contains the logic to build SSL-enabled Mongo images.

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.app/template/V-1Lmx?referralCode=ys51Xh)

## Why though?

The official Mongo image in Docker hub does not come with SSL baked in.

Since this could pose a problem for applications or services attempting to connect to Mongo services, we decided to
roll our own Mongo image with SSL enabled right out of the box.

## How does it work?

The Dockerfiles contained in this repository start with the official Mongo image as base. Then the `init-ssl.sh`
script is copied into the container to be executed upon initialization.

## Accessing the service

Mongo is launched with the `preferTLS` mode. This means that connections are not required to use TLS and you can
continue to connect to Mongo using the `MONGO_URL` or `MONGO_PRIVATE_URL` variables.

If you would like to use TLS then there are three options:

### 1. Connect without client certificates

Set the `tls` and `tlsAllowInvalidCertificates` (required because of the self-signed server certificate) options when
connecting:

```shell
mongosh --tls --tlsAllowInvalidCertificates "$MONGO_URL"
# or
mongosh "$MONGO_URL/?tls=true&tlsAllowInvalidCertificates=true"
```

### 2. Connect without client certificates but with root CA certificate

When starting up the wrapper script will print the generated root CA key and certificate files. You can use them to
verify the server's certificate and/or generate your own.

Scroll up in the service logs and copy the text starting with `-----BEGIN CERTIFICATE-----` and ending
with `-----END CERTIFICATE-----` to a file named `root.crt`.

You can now verify the server's certificate with the `tlsCAFile` option:

```shell
mongosh --tls --tlsCAFile root.crt "$MONGO_URL"
# or
mongosh "$MONGO_URL/?tls=true&tlsCAFile=root.crt"
```

### 3. Connect with client certificates

Create the `root.crt` file as explained above. From the service logs copy the text starting
with `-----BEGIN PRIVATE KEY-----` and ending
with `-----END PRIVATE KEY-----` to a file named `root.key`.

Generate the client certificates (set the `SSL_CERT_DAYS` environment variable if you want to change the default
certificate expiry of 820 days):

```shell
openssl req -new -nodes -text -out "client.csr" -keyout "client.key" -subj "/CN=localhost"
openssl x509 -req -in "client.csr" -text -out "client.crt" -CA "root.crt" -CAkey "root.key" -CAcreateserial -days "${SSL_CERT_DAYS:-820}"
cat "client.key" "client.crt" > "client.pem"
```

Use the new `client.pem` file with the `tlsCertificateKeyFile` option when connecting:

```shell
mongosh --tls --tlsCAFile root.crt --tlsCertificateKeyFile client.pem "$MONGO_URL"
# or
mongosh "$MONGO_URL/?tls=true&tlsCAFile=root.crt&tlsCertificateKeyFile=client.pem"
```

## Custom start command

Extend the current start command if you need to add other arguments to mongo:

```shell
wrapper.sh mongod --config=/etc/mongo/mongod.conf --ipv6 --bind_ip=::,0.0.0.0
```

If you need a custom config then be sure to copy the current tls parameters found in [mongod.conf](mongod.conf).

## Cert expiry

By default, the cert expiry is set to 820 days. You can control this by configuring the `SSL_CERT_DAYS` environment
variable as needed.
