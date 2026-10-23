#!/bin/bash
sudo awk '{print $7}' /var/log/squid/access.log | sort | uniq -c | sort -rn | head -10