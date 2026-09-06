#!/bin/bash
dig $1 +trace | grep 'Received' | sed -n '2p' | awk '{print $6}' | cut -d'#' -f1 
