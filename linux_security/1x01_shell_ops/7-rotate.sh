#!/bin/bash
if [ ! -d "$1" ]; then
        exit 1
fi

mkdir -p "$1/backups"

find "$1" -type f -name "*.log" | while read file
do
        size=$(stat -c %s "$file")
        name_file=$(basename "$file")

        if [ "$size" -gt 1024 ]; then
                gzip "$file"
                mv "${file}.gz" "$1/backups/"
        else
                echo "Skipping small file: $name_file"
        fi
done
