#!/bin/bash
while IFS=: read -r user password uid gid rest
do
	if [ "$uid" -ge 1000  ]; then
		for group in disk docker shadow
		do
			if getent group "$group" | grep -qE "(:)$user(,|$)"; then
				echo "$user:$group"
			fi
		done
	fi
done < "$1"
