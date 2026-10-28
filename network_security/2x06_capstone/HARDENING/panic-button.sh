#!/bin/bash
BACKUP="/root/nftables-backup.rules"

# Save current rules
nft list rules > "$BACKUP"

# Restore the rules after 60 seconds and restart SSH
(sleep 60; nft -f "$BACKUP"; service ssh restart) &
echo "Rollback scheduled in 60 seconds."
echo "The firewall rules will be restored and SSH will be restarted."
