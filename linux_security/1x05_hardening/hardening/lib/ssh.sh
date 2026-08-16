#!/bin/bash

harden_ssh() {
    log "Starting SSH hardening"

    if [ ! -f "$SSHD_CONFIG" ]; then
        log "ERROR: SSH config not found"
        return 1
    fi

    # Delete old configurations
    sed -i '/PasswordAuthentication/d' "$SSHD_CONFIG"
    sed -i '/PubkeyAuthentication/d' "$SSHD_CONFIG"
    sed -i '/PermitRootLogin/d' "$SSHD_CONFIG"

    # Add the new configuration
    echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
    echo "PermitRootLogin no" >> "$SSHD_CONFIG"

    # Check the configuration
    if ! sshd -t -f "$SSHD_CONFIG"; then
        log "ERROR: Invalid SSH configuration"
        return 1
    fi

    log "SSH hardening completed"
    return 0
}
