#!/bin/bash
find "$1" -type f ! -name "*.gz" -size +1M -mtime -1 2>/dev/null
