#!/bin/bash
if sudo squid -k parse; then sudo squid -k reconfigure; else sudo journalctl -u squid -p err -e; exit 1; fi