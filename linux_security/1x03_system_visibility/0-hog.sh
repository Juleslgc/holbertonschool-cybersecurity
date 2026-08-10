#!/bin/bash
ps -eo pid,comm,%cpu --sort=-%cpu | sed -n '2p' | awk '{ print $1, $2 }'
