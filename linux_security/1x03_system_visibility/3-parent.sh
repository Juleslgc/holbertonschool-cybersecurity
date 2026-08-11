#!/bin/bash
ps -p $1 -o pid=,ppid= | tr -s ' ' '\n' | awk 'NR==3 { print }'
