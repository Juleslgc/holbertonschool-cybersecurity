#!/usr/bin/env python3

import socket
from concurrent.futures import ThreadPoolExecutor, as_completed
import argparse
import json
import time


def check_port(ip: str, port: int, delay: float = 0) -> bool:
    if delay > 0:
        print(f"[DEBUG] Sleeping {delay}s before next packet...")
        time.sleep(delay)
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1)
    try:
        s.connect((ip, port))
        return True
    except (TimeoutError, ConnectionRefusedError, OSError):
        return False
    finally:
        s.close()


def ping_sweep(subnet: str) -> list:
    live_ips = []

    for hosts in range(1, 255):
        ip = f'{subnet}.{hosts}'
        if check_port(ip, 80):
            live_ips.append(ip)

    return live_ips


def get_banner(ip: str, port: int) -> str:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(1)

    try:
        s.connect((ip, port))
        s.sendall(b"HEAD / HTTP/1.0\r\n\r\n")
        banner = s.recv(1024)

        if not banner or b"":
            return "Unknown"

        return banner.decode(errors="ignore").strip()
    except (OSError, socket.gaierror):
        return "Unknown"
    finally:
        s.close()


def scan_ports(ip: str, start_port: int, end_port: int,
               delay: float = 0) -> list:
    list_port = []
    print(f"Scanning {ip} from {start_port} to {end_port}")
    with ThreadPoolExecutor(max_workers=50) as executor:
        futures = {executor.submit(check_port, ip, port, delay): port
                   for port in range(start_port, end_port + 1)}
        for future in as_completed(futures):
            port = futures[future]
            if future.result():
                banner = get_banner(ip, port)
                vuln = check_vulnerability(banner)
                list_port.append({
                    'port': port,
                    'state': 'open',
                    'service': banner,
                    'Vulnerability': "YES" if vuln else "NO"
                })
                print(f"[+] Port {port} Open: {banner} {vuln}")
    return list_port


def guess_service(port: int) -> str:
    services = {
        21: "FTP",
        22: "SSH",
        80: "HTTP",
        443: "HTTPS",
        3306: "MySQL"
    }
    return services.get(port, "Unknown")


def get_service_info(ip: str, port: int) -> str:
    banner = get_banner(ip, port)

    if not banner:
        return f"{guess_service(port)} (Guessed)"

    return banner


def check_vulnerability(banner: str) -> str:
    bad_sign = ["vsftpd 2.3.4", "apache 2.2.8"]
    for sign in bad_sign:
        if sign in banner:
            return ("[VULNERABLE]")
    return ""


def parse_args():
    parser = argparse.ArgumentParser(description="NetProbe - Network Scanner")

    parser.add_argument(
        "-t", "--target",
        required=True,
        help="Target IP address"
    )

    parser.add_argument(
        "-p", "--ports",
        type=valid_port_range,
        default="1-1000",
        help="Port range (example: 1-1000)"
    )

    parser.add_argument(
        "-o", "--output",
        help="Output JSON file"
    )

    parser.add_argument(
        "-d", "--delay",
        type=float,
        default=0,
        help="Delay in seconds between scan attempts"
    )

    return parser.parse_args()


def valid_port_range(value):
    try:
        start_port = int(value.split("-")[0])
        end_port = int(value.split("-")[1])

        if start_port < 1 or end_port > 65535 or start_port > end_port:
            raise ValueError

        return start_port, end_port

    except (ValueError, IndexError):
        raise argparse.ArgumentTypeError(
            "Use the format START-END (example: 1-22)"
        )


def main():
    print("NetProbe v1.0 initialized...")
    args = parse_args()
    start_port, end_port = args.ports

    results = scan_ports(args.target, start_port, end_port, args.delay)

    if args.output:
        with open(args.output, "w", encoding="utf-8") as file:
            json.dump(results, file, indent=4)

        print(f"Results saved to {args.output}")


if __name__ == "__main__":
    main()
