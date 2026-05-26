#!/usr/bin/env python3
"""gmail.py · Clara · envia email via conta Google do dono.

Uso:
    python3 tools/google-workspace/gmail.py send_email --to=email@x.com --subject="..." --body="..."
"""
from __future__ import annotations

import argparse
import base64
import json
import sys
from email.mime.text import MIMEText
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from _oauth import load_credentials  # noqa: E402


def get_service(creds):
    try:
        from googleapiclient.discovery import build
    except ImportError:
        print("[gmail] googleapiclient ausente. Roda: pip install --user google-api-python-client", file=sys.stderr)
        raise SystemExit(3)
    return build("gmail", "v1", credentials=creds, cache_discovery=False)


def send_email(args) -> int:
    creds = load_credentials()
    service = get_service(creds)

    msg = MIMEText(args.body, "plain", "utf-8")
    msg["to"] = args.to
    msg["subject"] = args.subject
    if args.from_addr:
        msg["from"] = args.from_addr

    raw = base64.urlsafe_b64encode(msg.as_bytes()).decode("utf-8")
    result = service.users().messages().send(
        userId="me",
        body={"raw": raw},
    ).execute()

    out = {
        "id": result.get("id"),
        "threadId": result.get("threadId"),
        "to": args.to,
        "subject": args.subject,
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    print(f"[gmail] email enviado pra {args.to}", file=sys.stderr)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Clara · Gmail send")
    sub = parser.add_subparsers(dest="action", required=True)

    p_send = sub.add_parser("send_email", help="Envia email")
    p_send.add_argument("--to", required=True)
    p_send.add_argument("--subject", required=True)
    p_send.add_argument("--body", required=True)
    p_send.add_argument("--from-addr", dest="from_addr", default="")
    p_send.set_defaults(func=send_email)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
