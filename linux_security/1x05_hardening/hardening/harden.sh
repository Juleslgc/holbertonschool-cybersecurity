#!/bin/bash

if [ "$EUID" -ne 0 ]; then
        echo "ERROR: script must be run as root" >&2
        exit 1
fi

log() {
	echo "$(date -u '+%FT%TZ') $1" >> /var/log/hardening.log
}

source config/harden.cfg
source lib/network.sh
source lib/ssh.sh
source lib/identity.sh
source lib/system.sh

log "Hardening framework initialized"

if ! configure_network; then
        log "ERROR: Network hardening failed"
        exit 1
fi

if ! configure_ssh; then
        log "ERROR: SSH hardening failed"
        exit 1
fi

if ! configure_identity; then
        log "ERROR: Identity hardening failed"
        exit 1
fi

if ! configure_system; then
        log "ERROR: System hardening failed"
        exit 1
fi

log "Hardening completed"
