#!/bin/bash
cat "$1" | awk -F: '$2~/^\$1\$/ {print $1}'
