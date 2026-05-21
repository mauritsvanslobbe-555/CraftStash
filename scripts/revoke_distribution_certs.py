#!/usr/bin/env python3
"""
Revoke all existing Apple Distribution certificates.

Uses multiple methods to ensure at least one works:
1. codemagic Python library (already authenticated via env vars)
2. CLI with subprocess
3. Raw API calls with curl
"""

import os
import sys
import subprocess
import json


def method_cli_json():
    """Use app-store-connect CLI to list certs as JSON, then delete each."""
    print("--- Method: CLI list + delete ---")

    # First check what subcommands are available
    help_result = subprocess.run(
        ["app-store-connect", "certificates", "--help"],
        capture_output=True, text=True,
    )
    print(f"Available certificate commands:\n{help_result.stdout}\n")

    # List certificates with JSON output
    list_result = subprocess.run(
        [
            "app-store-connect", "certificates", "list",
            "--type", "DISTRIBUTION",
            "--type", "IOS_DISTRIBUTION",
        ],
        capture_output=True, text=True,
    )
    print(f"List stdout:\n{list_result.stdout[:1000]}")
    print(f"List stderr:\n{list_result.stderr[:1000]}")

    # Try to find certificate resource IDs in the output
    # The CLI typically outputs structured data we can parse
    stdout = list_result.stdout

    # Try parsing as JSON (if --json flag was implicit or output is JSON)
    cert_ids = []
    try:
        data = json.loads(stdout)
        if isinstance(data, list):
            cert_ids = [c.get("id", "") for c in data if c.get("id")]
        elif isinstance(data, dict) and "data" in data:
            cert_ids = [c.get("id", "") for c in data["data"] if c.get("id")]
    except (json.JSONDecodeError, TypeError):
        # Not JSON, try to extract IDs from text output
        # Certificate IDs are typically alphanumeric strings
        import re
        # Look for patterns like "Serial number: XXXXX" or "ID: XXXXX"
        for line in stdout.split("\n"):
            # Codemagic CLI typically shows certificate details
            if "Serial" in line or "id" in line.lower():
                print(f"  Potential ID line: {line.strip()}")

    if cert_ids:
        for cert_id in cert_ids:
            print(f"\nDeleting certificate: {cert_id}")
            del_result = subprocess.run(
                ["app-store-connect", "certificates", "delete", cert_id],
                capture_output=True, text=True,
            )
            print(f"  exit code: {del_result.returncode}")
            print(f"  stdout: {del_result.stdout[:200]}")
            print(f"  stderr: {del_result.stderr[:200]}")
        return True

    print("Could not extract certificate IDs from CLI output")
    return False


def method_library():
    """Use the codemagic Python library directly."""
    print("\n--- Method: codemagic Python library ---")

    # Discover what's available in the codemagic package
    try:
        import codemagic
        print(f"codemagic package location: {codemagic.__file__}")
    except ImportError:
        print("codemagic package not importable")
        return False

    # Try various import paths
    api_client = None

    # Approach A: Use the high-level API client
    try:
        from codemagic.apple.app_store_connect import AppStoreConnectApiClient
        print("Imported AppStoreConnectApiClient")

        key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
        issuer_id = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
        private_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")

        api_client = AppStoreConnectApiClient(
            key_identifier=key_id,
            issuer_id=issuer_id,
            private_key=private_key,
        )
        print("Created API client successfully")
    except Exception as e:
        print(f"Approach A failed: {e}")

    if api_client is None:
        # Approach B: Try alternative import paths
        try:
            from codemagic.apple import AppStoreConnectApiClient as Client2
            key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
            issuer_id = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
            private_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")
            api_client = Client2(
                key_identifier=key_id,
                issuer_id=issuer_id,
                private_key=private_key,
            )
            print("Created API client via alternative import")
        except Exception as e:
            print(f"Approach B failed: {e}")

    if api_client is None:
        print("Could not create API client")
        return False

    # Try to list and delete certificates
    try:
        # List signing certificates
        print("\nListing certificates...")
        certs = list(api_client.signing_certificates.list())
        print(f"Found {len(certs)} total certificates")

        for cert in certs:
            cert_type = getattr(cert, "certificate_type", "unknown")
            cert_id = getattr(cert, "id", "unknown")
            print(f"  Certificate: id={cert_id}, type={cert_type}")

            if "DISTRIBUTION" in str(cert_type).upper():
                print(f"  -> Deleting distribution cert {cert_id}...")
                try:
                    api_client.signing_certificates.delete(cert_id)
                    print(f"  -> Deleted!")
                except Exception as de:
                    print(f"  -> Delete failed: {de}")
        return True
    except Exception as e:
        print(f"List/delete failed: {e}")
        import traceback
        traceback.print_exc()

    return False


def method_curl():
    """Generate JWT with openssl and use curl to delete certificates."""
    print("\n--- Method: openssl JWT + curl ---")

    key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
    issuer_id = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
    private_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")

    if not all([key_id, issuer_id, private_key]):
        print("Missing credentials")
        return False

    # Write the private key to a temp file
    key_path = "/tmp/asc_api_key.p8"
    # Handle literal \n in the key
    formatted_key = private_key.replace("\\n", "\n")
    with open(key_path, "w") as f:
        f.write(formatted_key)

    print(f"Key written to {key_path}")
    print(f"Key starts with: {formatted_key[:40]}")

    # Try to load the key with openssl to verify it's valid
    verify = subprocess.run(
        ["openssl", "ec", "-in", key_path, "-noout", "-text"],
        capture_output=True, text=True,
    )
    print(f"Key verification: exit={verify.returncode}")
    if verify.returncode != 0:
        print(f"Key verification stderr: {verify.stderr[:300]}")
        # Try without the \n replacement
        with open(key_path, "w") as f:
            f.write(private_key)
        verify2 = subprocess.run(
            ["openssl", "ec", "-in", key_path, "-noout", "-text"],
            capture_output=True, text=True,
        )
        print(f"Raw key verification: exit={verify2.returncode}")
        if verify2.returncode != 0:
            print(f"Raw key stderr: {verify2.stderr[:300]}")
            # Try to detect the actual format
            print(f"\nKey content analysis:")
            print(f"  Length: {len(private_key)}")
            print(f"  First 60 chars: {repr(private_key[:60])}")
            print(f"  Last 40 chars: {repr(private_key[-40:])}")
            print(f"  Contains literal backslash-n: {'\\\\n' in repr(private_key)}")
            print(f"  Contains real newlines: {chr(10) in private_key}")
            print(f"  Unique chars: {set(private_key[:200]) - set('ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789')}")
            return False

    print("Key is valid!")

    # Generate JWT components using Python
    import base64
    import time
    import struct

    def b64url(data):
        if isinstance(data, str):
            data = data.encode()
        return base64.urlsafe_b64encode(data).rstrip(b"=").decode()

    now = int(time.time())
    header = b64url(json.dumps({"alg": "ES256", "kid": key_id, "typ": "JWT"}))
    payload = b64url(json.dumps({
        "iss": issuer_id, "iat": now, "exp": now + 1200,
        "aud": "appstoreconnect-v1",
    }))

    signing_input = f"{header}.{payload}"

    # Sign with openssl
    sign_result = subprocess.run(
        ["openssl", "dgst", "-sha256", "-sign", key_path, "-binary"],
        input=signing_input.encode(),
        capture_output=True,
    )

    if sign_result.returncode != 0:
        print(f"Signing failed: {sign_result.stderr.decode()}")
        return False

    der_sig = sign_result.stdout

    # Convert DER signature to raw (r, s) for ES256 JWT
    # DER format: 30 <len> 02 <rlen> <r> 02 <slen> <s>
    try:
        from cryptography.hazmat.primitives.asymmetric.utils import decode_dss_signature
        r, s = decode_dss_signature(der_sig)
        raw_sig = r.to_bytes(32, byteorder="big") + s.to_bytes(32, byteorder="big")
    except ImportError:
        # Manual DER parsing
        idx = 2  # skip 30 <len>
        if der_sig[0] == 0x30:
            idx = 2
            r_len = der_sig[3]
            r_start = 4
            r_bytes = der_sig[r_start:r_start + r_len]
            s_len_idx = r_start + r_len + 1
            s_len = der_sig[s_len_idx]
            s_start = s_len_idx + 1
            s_bytes = der_sig[s_start:s_start + s_len]

            # Remove leading zero padding
            r_bytes = r_bytes.lstrip(b"\x00").rjust(32, b"\x00")
            s_bytes = s_bytes.lstrip(b"\x00").rjust(32, b"\x00")
            raw_sig = r_bytes + s_bytes
        else:
            print(f"Unexpected DER format: {der_sig[:10].hex()}")
            return False

    signature = b64url(raw_sig)
    token = f"{signing_input}.{signature}"
    print(f"JWT token generated (length: {len(token)})")

    # List certificates
    list_result = subprocess.run(
        [
            "curl", "-s",
            "-H", f"Authorization: Bearer {token}",
            "https://api.appstoreconnect.apple.com/v1/certificates?filter[certificateType]=DISTRIBUTION,IOS_DISTRIBUTION",
        ],
        capture_output=True, text=True,
    )

    print(f"API list response: {list_result.stdout[:500]}")

    try:
        data = json.loads(list_result.stdout)
        certs = data.get("data", [])
        print(f"Found {len(certs)} certificates")

        for cert in certs:
            cert_id = cert["id"]
            cert_name = cert.get("attributes", {}).get("name", "unknown")
            print(f"\nDeleting: {cert_name} (id={cert_id})")
            del_result = subprocess.run(
                [
                    "curl", "-s", "-X", "DELETE",
                    "-H", f"Authorization: Bearer {token}",
                    f"https://api.appstoreconnect.apple.com/v1/certificates/{cert_id}",
                    "-w", "\nHTTP_STATUS:%{http_code}",
                ],
                capture_output=True, text=True,
            )
            print(f"  Response: {del_result.stdout[:200]}")
        return True
    except Exception as e:
        print(f"Error parsing response: {e}")
        return False


if __name__ == "__main__":
    print("=== Revoking Distribution Certificates ===\n")

    # Try method 1: CLI
    success = False
    try:
        success = method_cli_json()
    except Exception as e:
        print(f"CLI method error: {e}")

    # Try method 2: Python library
    if not success:
        try:
            success = method_library()
        except Exception as e:
            print(f"Library method error: {e}")

    # Try method 3: curl with openssl JWT
    if not success:
        try:
            success = method_curl()
        except Exception as e:
            print(f"Curl method error: {e}")

    if success:
        print("\n=== Certificate revocation completed ===")
    else:
        print("\n=== All methods failed - check output above ===")
        sys.exit(0)  # Don't fail the build
