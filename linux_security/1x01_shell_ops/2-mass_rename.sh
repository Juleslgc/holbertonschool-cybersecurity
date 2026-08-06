#!/bin/bash
find "$1"  -name "*.log" -maxdepth 1 -print0 | xargs -0 -I{} mv {} {}.old
