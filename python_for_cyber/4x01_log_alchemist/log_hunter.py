#!/usr/bin/env python3

import argparse
import re
from collections.abc import Iterable, Iterator

# Pre-compile Apache regex
APACHE_PATETERN = re.compile(
    r'(?P<ip>\S+)\s+\S+\s+\S+\s+'
    r'\[(?P<date>[^\]]+)\]\s+'
    r'"(?P<method>\S+)\s+'
    r'(?P<path>\S+)\s+[^"]+"\s+'
    r'(?P<status>\d{3})\s+'
    r'(?P<size>\d+|-)'
)

# Pre-complice Syslog regex.
SYSLOG_PATTERN = re.compile(
    r'^(?P<date>[A-Z][a-z]{2}\s+\d{1,2}\s+\d{2}:\d{2}:\d{2})\s+'
    r'(?P<host>\S+)\s+'
    r'(?P<process>\S+):\s+'
    r'(?P<message>.+)$'
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


def parse_syslog_line(line: str) -> dict:
    match = re.search(SYSLOG_PATTERN, line)

    if match:
        return match.groupdict()

    return None


class LogEntry:
    def __init__(self, ip="", timestamp="",
                 service="", message="",
                 raw_line="", method="",
                 path="", status=0, user_agent=""):

        self.ip = ip
        self.timestamp = timestamp
        self.service = service
        self.message = message
        self.raw_line = raw_line

        # Attributes for apache logs
        self.method = method
        self.path = path
        self.status = status
        self.user_agent = user_agent


def normalize_entry(parsed_dict, log_type, raw_line='') -> LogEntry:
    if log_type == "apache":
        return LogEntry(
            ip=parsed_dict.get("ip", ""),
            timestamp=parsed_dict.get("date", ""),
            service="http",
            message=(
                f'{parsed_dict.get("method", "")}'
                f'{parsed_dict.get("path", "")} '
                f'{parsed_dict.get("status", "")}'),
            raw_line=raw_line,
            method=parsed_dict.get("method", ""),
            path=parsed_dict.get("path", ""),
            status=int(parsed_dict.get("status", 0)),
            user_agent=parsed_dict.get("user_agent", "")
        )
    elif log_type == "syslog":
        message = parsed_dict.get("message", "")

        # Search IPv4 address in the message
        ip_match = re.search(
            r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
            message
        )

        ip = ip_match.group(0) if ip_match else ""

        return LogEntry(
            ip=ip,
            timestamp=parsed_dict.get("date", ""),
            service="ssh",
            message=message,
            raw_line=raw_line
        )
    return None


def filter_logs(stream: Iterable[LogEntry],
                status_codes=[404, 500]) -> Iterator[LogEntry]:
    for entry in stream:
        status = getattr(entry, "status", None)

        if status in status_codes:
            yield entry


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to the lof file")

    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    apache_count = 0
    syslog_count = 0
    entries = []

    for line in read_stream(args.file):
        result = parse_apache_line(line)

        if result:
            entry = normalize_entry(result, "apache", line.rstrip("\n"))
            entries.append(entry)
            apache_count += 1

        else:
            result = parse_syslog_line(line)
            if result:
                entry = normalize_entry(result, "syslog", line.rstrip("\n"))
                entries.append(entry)
                syslog_count += 1

    print("--- Parsing ---")
    print(f"[*] Apache lines:  {apache_count}")
    print(f"[*] Syslog lines:  {syslog_count}")
    print(f"[*] Total parsed:  {len(entries)}")

    if entries:
        sample = next(
            (entry for entry in entries if entry.service == "http"),
            entries[0]
        )

        print("[*] Sample entry:")
        print(
            f"    ip={sample.ip} | "
            f"service={sample.service} | "
            f"status={sample.status} | "
            f"path={sample.path}"
        )

    print("--- Filtering ---")
    suspicious_entries = list(filter_logs(entries))
    print(f"[*] Suspicious (404, 500): {len(suspicious_entries)}")
