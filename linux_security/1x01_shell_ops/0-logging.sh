#!/bin/bash
if [ -z "$1" ]; then
    commande_bruyante &>/dev/null
    exit 0
fi
exec &> "$1" && echo "Starting Task" && echo "Doing Work" && echo "Error: Work Failed" >&2
