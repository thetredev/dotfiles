#!/bin/bash

apt-get update -y
apt-get install -y \
    debian-keyring \
    debian-archive-keyring \
    apt-transport-https curl \
    gnupg2

install -m 0755 -d /etc/apt/keyrings
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
    | gpg --dearmor -o /etc/apt/keyrings/caddy-stable-archive-keyring.gpg
chmod a+r/etc/apt/keyrings/caddy-stable-archive-keyring.gpg

cat > /etc/apt/sources.list.d/caddy-stable.sources <<EOF
Types: deb deb-src
URIs: https://dl.cloudsmith.io/public/caddy/stable/deb/debian/
Suites: any-version
Components: main
Signed-By: /etc/apt/keyrings/caddy-stable-archive-keyring.gpg
EOF

apt-get -y update
apt-get -y install caddy
