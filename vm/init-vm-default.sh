#!/bin/bash

rm -rf /var/lib/dbus/machine-id /etc/machine-id

dbus-uuidgen --ensure
ln -sf /var/lib/dbus/machine-id /etc/machine-id

curl -fsSL https://raw.githubusercontent.com/thetredev/dotfiles/main/vm/init-vm-cleanup-ssh.sh | bash

${@}
