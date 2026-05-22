#!/usr/bin/env python3
"""Revoke all Distribution certificates via App Store Connect REST API.

The Codemagic CLI's `certificates list --json` returns empty results despite
certificates existing. This script bypasses the CLI and calls the API directly
using a JWT signed with the App Store Connect API key.
"""

import json
import os
import subprocess
import sys
import time
import glob


def find_api_key_info():
    """Find API key ID, issuer ID, and private key path from Codemagic environment."""
    # Codemagic stores the key at a known path pattern
    key_pattern = os.path.expanduser("~/.appstoreconnect/private_keys/AuthKey_*.p8")
    key_files = glob.glob(key_pattern)

    key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
    issuer_id = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")

    # Try to extract key ID from filename if env var not set
    if not key_id and key_files:
        # AuthKey_XXXXXXXX.p8 -> XXXXXXXX
        fname = os.path.basename(key_files[0])
        key_id = fname.replace("AuthKey_", "").replace(".p8", "")

    key_path = key_files[0] if key_files else ""

    # Also check the env var for file path
    if not key_path:
        env_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")
        if env_key.startswith("@file:"):
            key_path = env_key[6:]

    print(f"API Key ID: {key_id}")
    print(f"Issuer ID:  {issuer_id}")
    print(f"Key path:   {key_path}")
    print(f"Key exists: {os.path.exists(key_path) if key_path else False}")

    return key_id, issuer_id, key_path


def generate_jwt(key_id, issuer_id, key_path):
    """Generate a JWT for App Store Connect API authentication."""
    try:
        import jwt  # PyJWT
    except ImportError:
        print("PyJWT not installed, installing...")
        subprocess.run([sys.executable, "-m", "pip", "install", "PyJWT", "cryptography"],
                       capture_output=True)
        import jwt

    with open(key_path, "r") as f:
        private_key = f.read()

    now = int(time.time())
    payload = {
        "iss": issuer_id,
        "iat": now,
        "exp": now + 1200,  # 20 minutes
        "aud": "appstoreconnect-v1",
    }

    token = jwt.encode(payload, private_key, algorithm="ES256", headers={
        "kid": key_id,
        "typ": "JWT",
    })

    return token


def list_certificates(token):
    """List all certificates via REST API."""
    import urllib.request
    import urllib.error

    url = "https://api.appstoreconnect.apple.com/v1/certificates?limit=200"
    req = urllib.request.Request(url, headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    })

    try:
        with urllib.request.urlopen(req) as resp:
            data = json.loads(resp.read().decode())
            return data.get("data", [])
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        print(f"HTTP {e.code} listing certificates: {body[:500]}")
        return []


def delete_certificate(token, cert_id):
    """Delete a certificate via REST API."""
    import urllib.request
    import urllib.error

    url = f"https://api.appstoreconnect.apple.com/v1/certificates/{cert_id}"
    req = urllib.request.Request(url, method="DELETE", headers={
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json",
    })

    try:
        with urllib.request.urlopen(req) as resp:
            print(f"  Deleted {cert_id} (HTTP {resp.status})")
            return True
    except urllib.error.HTTPError as e:
        body = e.read().decode() if e.fp else ""
        print(f"  Failed to delete {cert_id}: HTTP {e.code} - {body[:300]}")
        return False


def main():
    print("=== Revoking Distribution certificates via REST API ===\n")

    key_id, issuer_id, key_path = find_api_key_info()

    if not all([key_id, issuer_id, key_path]):
        print("\nERROR: Could not find API key info. Available env vars:")
        for k, v in sorted(os.environ.items()):
            if any(x in k.upper() for x in ["APP_STORE", "CONNECT", "KEY", "ISSUER"]):
                # Mask sensitive values
                display = v[:20] + "..." if len(v) > 20 else v
                print(f"  {k}={display}")
        print("\nSearching for .p8 files...")
        for root, dirs, files in os.walk(os.path.expanduser("~")):
            for f in files:
                if f.endswith(".p8"):
                    print(f"  Found: {os.path.join(root, f)}")
            # Don't recurse too deep
            if root.count(os.sep) - os.path.expanduser("~").count(os.sep) > 3:
                dirs.clear()
        return

    if not os.path.exists(key_path):
        print(f"\nERROR: Key file not found at {key_path}")
        return

    print("\nGenerating JWT...")
    token = generate_jwt(key_id, issuer_id, key_path)
    print(f"JWT generated (length: {len(token)})")

    print("\nListing certificates...")
    certs = list_certificates(token)
    print(f"Total certificates found: {len(certs)}")

    dist_certs = []
    for cert in certs:
        cert_id = cert.get("id", "")
        attrs = cert.get("attributes", {})
        cert_type = attrs.get("certificateType", "unknown")
        cert_name = attrs.get("name", "unknown")
        expiry = attrs.get("expirationDate", "unknown")
        print(f"  {cert_type}: {cert_name} (id={cert_id}, expires={expiry})")

        if "DISTRIBUTION" in cert_type.upper():
            dist_certs.append(cert_id)

    if not dist_certs:
        print("\nNo Distribution certificates found to revoke.")
        return

    print(f"\n=== Deleting {len(dist_certs)} Distribution certificates ===")
    deleted = 0
    for cert_id in dist_certs:
        print(f"Deleting: {cert_id}")
        if delete_certificate(token, cert_id):
            deleted += 1

    print(f"\n=== Done: deleted {deleted}/{len(dist_certs)} certificates ===")


if __name__ == "__main__":
    main()
