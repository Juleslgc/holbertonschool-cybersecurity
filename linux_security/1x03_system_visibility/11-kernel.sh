#!/bin/bash
if [ -f "$1" ]; then
	grep "segfault" "$1"
fi

if [ -f /var/log/message ]; then
	grep "segfault" /var/log/message
fi
