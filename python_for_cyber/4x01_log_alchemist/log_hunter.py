#!/usr/bin/env python3

import argparse
import re

# Pre-compile Apache regex
APACHE_PATETERN = re.compile(
    r'(?P<ip>\S+)\s+\S+\s+\S+\s+'
    r'\[(?P<date>[^\]]+)\]\s+'
    r'"(?P<method>\S+)\s+'
    r'(?P<path>\S+)\s+[^"]+"\s+'
    r'(?P<status>\d{3})\s+'
    r'(?P<size>\d+|-)'
)


def read_stream(file_path: str):
    """Read a file one line at a time using a generator"""
    try:
        with open(file_path, "r") as file:
            for line in file:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")


def parse_apache_line(line: str) -> dict:
    match = re.search(APACHE_PATETERN, line)

    if match:
        return match.groupdict()

    return None


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to the lof file")

    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    apache_count = 0
    syslog_count = 0

    for line in read_stream(args.file):
        result = parse_apache_line(line)

    if result:
        apache_count += 1

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {apache_count + syslog_count}")
