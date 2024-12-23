#!/bin/bash

distro=$(. /etc/os-release && echo "$ID")
distro_version=${1:-$(. /etc/os-release && echo "$VERSION_CODENAME")}

apt-get update
apt-get install ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/${distro}/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

mkdir -p /etc/apt/sources.list.d
cat > /etc/apt/sources.list.d/docker.list <<EOF
deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/${distro} ${distro_version} stable
EOF

cat > /etc/modules-load.d/docker.conf <<EOF
br_netfilter
EOF
modprobe br_netfilter

cat > /etc/sysctl.d/99-docker-bridge-nf-call-iptables.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system

apt-get update
apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker --now
