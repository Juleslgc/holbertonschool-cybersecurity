#!/usr/bin/env python3

import socket


def check_port(ip: str, port: int) -> bool:
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


def main():
    print("NetProbe v1.0 initialized...")
    print(f"Port 80 is open: {check_port('google.com', 80)}")
    print(f"Port 81 is open: {check_port('google.com', 81)}")
    print(ping_sweep("192.168.1"))


if __name__ == "__main__":
    main()
