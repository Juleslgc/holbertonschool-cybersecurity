#!/bin/bash
while  IFS=: read  -r f1 f2 f3 f4 f5 f6 f7
 do  
	 if [ "$f3" -eq 0  ]; then
		 echo "$f1"
	 fi
done  <  "$1"
