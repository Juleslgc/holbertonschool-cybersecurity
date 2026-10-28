#!/bin/bash

# Disable Telnet
disable_telnet() {
    local INETD_CONFIG="/etc/inetd.conf"

    log "Checking Telnet configuration"

    if [ "$EUID" -ne 0 ]; then
        log "ERROR: Run this script as root"
        return 1
    fi

    if [ ! -f "$INETD_CONFIG" ]; then
        log "ERROR: $INETD_CONFIG not found"
        return 1
    fi

    if grep -qiE '^[[:space:]]*telnet[[:space:]]' "$INETD_CONFIG"; then
        sed -i -E \
            '/^[[:space:]]*telnet[[:space:]]/I s/^/# Disabled by clean.sh: /' \
            "$INETD_CONFIG"

        if grep -qiE '^[[:space:]]*telnet[[:space:]]' "$INETD_CONFIG"; then
            log "ERROR: Failed to disable Telnet"
            return 1
        fi

        log "Telnet entry disabled in inetd.conf"
    else
        log "No active Telnet entry found"
    fi

    return 0
}

# Configuration
SSHD_CONFIG="/etc/ssh/sshd_config"
SSH_CONFIG_DIR="/etc/ssh/sshd_config.d"

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

harden_ssh() {

	log "Starting SSH hardening"

	# Vérifier les droits root
    	if [ "$EUID" -ne 0 ]; then
        	log "ERROR: Run this script as root"
        	return 1
    	fi

	if [ ! -f "$SSHD_CONFIG" ]; then
		log "ERROR: SSH config not found"
		return 1
	fi

	# Save current config
	if ! cp -p "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"; then
		log "ERROR: Backup failed"
		return 1
	fi

	# Check for additional files in the `Include` directive within the `sshd_config` file.
	if compgen -G "$SSH_CONFIG_DIR/*.conf" > /dev/null; then
    		log "Additional SSH configuration files found"
		
    		if grep -qiE \
        		'^[[:space:]]*(PasswordAuthentication[[:space:]]+yes|PubkeyAuthentication[[:space:]]+no|PermitRootLogin[[:space:]]+yes)' "$SSH_CONFIG_DIR"/*.conf; then
			log "Insecure SSH settings found. Correcting configuration"

        		sed -i -E \
            			's/^[[:space:]]*PasswordAuthentication[[:space:]]+.*/PasswordAuthentication no/I;
             			s/^[[:space:]]*PubkeyAuthentication[[:space:]]+.*/PubkeyAuthentication yes/I;
             			s/^[[:space:]]*PermitRootLogin[[:space:]]+.*/PermitRootLogin no/I' "$SSH_CONFIG_DIR"/*.conf

    		else
        		log "No insecure SSH settings found"
    		fi
	else
		log "No additional SSH configuration files found"
	fi

	# Delete old configurations and add the new configuration
	sed -i -E \
    '/^[[:space:]]*#?[[:space:]]*(PasswordAuthentication|PubkeyAuthentication|PermitRootLogin)[[:space:]]/Id' "$SSHD_CONFIG"
	
	# Add the new configuration
	echo "PasswordAuthentication no" >> "$SSHD_CONFIG"
    	echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
    	echo "PermitRootLogin no" >> "$SSHD_CONFIG"

	# Check the configuration
	if ! sshd -t -f "$SSHD_CONFIG"; then
        	log "ERROR: Invalid SSH configuration"
		if ! cp -p "${SSHD_CONFIG}.bak" "$SSHD_CONFIG"; then
        		log "ERROR: Failed to restore SSH configuration"
        		return 1
    		fi
        	return 1
    	fi

	# Check the value correct
	SSH_SETTING=$(sshd -T -f "$SSHD_CONFIG" | grep -E '^(passwordauthentication|pubkeyauthentication|permitrootlogin) ')
	if [ "$SSH_SETTING" = "$(printf '%s\n' 'passwordauthentication no' 'pubkeyauthentication yes' 'permitrootlogin no')" ]; then
		log "SSH settings are secure"
	else
		log "ERROR: SSH settings are incorrect"
		log "$SSH_SETTING"
		if ! cp -p "${SSHD_CONFIG}.bak" "$SSHD_CONFIG"; then
        		log "ERROR: Failed to restore SSH configuration"
        		return 1
    		fi
		return 1
	fi

    	log "SSH hardening completed"
    	return 0
}

# Execute hardening functions
harden_ssh
disable_telnet
