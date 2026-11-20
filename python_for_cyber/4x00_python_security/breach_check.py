#!/usr/bin/env python3
import argparse
import sys
import logging
import configparser
from utils import read_file, clean_data, validate_line, check_policy, hash_password

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


config = configparser.ConfigParser()

if not config.read("config.ini"):
    logging.error("[ERROR] config file missing")
    sys.exit(1)
SALT = config.get("SECURITY", "Salt")


def main():
    # 1. Configuration des arguments
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

    # 2. Mode verbose
    if args.verbose:
        logging.debug("Verbose mode enabled")

    # 3. Lecture du fichier
    logging.info("Processing input file...")
    lines = read_file(args.file)

    # 4. Nettoyage des lignes
    cleaned_lines = clean_data(lines)
    logging.info(f"{len(cleaned_lines)} lines to process")

    # 5. Validation et analyse
    valid_count = 0
    invalid_count = 0
    weak_count = 0
    compliant_count = 0

    for line_number, line in enumerate(cleaned_lines, start=1):

        if not validate_line(line):
            logging.warning(f"Invalid line at line {line_number}")
            invalid_count += 1
            continue

        email, password = line.split(":", 1)

        policy = check_policy(password)
        hashed_password = hash_password(password, SALT)

        valid_count += 1

        if policy == "WEAK":
            weak_count += 1
            logging.warning(f"Weak password detected at line {line_number}")
        else:
            compliant_count += 1
            logging.info(f"Compliant password at line {line_number}")

        logging.debug(f"Password hash generated for line {line_number}")

    # 6. Résumé final
    logging.info("Processing completed")
    logging.info(f"Valid lines: {valid_count}")
    logging.info(f"Invalid lines: {invalid_count}")
    logging.info(f"Weak passwords: {weak_count}")
    logging.info(f"Compliant passwords: {compliant_count}")
    logging.info(f"Email : {email}")
    logging.info(f"Password hash : {hashed_password}")

    # 7. Chemin du rapport
    if args.output:
        logging.info(f"Output file requested: {args.output}")


if __name__ == "__main__":
    main()
