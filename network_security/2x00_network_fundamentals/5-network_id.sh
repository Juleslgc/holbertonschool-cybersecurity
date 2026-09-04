#!/bin/bash
IFS='.' read -r a b c d <<< "$1"; IFS='.' read -r m1 m2 m3 m4 <<< "$2"; printf "%d.%d.%d.%d" "$((a&m1))" "$((b&m2))" "$((c&m3))" "$((d&m4))"
