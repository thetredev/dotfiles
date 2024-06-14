#!/bin/bash

rm -rf /etc/machine-id
dbus-uuidgen --ensure=/etc/machine-id

rm -rf /var/lib/dbus/machine-id
dbus-uuidgen --ensure

rm -rf /etc/ssh/ssh_*_key*
ssh-keygen -A

reboot
