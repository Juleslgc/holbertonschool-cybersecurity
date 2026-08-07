#!/bin/bash
while  IFS=: read  -r f1 f2 f3 f4 f5 f6 f7; do [ "$f3" -eq 0  ] && echo "$f1"; done  <  "$1"
