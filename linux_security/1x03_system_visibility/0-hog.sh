#!/bin/bash
ps -eo pid,pcpu,comm --sort=-pcpu | sed -n '2p' | awk '{ print $1, $3  }'  
