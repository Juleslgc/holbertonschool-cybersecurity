#!/bin/bash
if [ ! -f sentinel.conf ]; then
	exit 1
fi
source sentinel.conf
if [ ! -v SERVICES ]; then
	exit 1
fi
if [ ! -v FILES_TO_WATCH ]; then
	exit 1
fi
