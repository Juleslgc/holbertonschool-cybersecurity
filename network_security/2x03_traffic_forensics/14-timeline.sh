#!/bin/bash
tshark -r "$1" -Y "ip.addr == 10.10.10.50" -T fields -e frame.time | awk 'NR==1 {first=$0} {last=$0} END {print first; print last}'
