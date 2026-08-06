#!/bin/bash
while read user
do
	if id "$user"
	then
		usermod -L "$user" && echo "User "$user" locked"
	else
		echo "User "$user" not found"
	fi
done < "$1"
