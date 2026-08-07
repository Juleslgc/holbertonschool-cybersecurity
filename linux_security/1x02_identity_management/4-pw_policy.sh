#!/bin/bash
apt install "$1"
echo "password requisite pam_pwquality.so minlen=12 minclass=3" > "$2"
