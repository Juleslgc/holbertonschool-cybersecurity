#!/bin/bash
awk -F: '$3 >= 1000 {users[$1]=1}' "$1"

while read -r user
do
    for group in disk docker shadow
    do
        if id "$user" | grep -qw "$group"; then
            echo "$user:$group"
        fi
    done
done < <(awk -F: '$3 >= 1000 {print $1}' "$1")
