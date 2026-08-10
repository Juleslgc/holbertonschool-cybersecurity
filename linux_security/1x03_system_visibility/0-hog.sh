#!/bin/bash
ps aux --sort=-%cpu | sed -n '2p' | awk '{ print $2, $11, $12 }'
