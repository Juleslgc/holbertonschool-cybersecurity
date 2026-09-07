#!/bin/bash
dig SOA $1 +short | awk '{print $1}'
