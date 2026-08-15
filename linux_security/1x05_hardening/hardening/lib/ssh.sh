#!/bin/bash

configure_ssh() {

        log "Starting SSH hardening"

        if [ ! -f "$SSHD_CONFIG" ]; then
                log "ERROR: $SSHD_CONFIG does not exist"
                return 1
        fi

        # Remove existing directives
        sed -i '/^[[:space:]]*#*[[:space:]]*PasswordAuthentication[[:space:]]/d' "$SSHD_CONFIG"
        sed -i '/^[[:space:]]*#*[[:space:]]*PubkeyAuthentication[[:space:]]/d' "$SSHD_CONFIG"
        sed -i '/^[[:space:]]*#*[[:space:]]*PermitRootLogin[[:space:]]/d' "$SSHD_CONFIG"

        # Add our configuration
        cat >> "$SSHD_CONFIG" <<EOF

# Hardening configuration
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
EOF

        # Validate SSH configuration
        if sshd -t -f "$SSHD_CONFIG"; then
                log "SSH configuration validated successfully"
        else
                log "ERROR: Invalid SSH configuration"
                return 1
        fi

        log "SSH hardening completed"

        return 0
}
