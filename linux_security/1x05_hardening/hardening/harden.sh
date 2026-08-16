#!/bin/bash

if [ "$EUID" -ne 0 ]; then
        echo "ERROR: script must be run as root" >&2
        exit 1
fi

log() {
	echo "$(date -u '+%FT%TZ') $1" >> /var/log/hardening.log
}

source config/harden.cfg
source lib/logging.sh
source lib/network.sh
source lib/ssh.sh
source lib/identity.sh
source lib/system.sh
source lib/report.sh

REPORT_INFO=()
REPORT_WARN=()
REPORT_ERROR=()

log INFO "Hardening framework initialized"

harden_network
configure_firewall
harden_kernel
harden_ssh
harden_identity
configure_password_policy
configure_lockout
configure_lockout
cleanup_users
lock_root
harden_system
generate_report

log INFO "Hardening procedure completed successfully."
