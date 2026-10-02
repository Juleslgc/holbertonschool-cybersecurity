#!/bin/bash
tshark -r "$1" -Y "tcp contains \"uid=0\" || tcp contains \"root\"" -T fields -e tcp.port | cut -d, -f2 | sort -u
