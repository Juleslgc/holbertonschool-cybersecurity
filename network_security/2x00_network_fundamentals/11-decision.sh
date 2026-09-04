#!/bin/bash
ip route get $1 | awk 'NR==1 {if ($2 ~ /via/) print "REMOTE"; else print "LOCAL"}'
