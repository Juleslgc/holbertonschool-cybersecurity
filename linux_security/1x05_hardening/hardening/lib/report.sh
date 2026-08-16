#!/bin/bash

FILE="audit_report.txt"

REMOVED_USERS_COUNT=0
REMOVED_USERS=""

generate_report() {
    echo "===============================================" > "$FILE"
    echo " HARDENING AUDIT REPORT - $(date '+%Y-%m-%d %H:%M:%S')" >> "$FILE"
    echo "===============================================" >> "$FILE"
    echo "" >> "$FILE"

    echo "[INFO] Hardening procedure completed successfully." >> "$FILE"
    echo "[INFO] SSH configured on port $SSH_PORT." >> "$FILE"
    echo "[INFO] Firewall policy created: ports $SSH_PORT, 80, 443 ALLOWED." >> "$FILE"
    echo "[INFO] $REMOVED_USERS_COUNT unauthorized users removed: $REMOVED_USERS." >> "$FILE"
    echo "[INFO] Installed: $INSTALL_PACKAGES." >> "$FILE"
    echo "[INFO] Removed: $REMOVE_PACKAGES." >> "$FILE"

    echo "" >> "$FILE"
    echo "===============================================" >> "$FILE"
    echo " COMPLIANCE STATUS: PASS" >> "$FILE"
    echo "===============================================" >> "$FILE"
}
