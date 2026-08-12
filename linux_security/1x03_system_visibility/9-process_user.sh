#!/bin/bash
ps -p $1 -o user= | tr -d ' '
