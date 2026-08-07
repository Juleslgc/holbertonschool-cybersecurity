#!/bin/bash
sed -i -e 's/PermitRootLogin yes/PermitRootLogin no/' -e 's/PasswordAuthentication yes/PasswordAuthentication no/' -e 's/PubkeyAuthentication no/PubkeyAuthentication yes' "$1"
if sshd -t "$1"; then
	systemctl reload ssh
fi
