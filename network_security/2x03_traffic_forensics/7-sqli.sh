#!/bin/bash
tshark -r "$1" -Y "http.request.uri matches \"(?i)(select|union)\"" -T fields -e http.request.uri | sort -u
