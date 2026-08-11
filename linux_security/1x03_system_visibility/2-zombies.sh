#!/bin/bash
ps -Z | awk 'NR >= 2 { print $2 }'
