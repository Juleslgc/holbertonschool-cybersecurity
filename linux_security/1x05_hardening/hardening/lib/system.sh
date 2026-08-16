#!/bin/bash

harden_system() {
    log "Starting system hardening"

    # System update
    log "Updating package repositories"

    if ! DEBIAN_FRONTEND=noninteractive apt-get update; then
        log "ERROR: apt-get update failed"
        return 1
    fi

    log "Upgrading installed packages"

    if ! DEBIAN_FRONTEND=noninteractive apt-get upgrade -y; then
        log "ERROR: apt-get upgrade failed"
        return 1
    fi

    # Removing unnecessary packages
    log "Removing unwanted packages"

    if ! DEBIAN_FRONTEND=noninteractive apt-get remove -y $REMOVE_PACKAGES; then
        log "ERROR: Failed to remove unwanted packages"
        return 1
    fi

    # Installation of security tools
    log "Installing security tools"

    if ! DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PACKAGES; then
        log "ERROR: Failed to install security tools"
        return 1
    fi

    log "System hardening completed"
    return 0
}
