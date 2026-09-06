#!/bin/bash
nmcli device show eth0 | grep 'dhcp_server_identifier' | awk -F' = ' '{print $2}'
