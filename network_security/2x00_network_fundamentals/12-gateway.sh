#!/bin/bash
ip route get $1 | grep default | awk '{print $3}'
