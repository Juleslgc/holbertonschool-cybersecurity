#!/bin/bash
sudo apt install squid && sudo systemctl enable squid && cp /etc/squid/squid.conf /etc/squid/squid.conf.bak