#!/usr/bin/env python3
"""Revoke all Distribution certificates using the app-store-connect CLI."""

import subprocess
import sys
import re


def run(cmd):
    """Run a command and return (stdout, stderr, returncode)."""
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout, result.stderr, result.returncode


def main():
    print("=== Step 1: List certificates (raw text) ===")
    stdout, stderr, rc = run([
        "app-store-connect", "certificates", "list",
        "--type", "DISTRIBUTION",
        "--type", "IOS_DISTRIBUTION",
    ])
    print(f"Exit code: {rc}")
    print(f"STDOUT:\n{stdout[:2000]}")
    print(f"STDERR:\n{stderr[:2000]}")

    print("\n=== Step 2: List certificates (--json) ===")
    stdout_json, stderr_json, rc_json = run([
        "app-store-connect", "certificates", "list",
        "--type", "DISTRIBUTION",
        "--type", "IOS_DISTRIBUTION",
        "--json",
    ])
    print(f"Exit code: {rc_json}")
    print(f"STDOUT:\n{stdout_json[:2000]}")
    print(f"STDERR:\n{stderr_json[:2000]}")

    # Try to find certificate IDs from any output
    cert_ids = set()

    # Method 1: Try parsing JSON from stdout
    try:
        import json
        data = json.loads(stdout_json)
        if isinstance(data, list):
            for c in data:
                if "id" in c:
                    cert_ids.add(c["id"])
        elif isinstance(data, dict) and "data" in data:
            for c in data["data"]:
                if "id" in c:
                    cert_ids.add(c["id"])
        print(f"\nMethod 1 (JSON stdout): found {len(cert_ids)} IDs")
    except Exception as e:
        print(f"\nMethod 1 (JSON stdout) failed: {e}")

    # Method 2: Try parsing JSON from stderr (some CLI tools output JSON to stderr)
    if not cert_ids:
        try:
            import json
            data = json.loads(stderr_json)
            if isinstance(data, list):
                for c in data:
                    if "id" in c:
                        cert_ids.add(c["id"])
            print(f"Method 2 (JSON stderr): found {len(cert_ids)} IDs")
        except Exception as e:
            print(f"Method 2 (JSON stderr) failed: {e}")

    # Method 3: Extract IDs from text output using regex
    # Look for alphanumeric IDs that look like Apple resource IDs
    if not cert_ids:
        all_output = stdout + stderr + stdout_json + stderr_json
        # Apple resource IDs are typically alphanumeric, 10+ chars
        # Look for patterns after "Serial:" or in parentheses
        patterns = [
            r"Serial:\s*([A-Fa-f0-9]{20,})",
            r"\(([A-Za-z0-9]{8,})\)",
            r"id[=:]\s*([A-Za-z0-9_-]{8,})",
        ]
        for pattern in patterns:
            matches = re.findall(pattern, all_output, re.IGNORECASE)
            if matches:
                cert_ids.update(matches)
                print(f"Method 3 (regex '{pattern}'): found {len(matches)} matches")

    # Method 4: Try --save flag to get certificates to files
    if not cert_ids:
        print("\nMethod 4: Trying --save flag...")
        stdout_save, stderr_save, rc_save = run([
            "app-store-connect", "certificates", "list",
            "--type", "DISTRIBUTION",
            "--type", "IOS_DISTRIBUTION",
            "--save",
        ])
        print(f"Save stdout:\n{stdout_save[:1000]}")
        print(f"Save stderr:\n{stderr_save[:1000]}")

    print(f"\n=== Found certificate IDs: {cert_ids} ===")

    if not cert_ids:
        print("WARNING: Could not find any certificate IDs to revoke!")
        print("Dumping all available subcommands for debugging:")
        help_out, help_err, _ = run(["app-store-connect", "certificates", "--help"])
        print(help_out)
        print(help_err)
        sys.exit(0)

    # Delete each certificate
    print(f"\n=== Step 3: Deleting {len(cert_ids)} certificates ===")
    for cert_id in cert_ids:
        print(f"\nDeleting: {cert_id}")
        del_out, del_err, del_rc = run([
            "app-store-connect", "certificates", "delete", cert_id,
        ])
        print(f"  Exit code: {del_rc}")
        if del_out.strip():
            print(f"  Stdout: {del_out[:200]}")
        if del_err.strip():
            print(f"  Stderr: {del_err[:200]}")

    print("\n=== Certificate revocation complete ===")


if __name__ == "__main__":
    main()
