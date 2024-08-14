#!/bin/bash

rm -rf /etc/machine-id
dbus-uuidgen --ensure=/etc/machine-id

rm -rf /var/lib/dbus/machine-id
dbus-uuidgen --ensure

curl -fsSL https://raw.githubusercontent.com/thetredev/dotfiles/main/vm/init-vm-cleanup-ssh.sh | bash
poweroff
