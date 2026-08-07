#!/bin/bash
awk -F: '$3 >= 1000 {users[$1]=1}' "$1"

while read -r user
do
    for group in disk docker shadow
    do
        if getent group "$group" | grep -qE "(:|,)$user(,|$)"; then
            echo "$user:$group"
        fi
    done
done < <(awk -F: '$3 >= 1000 {print $1}' "$1")
