#!/bin/bash
ps -eo pid,ppid | awk -v pid=$1 '$1==pid { print $2 }'
