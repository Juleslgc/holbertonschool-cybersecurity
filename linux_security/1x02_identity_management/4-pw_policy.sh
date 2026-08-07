#!/bin/bash
apt-get install -y $1
echo "password requisite pam_pwquality.so minlen=12 minclass=3" > "$2"
