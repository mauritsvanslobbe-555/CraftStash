#!/usr/bin/env python3
"""Parse certificate IDs from app-store-connect CLI JSON output."""
import json
import sys

certs = json.load(sys.stdin)
for cert in certs:
    print(cert["id"])
