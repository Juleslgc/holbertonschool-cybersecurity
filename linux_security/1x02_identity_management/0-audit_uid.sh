#!/bin/bash
cat "$1" | awk -F: '$3 == 0 && $1 != "root" {print $1}'
