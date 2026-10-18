#!/bin/bash
curl -x http://proxy_ip:3128 -o /dev/null -s -w "403" http://malware.com