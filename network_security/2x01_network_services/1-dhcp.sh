#!/bin/bash
nmcli | grep 'servers' | awk -F: '{print $2}'
