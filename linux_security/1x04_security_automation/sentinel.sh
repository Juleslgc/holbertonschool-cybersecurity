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

log() {
	timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    echo "{\"timestamp\":\"$timestamp\",\"component\":\"$1\",\"target\":\"$2\",\"status\":\"$3\",\"details\":\"$4\"}" >> /var/log/sentinel.log
}

check_services() {
for svc in "${SERVICES[@]}"
do
	if pgrep -f "$svc"; then
		log "SERVICES" "$svc" "OK"  "$svc is running"
	else
		if eval "$svc"; then
			log "SERVICES" "$svc" "FIXED" "Restarted $svc"
		else
			log "SERVICES" "$svc" "ALERT" "Failed restarted $svc"
		fi
	fi
done
}

check_integrity() {
for file in "${FILES_TO_WATCH[@]}"
do
	filename=$(basename "$file")
	gold="/var/backups/sentinel/${filename}.gold"

	file_hash=$(md5sum "$file" | awk '{print $1}')
	gold_hash=$(md5sum "$gold" | awk '{print $1}')
	
	if [[ "$file_hash" == "$gold_hash" ]]; then
		log "INTEGRETY" "$file" "OK" "$file integrity verified"
	else
		cp "$gold" "$file"
		log "INTEGRETY" "$file" "FIXED" "Restored $file"
	fi
done
}

check_ports() {
    for port in $(ss -lnt | awk 'NR > 1 {split($4, a, ":"); print a[length(a)]}')
    do
        allowed=false

        for ports in "${ALLOWED_PORTS[@]}"
        do
            if [ "$ports" -eq "$port" ]; then
                allowed=true
                break
            fi
        done

        if [ "$allowed" = false ]; then
            pid=$(lsof -t -i :"$port")

            if [ -n "$pid" ]; then
                kill "$pid"
                log "PORTS" "$port" "ALERT" "Killed rogue process on port $port"
            fi
        fi
    done
}
