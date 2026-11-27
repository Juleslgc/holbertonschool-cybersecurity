#!/usr/bin/env python3

import socket
from concurrent.futures import ThreadPoolExecutor, as_completed


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


def scan_ports(ip: str, start_port: int, end_port: int) -> list:
    list_port = []
    print(f"Scanning {ip} from {start_port} to {end_port}")
    with ThreadPoolExecutor(max_workers=50) as executor:
        futures = {executor.submit(check_port, ip, port): port
                   for port in range(start_port, end_port + 1)}
        for future in as_completed(futures):
            port = futures[future]
            if future.result():
                banner = get_banner(ip, port)
                list_port.append({
                    'port': port,
                    'service': banner
                })
                print(f"[+] Port {port} Open: {banner}")
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


def main():
    print("NetProbe v1.0 initialized...")
    print(f"Port 80 is open: {check_port('google.com', 80)}")
    print(f"Port 81 is open: {check_port('google.com', 81)}")
    print(ping_sweep("192.168.1"))
    print(get_banner("scanme.nmap.org", 22))
    print(get_banner("scanme.nma", 21))
    print(scan_ports("192.168.1.1", 20, 80))
    print(get_service_info("192.168.1", 80))


if __name__ == "__main__":
    main()
