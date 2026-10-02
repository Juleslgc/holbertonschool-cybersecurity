#!/bin/bash
tshark -r "$1" -Y http.request -T fields -e http.file_data | xxd -r -p | grep -oE '(^|&)(password|pass|pwd)=[^&]*' | cut -d= -f2
