#!/bin/bash

set -e

TARGET_DIR="${1}"
DOMAINS="${@:2}"

rm -rf /tmp/certs
mkdir -p /tmp/certs

for domain in ${DOMAINS[@]}; do
    step ca certificate \
        ${domain} \
        "/tmp/certs/${domain}.crt" \
        "/tmp/certs/${domain}.key" \
        --provisioner=acme
done

rm -rf ${TARGET_DIR}/*{.crt,.key}
mv /tmp/certs/*{.crt,.key} ${TARGET_DIR}
rm -rf /tmp/certs
