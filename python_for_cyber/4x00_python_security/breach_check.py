#!/usr/bin/env python3
import argparse


def main():
    print("BreachCheck v1.0 startup...")
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
        "-o", "-output",
        type=str,
        help="Path to the output report file"
    )

    args = parser.parse_args()

    print(f"Input file: {args.file}")

    if args.verbose:
        print("Verbose mode enabled")

    if args.output:
        print(f"Output file: {args.output}")


if __name__ == "__main__":
    main()
