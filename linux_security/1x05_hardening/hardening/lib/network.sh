#!/bin/bash

harden_network() {

        log "Starting network hardening"

        # N-01 + N-02
        if ! configure_firewall; then
                log "ERROR: Firewall configuration failed"
                return 1
        fi

        # N-03
        if ! configure_kernel; then
                log "ERROR: Kernel configuration failed"
                return 1
        fi

        log "Network hardening completed"

        return 0
}


configure_firewall() {

        log "Configuring firewall policy"

        mkdir -p "$FIREWALL_DIR"

        cat > "$FIREWALL_RULES" <<EOF
DEFAULT_INPUT=$DEFAULT_INPUT
DEFAULT_OUTPUT=$DEFAULT_OUTPUT
ALLOW_TCP=$SSH_PORT
EOF

        if [ "$ALLOW_HTTP" = "true" ]; then
                echo "ALLOW_TCP=80" >> "$FIREWALL_RULES"
        fi

        if [ "$ALLOW_HTTPS" = "true" ]; then
                echo "ALLOW_TCP=443" >> "$FIREWALL_RULES"
        fi

        chmod 600 "$FIREWALL_RULES"

        log "Firewall policy written to $FIREWALL_RULES"

        return 0
}


harden_kernel() {

        log "Configuring persistent kernel parameters"

        # Create sysctl configuration file if it does not exist
        if [ ! -f "$SYSCTL_CONFIG" ]; then
                touch "$SYSCTL_CONFIG"
                log "Created $SYSCTL_CONFIG"
        fi

        # Remove existing definitions
        sed -i '/^[[:space:]]*net\.ipv4\.ip_forward[[:space:]]*=/d' "$SYSCTL_CONFIG"

        sed -i '/^[[:space:]]*net\.ipv4\.icmp_echo_ignore_all[[:space:]]*=/d' "$SYSCTL_CONFIG"

        # Add required values
        echo "net.ipv4.ip_forward=0" >> "$SYSCTL_CONFIG"

        echo "net.ipv4.icmp_echo_ignore_all=1" >> "$SYSCTL_CONFIG"

        log "Kernel parameters configured in $SYSCTL_CONFIG"

        return 0
}
