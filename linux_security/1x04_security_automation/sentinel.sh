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

check_integrity() {
filename=$(basename "$file")
gold="/var/backups/sentinel/${filename}.gold"

file_hash=$(md5sum "$file" | awk '{print $1}')
gold_hash=$(md5sum "$gold" | awk '{print $1}')

if [[ "$file_hash" == "$gold_hash" ]]; then
	logger "OK: $file integrity verified"
else
	cp "$gold" "$file"
	logger "FIXED: Restored $file"
fi
}
