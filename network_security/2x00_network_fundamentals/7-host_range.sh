#!/bin/bash
IFS='.' read -r a b c d <<< "$1"; bits=$2; mask=$((0xffffffff << (32-bits))); net=$(( ( (a<<24)|(b<<16)|(c<<8)|d ) & mask )); first=$((net+1)); last=$((net+(2**(32-bits))-2)); printf "%d.%d.%d.%d - %d.%d.%d.%d" $((first>>24&255)) $((first>>16&255)) $((first>>8&255)) $((first&255)) $((last>>24&255)) $((last>>16&255)) $((last>>8&255)) $((last&255))
