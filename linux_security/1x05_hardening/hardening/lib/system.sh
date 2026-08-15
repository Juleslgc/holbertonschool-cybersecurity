#!/bin/bash

configure_system() {

        log "Starting system hardening"

        if ! update_system; then
                log "ERROR: System update failed"
                return 1
        fi

        if ! remove_bloatware; then
                log "ERROR: Bloatware removal failed"
                return 1
        fi

        if ! install_security_tools; then
                log "ERROR: Security tools installation failed"
                return 1
        fi

        log "System hardening completed"

        return 0
}

update_system() {

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


        log "System update completed"

        return 0
}

remove_bloatware() {

        log "Removing unwanted packages"

        if DEBIAN_FRONTEND=noninteractive apt-get remove -y $REMOVE_PACKAGES; then
                log "Unwanted packages removed"
                return 0
        fi

        log "ERROR: Failed to remove unwanted packages"

        return 1
}

install_security_tools() {

        log "Installing security tools"

        if DEBIAN_FRONTEND=noninteractive apt-get install -y $INSTALL_PACKAGES; then
                log "Security tools installed"
                return 0
        fi

        log "ERROR: Failed to install security tools"

        return 1
}
