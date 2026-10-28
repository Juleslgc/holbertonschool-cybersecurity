#!/bin/bash

# Logging
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

NFT_CONFIG="/etc/nftables.conf"

firewall() {

	# Check for root privileges
	if [ "$EUID" -ne 0 ]; then
		log "ERROR: Run this script as root"
		return 1
	fi

	# Check that nftables is installed
	if ! command -v nft >/dev/null 2>&1; then
		log "ERROR: NFT is not installed"
		return 1
	fi

	# Save current config
	if [[ -f "$NFT_CONFIG" ]]; then
    		if ! cp -p "$NFT_CONFIG" "${NFT_CONFIG}.bak"; then
        		log "ERROR: Backup failed"
        		return 1
    		fi
	else
    		log "ERROR: $NFT_CONFIG does not exist; cannot create a backup."
    		return 1
	fi

	cat << EOF > /etc/nftables.conf
table inet filter {
	chain input {
		type filter hook input priority 0;
		policy drop;
		
		iifname "lo" accept
		ct state invalid drop
		ct state established,related accept
		
		ip protocol icmp accept
		udp dport 51820 accept
		ip saddr 10.99.0.10 tcp dport 22 accept

		ip saddr { 10.99.0.21, 10.99.0.22 } tcp dport 21 accept
	}
	chain forward {
		type filter hook forward priority 0;
		policy drop;
		
		ct state invalid drop
		ct state established,related accept
		
		
		# FTP: Secure FTP access via VPN
		ip saddr { 10.99.0.21, 10.99.0.22 } ip daddr 192.168.1.30 tcp dport 21 accept

		# Application: reverse proxy to application server
		ip saddr 192.168.1.10 ip daddr 192.168.1.20 tcp dport 8080 accept

		# Database: application only
		ip saddr 192.168.1.20 ip daddr 192.168.1.50 tcp dport 3306 accept

		# Explicitly prohibit Finance VPN access to the database
		ip saddr { 10.99.0.21, 10.99.0.22 } ip daddr 192.168.1.50 tcp dport 3306 drop

		# Explicitly prohibit Internet access to the database
		ip daddr 192.168.1.50 tcp dport 3306 drop
	}
	chain output {
		type filter hook output priority 0;
		policy accept;
		
		oifname "lo" accept
		ct state invalid drop
		ct state established,related accept
	}		
}	
EOF

	if nft -c -f "$NFT_CONFIG"; then
    		log "Valid nftables configuration."
    		log "Rules were not applied."
	else
    		log "ERROR: Syntax error in the configuration."

    		if ! cp -p "${NFT_CONFIG}.bak" "$NFT_CONFIG"; then
        		log "ERROR: Failed to restore NFT configuration."
    		else
        		log "Previous configuration restored."
    		fi

    		return 1
	fi
}
firewall
