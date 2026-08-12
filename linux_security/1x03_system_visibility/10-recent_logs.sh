#!/bin/bash
awk -v start="$(date -d '30 minutes ago' '+%b %e %H:%M')" '$0 ~ /sshd/ { print }' "$1"
