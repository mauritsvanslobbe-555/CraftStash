#!/usr/bin/env python3
"""Revoke all Distribution certificates using the app-store-connect CLI."""

import subprocess
import json
import sys


def run(cmd):
    """Run command, return (stdout, stderr, returncode)."""
    r = subprocess.run(cmd, capture_output=True, text=True)
    return r.stdout, r.stderr, r.returncode


def main():
    # List ALL certificates (no type filter — the type filter returns 0 results)
    print("=== Listing ALL certificates ===")
    stdout, stderr, rc = run([
        "app-store-connect", "certificates", "list", "--json",
    ])
    print(f"Exit code: {rc}")
    print(f"STDERR (first 500): {stderr[:500]}")

    # Parse JSON
    cert_ids = []
    try:
        certs = json.loads(stdout)
        print(f"Total certificates found: {len(certs)}")
        for cert in certs:
            cert_id = cert.get("id", "")
            attrs = cert.get("attributes", {})
            cert_type = attrs.get("certificateType", "unknown")
            cert_name = attrs.get("name", "unknown")
            print(f"  {cert_type}: {cert_name} (id={cert_id})")

            # Collect all Distribution-type certificates
            if "DISTRIBUTION" in cert_type.upper():
                cert_ids.append(cert_id)
    except json.JSONDecodeError as e:
        print(f"JSON parse error: {e}")
        print(f"Raw stdout (first 500): {stdout[:500]}")

    if not cert_ids:
        print("\nNo Distribution certificates found to revoke.")
        print("Trying without --json for debug info...")
        stdout2, stderr2, _ = run([
            "app-store-connect", "certificates", "list",
        ])
        print(f"Text stdout:\n{stdout2[:1000]}")
        print(f"Text stderr:\n{stderr2[:1000]}")
        return

    # Delete each Distribution certificate
    print(f"\n=== Deleting {len(cert_ids)} Distribution certificates ===")
    for cert_id in cert_ids:
        print(f"Deleting: {cert_id}")
        out, err, rc = run([
            "app-store-connect", "certificates", "delete", cert_id,
        ])
        print(f"  rc={rc} | {out.strip()} {err.strip()}"[:200])

    print("\n=== Done ===")


if __name__ == "__main__":
    main()
