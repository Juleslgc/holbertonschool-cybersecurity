#!/bin/bash
apt-get install -y $1
sed -i '$a password requisite pam_pwquality.so minlen=12 minclass=3' "$2"
