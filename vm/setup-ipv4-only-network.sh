#!/bin/bash

set -x


DNS_NAMESERVERS=(
    "10.0.2.252"
    "10.0.2.253"
)



hostname="${1}"
domain="${2}"
address="${3}"
gateway="${4}"



# set hostname
chattr -i /etc/hosts
rm -rf /etc/hosts

echo -e "127.0.0.1\t\tlocalhost" > /etc/hosts

if [ "${address}" == "dhcp" ]; then
    echo -e "127.0.1.1\t\t${hostname}.${domain}\t\t${hostname}" >> /etc/hosts
else
    address_no_cidr=$(sed 's|/.*||' <<< ${address})
    echo -e "${address_no_cidr}\t\t${hostname}.${domain}\t\t${hostname}" >> /etc/hosts
fi
chattr +i /etc/hosts

chattr -i /etc/hostname
rm -rf /etc/hostname
echo "${hostname}" > /etc/hostname
chattr +i /etc/hostname


# disable & mask systemd-networkd
systemctl disable --now systemd-networkd
systemctl mask systemd-networkd

# disable & mask systemd-resolved
systemctl disable --now systemd-resolved
systemctl mask systemd-resolved


# configure loopback device via ifupdown2
chattr -i /etc/network/interfaces

rm -rf /etc/network/interfaces
cat > /etc/network/interfaces <<EOF
# The loopback network interface
auto lo
iface lo inet loopback

EOF


# get primary network interface
primary_interface=$(ip link show | grep -v 'link/' | grep -v 'lo:' | head -1 | cut -d ' ' -f 2 | tr -d ':')


# configure primary network interface via ifupdown2
if [ "${address}" == "dhcp" ]; then cat >> /etc/network/interfaces <<EOF
# The primary network interface
auto ${primary_interface}
iface ${primary_interface} inet dhcp

EOF
else cat >> /etc/network/interfaces <<EOF
# The primary network interface
auto ${primary_interface}
iface ${primary_interface} inet static
    address ${address}
    gateway ${gateway}

EOF
fi

cat >> /etc/network/interfaces <<EOF
# Include other ifupdown2 configurations
source /etc/network/interfaces.d/*

EOF
chattr -i /etc/network/interfaces


# create a fresh resolv.conf file
chattr -i /etc/resolv.conf
unlink /etc/resolv.conf
rm -rf /etc/resolv.conf

cat >> /etc/resolv.conf <<EOF
options timeout:1 attempts:5 rotate

$(
    for nameserver in ${DNS_NAMESERVERS[@]}; do
        echo "${nameserver}"
    done
)

domain ${domain}
search ${domain} ${domain}.
EOF
chattr +i /etc/resolv.conf


# force BBR TCP congestion mode
chattr -i /etc/sysctl.d/99-tcp-optimizations.conf
cat > /etc/sysctl.d/99-tcp-optimizations.conf <<EOF
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
EOF
chattr +i /etc/sysctl.d/99-tcp-optimizations.conf
