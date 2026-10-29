#!/bin/bash

# Logging
log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

vpn_setup() {

	# Configuration
	VPN_DIR="/etc/wireguard"

	# Check for root privilege
	if [ "$EUID" -ne 0 ]; then
		log "ERROR: Run this script as root."
		return 1
	fi

	# Check that wireguard is installed
	if ! command -v wg >/dev/null 2>&1; then
		log "Installing Wireguard..."
		apt-get update
		apt-get install -y wireguard
	else
		log "Wireguard is already installed."
	fi

	# Create directory
	if [ ! -d "$VPN_DIR" ]; then
		mkdir -p -m 700 "$VPN_DIR"
		log "Created directory"
	else
		return 1
		log "WARNING: Directory already exists"
	fi

	# Generate server keys
	wg genkey > "${VPN_DIR}/server_private.key"
	wg pubkey < "${VPN_DIR}/server_private.key" > "${VPN_DIR}/server_public.key"

	# Generate administrator keys
	wg genkey > "${VPN_DIR}/admin_private.key"
	wg pubkey < "${VPN_DIR}/admin_private.key" > "${VPN_DIR}/admin_public.key"

	# Generate finance workstation 1 keys
	wg genkey > "${VPN_DIR}/finance1_private.key"
	wg pubkey < "${VPN_DIR}/finance1_private.key" > "${VPN_DIR}/finance1_public.key"

	# Generate finance workstation 2 keys
	wg genkey > "${VPN_DIR}/finance2_private.key"
	wg pubkey < "${VPN_DIR}/finance2_private.key" > "${VPN_DIR}/finance2_public.key"

	# Secure private keys and public keys
	chmod 600 "$VPN_DIR"/*_private.key
	chmod 644 "$VPN_DIR"/*_public.key
	
	# Read key contents for configuration generation 
	SERVER_PRI=$(< "${VPN_DIR}/server_private.key")
	SERVER_PUB=$(< "${VPN_DIR}/server_public.key")
	ADMIN_PRI=$(< "${VPN_DIR}/admin_private.key")
	ADMIN_PUB=$(< "${VPN_DIR}/admin_public.key")
	FIN1_PRI=$(< "${VPN_DIR}/finance1_private.key")
	FIN1_PUB=$(< "${VPN_DIR}/finance1_public.key")
	FIN2_PRI=$(< "${VPN_DIR}/finance2_private.key")
	FIN2_PUB=$(< "${VPN_DIR}/finance2_public.key")
	
	# Create server configuration
	cat << EOF > "${VPN_DIR}/wg0.conf"

[Interface]
Address = 10.99.0.1/24
ListenPort = 51820
PrivateKey = $SERVER_PRI

[Peer]
# Administrateur
PublicKey = $ADMIN_PUB
AllowedIPs = 10.99.0.10/32

[Peer]
# Finance workstation 1
PublicKey = $FIN1_PUB
AllowedIPs = 10.99.0.21/32

[Peer]
# Finance workstation 2
PublicKey = $FIN2_PUB
AllowedIPs = 10.99.0.22/32

EOF

	# Create admin configuration
	cat << EOF > "${VPN_DIR}/admin.conf"

[Interface]
Address = 10.99.0.10/32
PrivateKey = $ADMIN_PRI

[Peer]
PublicKey = $SERVER_PUB
Endpoint = <IP_PUBLIQUE_DU_SERVEUR>:51820
AllowedIPs = 10.99.0.0/24
PersistentKeepalive = 25

EOF

	# Create finance worstation 1 configuration
	cat << EOF > "${VPN_DIR}/finance1.conf"

[Interface]
Address = 10.99.0.21/32
PrivateKey = $FIN1_PRI

[Peer]
PublicKey = $SERVER_PUB
Endpoint = <IP_PUBLIQUE_DU_SERVEUR>:51820
AllowedIPs = 10.99.0.0/24
PersistentKeepalive = 25

EOF

	# Create finance workstation 2 configuration
	cat << EOF > "${VPN_DIR}/finance2.conf"

[Interface]
Address = 10.99.0.22/32
PrivateKey = $FIN2_PRI

[Peer]
PublicKey = $SERVER_PUB
Endpoint = <IP_PUBLIQUE_DU_SERVEUR>:51820
AllowedIPs = 10.99.0.0/24
PersistentKeepalive = 25

EOF

	# Validate the WireGuard configuration
	if ! wg-quick strip "${VPN_DIR}/wg0.conf" >/dev/null; then
    		log "ERROR: Invalid WireGuard configuration."
    		return 1
	fi

	log "Server configuration created and validated."
}
vpn_setup
