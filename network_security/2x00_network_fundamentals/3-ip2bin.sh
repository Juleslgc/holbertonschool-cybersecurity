#!/bin/bash
printf "%08d.%08d.%08d.%08d\n" "$(echo "obase=2;$(echo "$1" | cut -d. -f1)" | bc)" "$(echo "obase=2;$(echo "$1" | cut -d. -f2)" | bc)" "$(echo "obase=2;$(echo "$1" | cut -d. -f3)" | bc)" "$(echo "obase=2;$(echo "$1" | cut -d. -f4)" | bc)"
