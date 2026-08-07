#!/bin/bash
cat "$1" | awk -F: '$3 < 1000 && $7~/(bash|sh)$/ && $1 != "root" {print $1}'
