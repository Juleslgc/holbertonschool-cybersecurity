#!/bin/bash
ps -eo pid | awk 'NR >= 2 { print $1 }'
