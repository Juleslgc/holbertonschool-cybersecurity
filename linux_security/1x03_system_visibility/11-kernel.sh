#!/bin/bash
grep -i segfault "$1" 2>/dev/null || grep -i segfault /var/log/messages 2>/dev/null
