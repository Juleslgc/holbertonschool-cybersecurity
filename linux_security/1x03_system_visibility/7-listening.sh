#!/bin/bash
ss -ltn4 | awk 'NR>=2 {print $4}' | cut -d: -f2 | sort -n
