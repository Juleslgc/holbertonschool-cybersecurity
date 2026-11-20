#!/usr/bin/env python3
import argparse
import sys
import re
import logging
import hashlib

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)

formatter = logging.Formatter("%(asctime)s - %(levelname)s - %(message)s")

console = logging.StreamHandler()
console.setLevel(logging.INFO)
console.setFormatter(formatter)

file = logging.FileHandler("breach_check.log")
file.setLevel(logging.DEBUG)
file.setFormatter(formatter)

logger.addHandler(console)
logger.addHandler(file)


def main():
    logging.info("INFO: Processing file...")
    parser = argparse.ArgumentParser(
        description="Command Line Interface - Breach Check"
    )

    parser.add_argument(
        "-f", "--file",
        type=str,
        required=True,
        help="Path to the input file"
    )

    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Enable verbose mode"
    )

    parser.add_argument(
        "-o", "--output",
        type=str,
        help="Path to the output report file"
    )

    args = parser.parse_args()

    lines = read_file(args.file)
    result = clean_data(lines)
    validate_line(result)

    if args.verbose:
        logging.info("Verbose mode enabled")

    if args.output:
        logging.info(f"Output file: {args.output}")


def read_file(filename: str) -> list:
    try:
        with open(filename, "r") as file:
            return file.readlines()
    except FileNotFoundError:
        logging.error(f"[ERROR] File not found: {filename}")
        sys.exit(1)
    except PermissionError:
        logging.error(f"[ERROR] Permission denied: {filename}")
        sys.exit(1)


def clean_data(lines: list) -> list:
    cleaned_line = []
    for line in lines:
        line = line.strip()
        if line and not line.strip().startswith("#"):
            cleaned_line.append(line)
    return cleaned_line


def validate_line(line: str) -> bool:
    logging.debug("DEBUG: Starting regex check on line 42...")
    if re.search(r"[\w.-]+@[\w.-]+\.\w+:.+", line):
        return True
    else:
        return False


def check_policy(password: str) -> str:
    common_password = ['password', '123456']
    if len(password) < 8 or password.isalpha() or password in common_password:
        return ("WEAK")
    else:
        return ("COMPLIANT")


def hash_password(password: str, salt: str) -> str:
    return hashlib.sha256(password.encode() + salt.encode()).hexdigest()


if __name__ == "__main__":
    main()
