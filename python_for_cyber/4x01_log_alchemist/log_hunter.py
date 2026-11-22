#!/usr/bin/env python3

import argparse


def read_stream(file_path: str):
    """Read a file one line at a time using a generator"""
    try:
        with open(file_path, "r") as file:
            for line in file:
                yield line
    except FileNotFoundError:
        print(f"[ERROR] File not found: {file_path}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("file", help="Path to the lof file")

    args = parser.parse_args()

    print("[*] LogHunter - Log Analysis Engine")
    print(f"[*] Reading: {args.file}")

    line_count = 0

    for line in read_stream(args.file):
        line_count += 1

    if line_count == 0:
        print("[!] No data to process. Existing.")
    else:
        print(f"[*] Lines read: {line_count}")