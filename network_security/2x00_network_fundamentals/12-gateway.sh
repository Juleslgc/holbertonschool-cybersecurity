#!/bin/bash
ip route get $1 | grep "via" | awk '{print $3}'
