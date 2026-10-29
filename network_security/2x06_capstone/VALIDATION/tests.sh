
#!/bin/bash

TOTAL=0
PASSED=0

check() {
    TOTAL=$((TOTAL + 1))
    if eval "$2"; then
        echo "[PASS] $1"
        PASSED=$((PASSED + 1))
    else
        echo "[FAIL] $1"
    fi
}

# Firewall
check "Firewall default INPUT policy is DROP" "nft list chain inet filter input 2>/dev/null | grep -q 'policy drop'"

check "Firewall default FORWARD policy is DROP" "nft list chain inet filter forward 2>/dev/null | grep -q 'policy drop'"

check "Firewall allows WireGuard UDP 51820" "nft list ruleset 2>/dev/null | grep -q 'udp dport 51820 accept'"

check "Firewall allows SSH from admin VPN" "nft list ruleset 2>/dev/null | grep -Eq 'ip saddr 10\.99\.0\.10.*tcp dport 22 accept'"

# SSH
check "SSH is running" "systemctl is-active --quiet ssh"

check "SSH root login disabled" "sshd -T 2>/dev/null | grep -q 'permitrootlogin no'"

check "SSH password authentication disabled" "sshd -T 2>/dev/null | grep -q 'passwordauthentication no'"

check "SSH public-key authentication enabled" "sshd -T 2>/dev/null | grep -q 'pubkeyauthentication yes'"

# VPN
check "VPN interface wg0 is UP" "ip link show wg0 2>/dev/null | grep -q 'UP'"

check "VPN server address is configured" "ip -4 addr show wg0 2>/dev/null | grep -q '10.99.0.1/24'"

# Services
check "FTP anonymous login is disabled" "grep -Eq '^[[:space:]]*anonymous_enable=NO' /etc/vsftpd.conf"

check "Service vsftpd is stopped" "! systemctl is-active --quiet vsftpd"

check "Telnet service is stopped" "! systemctl is-active --quiet telnet"

# Access control
check "User student has sudo access" "id -nG student 2>/dev/null | grep -qw sudo"

# Network
check "IPv4 forwarding is enabled" "test \"$(sysctl -n net.ipv4.ip_forward 2>/dev/null)\" = 1"

check "Default route exists" "ip route show default | grep -q '^default'"

# Result
echo
echo "RESULT: $PASSED/$TOTAL checks passed"
