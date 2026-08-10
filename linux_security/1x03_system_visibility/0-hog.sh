#!/bin/bash
ps -eo pid,pcpu,comm --sort=-%cpu | sed -n '2p' | awk '{ print $1, $3  }'  
