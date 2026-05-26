#!/usr/bin/env python3
"""
Clara · Google Meu Negócio (Business Profile API) · STUB

API gratuita. Lojista precisa fazer OAuth no Google Cloud (criar projeto +
ativar Business Profile API + gerar refresh token).

Uso:
    python3 gmb.py list_locations
    python3 gmb.py create_post <location_id> "<texto>" [--image=URL]
    python3 gmb.py list_reviews <location_id>
    python3 gmb.py reply_review <review_id> "<resposta>"

ENV obrigatórias (.env do lojista):
    GMB_ACCESS_TOKEN     # OAuth access token
    GMB_ACCOUNT_ID       # accounts/XXXXXX

Setup explicado em README.md.
"""

import os
import sys
import json
import argparse
import urllib.request


BASE_V4 = "https://mybusiness.googleapis.com/v4"            # locations · posts (legacy)
BASE_BP = "https://mybusinessbusinessinformation.googleapis.com/v1"  # business info
BASE_BUS_AC = "https://mybusinessaccountmanagement.googleapis.com/v1"  # accounts


def env_or_die(key):
    v = os.environ.get(key)
    if not v:
        print(json.dumps({"ok": False, "error": "missing_env", "var": key}))
        sys.exit(2)
    return v


def http_request(method, url, body=None):
    token = env_or_die("GMB_ACCESS_TOKEN")
    headers = {
        "Authorization": f"Bearer {token}",
        "Content-Type": "application/json; charset=utf-8",
    }
    data = None
    if body is not None:
        data = json.dumps(body).encode("utf-8")
    req = urllib.request.Request(url, data=data, method=method, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        return {
            "ok": False,
            "http_status": e.code,
            "body": e.read().decode("utf-8", errors="replace"),
        }


def list_locations():
    acc = env_or_die("GMB_ACCOUNT_ID")
    url = f"{BASE_BP}/{acc}/locations?readMask=name,title,storefrontAddress,phoneNumbers"
    return http_request("GET", url)


def create_post(location_id, text, image_url=None):
    body = {"languageCode": "pt-BR", "summary": text, "topicType": "STANDARD"}
    if image_url:
        body["media"] = [{"mediaFormat": "PHOTO", "sourceUrl": image_url}]
    url = f"{BASE_V4}/{location_id}/localPosts"
    return http_request("POST", url, body)


def list_reviews(location_id):
    url = f"{BASE_V4}/{location_id}/reviews"
    return http_request("GET", url)


def reply_review(review_name, comment):
    # review_name = "accounts/X/locations/Y/reviews/Z"
    url = f"{BASE_V4}/{review_name}/reply"
    return http_request("PUT", url, {"comment": comment})


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)

    sub.add_parser("list_locations")

    p1 = sub.add_parser("create_post")
    p1.add_argument("location_id")
    p1.add_argument("text")
    p1.add_argument("--image", default=None)

    p2 = sub.add_parser("list_reviews")
    p2.add_argument("location_id")

    p3 = sub.add_parser("reply_review")
    p3.add_argument("review_name")
    p3.add_argument("comment")

    args = parser.parse_args()

    if args.cmd == "list_locations":
        out = list_locations()
    elif args.cmd == "create_post":
        out = create_post(args.location_id, args.text, args.image)
    elif args.cmd == "list_reviews":
        out = list_reviews(args.location_id)
    elif args.cmd == "reply_review":
        out = reply_review(args.review_name, args.comment)
    else:
        out = {"ok": False, "error": "unknown_cmd"}

    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
