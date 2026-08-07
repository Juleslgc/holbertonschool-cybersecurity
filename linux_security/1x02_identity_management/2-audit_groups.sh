#!/bin/bash
while IFS=: read -r user password uid gid rest
do
	if [ "$uid" -ge 1000  ]; then
		for group in disk docker shadow
		do
			if awk -F: -v user="$user" -v group="$group" '$1==group && $4~"(^|,)" user "(,|$)"{
				found=1
			}
		END {
			exit !found
		}' /etc/group; then
			echo "$user:$group"
			fi
		done
	fi
done < "$1"
