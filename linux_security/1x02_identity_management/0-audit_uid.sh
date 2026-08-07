#!/bin/bash
cat "$1" | awk -F: '$3 == 0 {print $1}'
