#!/usr/bin/env python3
import sys
import re
import logging
import hashlib
import configparser

config = configparser.ConfigParser()

if not config.read("config.ini"):
    logging.error("[ERROR] config file missing")
    sys.exit(1)
SALT = config.get("SECURITY", "Salt")
MINLENGTH = config.getint("SECURITY", "MinLength")
COMMON = config.get("SECURITY", "CommonList").split(",")


def read_file(filename: str) -> list:
    try:
        with open(filename, "r") as file:
            for line in file:
                yield line.strip()
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
    if len(password) < MINLENGTH or password.isalpha() or password in COMMON:
        return ("WEAK")
    else:
        return ("COMPLIANT")


def hash_password(password: str, salt: str) -> str:
    return hashlib.sha256(password.encode() + salt.encode()).hexdigest()


if __name__ == "__main__":
    read_file()
    clean_data()
    validate_line()
    check_policy()
    hash_password()
