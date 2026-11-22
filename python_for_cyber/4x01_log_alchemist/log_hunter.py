#!/usr/bin/env python3

import argparse
import re
from collections.abc import Iterable, Iterator
from collections import Counter, defaultdict, deque
from datetime import datetime, timezone
import json
from dataclasses import asdict, is_dataclass

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

GEOIP_DB = {
    '1.2.3.4': 'US',
    '5.6.7.8': 'RU'
    }

BLACKLIST = {
    "10.0.0.1",
    "192.168.1.66"
}

SQLI_PATTERNS = [
    re.compile(r"union\s+select", re.IGNORECASE),
    re.compile(r"'\s*or\s+1\s*=\s*1", re.IGNORECASE),
    re.compile(r"--"),
]

XSS_PATTERNS = [
    re.compile(r"<\s*script\b", re.IGNORECASE),
    re.compile(r"javascript\s*:", re.IGNORECASE),
    re.compile(r"\bonload\s*=", re.IGNORECASE),
    re.compile(r"\bonerror\s*=", re.IGNORECASE)
]


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
                 path="", status=0,
                 user_agent="", size=0,
                 source="", attack_type=""):

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
        self.size = size
        self.source = source
        self.attack_type = attack_type


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
            user_agent=parsed_dict.get("user_agent", ""),
            size=parsed_dict.get("size", 0),
            source=parsed_dict.get("source", ""),
            attack_type=parsed_dict.get("attack_type", "")
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


def enrich_ip(log_entry):
    log_entry.country = GEOIP_DB.get(log_entry.ip, "UNKNOWN")
    return log_entry


def analyze_user_agent(log_entry):
    signatures = ["sqlmap", "nikto", "curl", "python"]
    fields = [
        getattr(log_entry, "user_agent", ""),
        getattr(log_entry, "message", ""),
        getattr(log_entry, "raw_line", "")
    ]

    content = " ".join(fields).lower()

    log_entry.is_bot = any(
        signature in content
        for signature in signatures
    )
    return log_entry


def check_threat_intel(log_entry):
    if log_entry.ip in BLACKLIST:
        log_entry.alert_level = "HIGH"
    else:
        log_entry.alert_level = "LOW"

    return log_entry


def detect_sqli(log_entry):
    path = getattr(log_entry, "path", "")
    message = getattr(log_entry, "message", "")

    content = f"{path} {message}"

    for pattern in SQLI_PATTERNS:
        if pattern.search(content):
            log_entry.attack_type = "SQLi"
            return log_entry
    return log_entry


def detect_xss(log_entry):
    path = getattr(log_entry, "path", "")

    for pattern in XSS_PATTERNS:
        if pattern.search(path):
            if getattr(log_entry, "attack_type", "") != "SQLi":
                log_entry.attack_type = "XSS"
            break
    return log_entry


def detect_bruteforce(entries):
    failures = Counter()

    for entry in entries:
        ip = getattr(entry, "ip", "")

        if not ip:
            continue

        if str(getattr(entry, "status", None)) == "401":
            failures[ip] += 1
        elif "Failed password" in getattr(entry, "message", ""):
            failures[ip] += 1

    for ip, count in failures.items():
        if count > 5:
            yield {
                "ip": ip,
                "count": count,
                "alert_type": "BRUTE_FORCE"
            }


def parse_timestamp(timestamp):
    formats = [
        "%d/%b/%Y:%H:%M:%S %z",  # Apache
        "%b %d %H:%M:%S",        # Syslog
    ]

    for fmt in formats:
        try:
            result = datetime.strptime(timestamp, fmt)

            if fmt == "%b %d %H:%M:%S":
                result = result.replace(year=datetime.now().year)

            return result

        except ValueError:
            continue

    return None


def detect_burst(entries, threshold=10, window_seconds=60):
    requests_by_ip = defaultdict(deque)
    alerted_ips = set()

    for entry in entries:
        ip = getattr(entry, "ip", "")

        if not ip:
            continue

        timestamp = getattr(entry, "timestamp", "")

        if isinstance(timestamp, datetime):
            current_time = timestamp
        else:
            current_time = parse_timestamp(timestamp)

        if current_time is None:
            continue

        if current_time.tzinfo is not None:
            current_time = current_time.astimezone(
                timezone.utc
            ).replace(tzinfo=None)

        timestamps = requests_by_ip[ip]

        timestamps.append(current_time)

        while timestamps and (
            current_time - timestamps[0]
        ).total_seconds() > window_seconds:
            timestamps.popleft()

        if len(timestamps) >= threshold and ip not in alerted_ips:
            alerted_ips.add(ip)

            yield {
                "ip": ip,
                "count": len(timestamps),
                "window": window_seconds,
                "alert_type": "BURST"
            }


def correlate_events(entries):
    states = defaultdict(set)

    for entry in entries:
        ip = getattr(entry, "ip", "")

        if not ip:
            continue

        if str(getattr(entry, "status", None)) == "404":
            states[ip].add("scanner")

        if getattr(entry, "attack_type", "") == "SQLi":
            states[ip].add("sqli")

        if "scanner" in states[ip] and "sqli" in states[ip]:
            yield {
                "ip": ip,
                "stages": ["scanner", "sqli"],
                "alert_type": "CRITICAL INCIDENT"
            }

            states[ip].clear()


def export_report(alerts, filename, format="json"):
    if format.lower() != "json":
        raise ValueError("Unsupported report format")

    report_data = []

    for alert in alerts:
        if isinstance(alert, dict):
            report_data.append(alert)

        elif is_dataclass(alert):
            report_data.append(asdict(alert))

        elif hasattr(alert, "__dict__"):
            report_data.append(vars(alert))

        else:
            raise TypeError(f"Unsupported alert type: {type(alert).__name__}")

    with open(filename, "w", encoding="utf-8") as file:
        json.dump(
            report_data,
            file,
            indent=2,
            ensure_ascii=False,
            default=lambda obj: (
                obj.isoformat()
                if isinstance(obj, datetime)
                else str(obj)
            )
        )


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to the lof file")
    parser.add_argument(
        "--report",
        help="Export alerts to a JSON report file"
    )

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

    print("--- Enrichment ---")

    known_ips = 0
    bot_count = 0

    for entry in entries:
        enrich_ip(entry)
        analyze_user_agent(entry)

        if entry.country != "UNKNOWN":
            known_ips += 1

        if entry.is_bot:
            bot_count += 1

    print(
        f"[*] GeoIP: {len(entries)} entries enriched "
        f"({known_ips} known IPs)"
    )
    print(f"[*] Bots detected: {bot_count}")

    print("--- Threat Intelligence ---")

    high_alerts = 0

    for entry in entries:
        check_threat_intel(entry)

        if entry.alert_level == "HIGH":
            high_alerts += 1

    print(
        f"[*] HIGH alerts: {high_alerts} "
        "entries from blacklisted IPs"
    )

    print("--- Attack Detection ---")

    sqli_count = 0
    xss_count = 0

    for entry in entries:
        detect_sqli(entry)
        detect_xss(entry)

        if getattr(entry, "attack_type", "") == "SQLi":
            sqli_count += 1
        elif getattr(entry, "attack_type", "") == "XSS":
            xss_count += 1

    print(f"[*] SQLi attempts: {sqli_count}")
    print(f"[*] XSS attempts:  {xss_count}")

    print("--- Brute Force ---")

    brute_force_alerts = list(detect_bruteforce(entries))
    brute_force_alerts.sort(
        key=lambda alert: alert["count"],
        reverse=True
    )

    print(f"[*] BRUTE_FORCE alerts: {len(brute_force_alerts)}")

    for alert in brute_force_alerts:
        print(f"    {alert['ip']}: {alert['count']} failures")

    print("--- Burst Detection ---")

    burst_alerts = list(detect_burst(entries))

    print(f"[*] BURST alerts: {len(burst_alerts)}")

    for alert in burst_alerts:
        print(
            f"    {alert['ip']}: {alert['count']} "
            f"requests in {alert['window']}s window"
        )
    print("--- Correlation ---")

    critical_incidents = list(correlate_events(entries))

    print("[*] CRITICAL INCIDENTS:")

    for incident in critical_incidents:
        stages = " -> ".join(incident["stages"])
        print(f"    {incident['ip']}: {stages}")

    all_alerts = (
        brute_force_alerts
        + burst_alerts
        + critical_incidents
    )

    if args.report:
        export_report(all_alerts, args.report)

        print(
            f"[*] Report exported: {args.report} "
            f"({len(all_alerts)} alerts)"
        )
    else:
        print(f"[*] Total alerts: {len(all_alerts)}")
        print("[*] Use --report <file> to export.")
