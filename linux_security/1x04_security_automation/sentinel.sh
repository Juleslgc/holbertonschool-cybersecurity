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
check_services() {
for svc in "${SERVICES[@]}"
do
	if pgrep -f "$svc"; then
		logger "OK: $svc is running"
	else
		if eval "$svc"; then
			logger "FIXED: Restarted $svc"
		else
			logger "Error"
		fi
	fi
done
}
