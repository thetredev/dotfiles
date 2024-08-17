#!/bin/bash

rm -rf /etc/machine-id
ln -sf /var/lib/dbus/machine-id /etc/machine-id

rm -rf /var/lib/dbus/machine-id
dbus-uuidgen --ensure

curl -fsSL https://raw.githubusercontent.com/thetredev/dotfiles/main/vm/init-vm-cleanup-ssh.sh | bash
poweroff
