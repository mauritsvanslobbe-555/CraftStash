#!/usr/bin/env python3
"""
Revoke all existing Apple Distribution certificates via App Store Connect API.

Apple allows max 2 Distribution certs. When both slots are taken with lost
private keys, we must revoke them before creating a new one.

Requires environment variables set by Codemagic integration:
- APP_STORE_CONNECT_KEY_IDENTIFIER
- APP_STORE_CONNECT_ISSUER_ID
- APP_STORE_CONNECT_PRIVATE_KEY
"""

import json
import time
import os
import sys
from urllib.request import Request, urlopen
from urllib.error import HTTPError

try:
    import jwt
except ImportError:
    print("ERROR: PyJWT not installed. Run: pip3 install PyJWT")
    sys.exit(1)


def main():
    key_id = os.environ.get("APP_STORE_CONNECT_KEY_IDENTIFIER", "")
    issuer_id = os.environ.get("APP_STORE_CONNECT_ISSUER_ID", "")
    private_key = os.environ.get("APP_STORE_CONNECT_PRIVATE_KEY", "")

    if not all([key_id, issuer_id, private_key]):
        print("WARNING: Missing App Store Connect credentials!")
        print(f"  KEY_IDENTIFIER set: {bool(key_id)}")
        print(f"  ISSUER_ID set: {bool(issuer_id)}")
        print(f"  PRIVATE_KEY set: {bool(private_key)}")
        sys.exit(0)

    print(f"Using Key ID: {key_id}")
    print(f"Using Issuer ID: {issuer_id}")

    # Create JWT token
    token = jwt.encode(
        {
            "iss": issuer_id,
            "iat": int(time.time()),
            "exp": int(time.time()) + 1200,
            "aud": "appstoreconnect-v1",
        },
        private_key,
        algorithm="ES256",
        headers={"kid": key_id},
    )

    headers = {"Authorization": f"Bearer {token}"}

    # List all Distribution certificates
    print("\n=== Listing Distribution certificates ===")
    try:
        req = Request(
            "https://api.appstoreconnect.apple.com/v1/certificates"
            "?filter[certificateType]=DISTRIBUTION,IOS_DISTRIBUTION",
            headers=headers,
        )
        resp = urlopen(req)
        data = json.loads(resp.read())
        certs = data.get("data", [])
        print(f"Found {len(certs)} Distribution certificate(s)")

        if not certs:
            print("No certificates to revoke.")
            return

        for cert in certs:
            cert_id = cert["id"]
            attrs = cert.get("attributes", {})
            cert_name = attrs.get("name", "unknown")
            cert_type = attrs.get("certificateType", "unknown")
            print(f"\n  Revoking: {cert_name} (type={cert_type}, id={cert_id})")
            try:
                del_req = Request(
                    f"https://api.appstoreconnect.apple.com/v1/certificates/{cert_id}",
                    method="DELETE",
                    headers=headers,
                )
                urlopen(del_req)
                print("  -> Revoked successfully")
            except HTTPError as e:
                body = e.read().decode()
                print(f"  -> Error {e.code}: {body[:300]}")

    except HTTPError as e:
        body = e.read().decode()
        print(f"Error listing certificates: {e.code} {body[:500]}")
    except Exception as e:
        print(f"Unexpected error: {e}")

    print("\n=== Certificate revocation complete ===\n")


if __name__ == "__main__":
    main()
