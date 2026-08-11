#!/bin/bash
ss -ltn4H | awk '{print $4}' | cut -d: -f2 | sort -n
