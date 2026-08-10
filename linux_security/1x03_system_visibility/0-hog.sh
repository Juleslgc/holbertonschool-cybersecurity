#!/bin/bash
ps -eo pid,comm,pcpu --sort=-%cpu | sed -n '2p' | awk '{ print $1, $2  }'  
