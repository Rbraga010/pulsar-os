#!/usr/bin/env python3
"""
Clara · Instagram Graph API (STUB FUNCIONAL · não autenticado ainda)

A Instagram Graph API é gratuita pra contas Business ou Creator vinculadas
a uma Facebook Page. Lojista precisa criar um Facebook Developer App + obter
Page Access Token + permissão `instagram_content_publish`.

Uso:
    python3 ig.py publish_photo <image_url> <caption>
    python3 ig.py publish_carousel <image_url_1> <image_url_2> ... <caption>
    python3 ig.py insights <media_id>

ENV obrigatórias (configurar no `.env` do lojista):
    IG_USER_ID         # ID da conta IG Business (numérico)
    IG_ACCESS_TOKEN    # Page Access Token (long-lived · 60 dias)

Setup explicado em README.md.
"""

import os
import sys
import json
import argparse
import urllib.request
import urllib.parse


GRAPH_BASE = "https://graph.facebook.com/v21.0"


def env_or_die(key):
    v = os.environ.get(key)
    if not v:
        print(json.dumps({
            "ok": False,
            "error": "missing_env",
            "var": key,
            "hint": f"Defina {key} no .env do lojista · ver README setup OAuth",
        }))
        sys.exit(2)
    return v


def http_post(url, params):
    data = urllib.parse.urlencode(params).encode("utf-8")
    req = urllib.request.Request(url, data=data, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return {"ok": False, "http_status": e.code, "body": body}


def http_get(url):
    try:
        with urllib.request.urlopen(url, timeout=60) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return {"ok": False, "http_status": e.code, "body": body}


def publish_photo(image_url, caption):
    ig_user = env_or_die("IG_USER_ID")
    token = env_or_die("IG_ACCESS_TOKEN")

    # 1. criar container
    container = http_post(f"{GRAPH_BASE}/{ig_user}/media", {
        "image_url": image_url,
        "caption": caption,
        "access_token": token,
    })
    if "id" not in container:
        return {"ok": False, "step": "create_container", "response": container}

    # 2. publicar container
    publish = http_post(f"{GRAPH_BASE}/{ig_user}/media_publish", {
        "creation_id": container["id"],
        "access_token": token,
    })
    return {
        "ok": "id" in publish,
        "container_id": container["id"],
        "media_id": publish.get("id"),
        "raw_publish": publish,
    }


def publish_carousel(image_urls, caption):
    ig_user = env_or_die("IG_USER_ID")
    token = env_or_die("IG_ACCESS_TOKEN")

    # 1. criar 1 container por imagem (is_carousel_item=true)
    children = []
    for url in image_urls:
        c = http_post(f"{GRAPH_BASE}/{ig_user}/media", {
            "image_url": url,
            "is_carousel_item": "true",
            "access_token": token,
        })
        if "id" not in c:
            return {"ok": False, "step": "child_container", "url": url, "response": c}
        children.append(c["id"])

    # 2. container pai (CAROUSEL)
    parent = http_post(f"{GRAPH_BASE}/{ig_user}/media", {
        "media_type": "CAROUSEL",
        "children": ",".join(children),
        "caption": caption,
        "access_token": token,
    })
    if "id" not in parent:
        return {"ok": False, "step": "parent_container", "response": parent}

    # 3. publicar
    publish = http_post(f"{GRAPH_BASE}/{ig_user}/media_publish", {
        "creation_id": parent["id"],
        "access_token": token,
    })
    return {
        "ok": "id" in publish,
        "parent_container_id": parent["id"],
        "media_id": publish.get("id"),
        "raw_publish": publish,
    }


def insights(media_id):
    token = env_or_die("IG_ACCESS_TOKEN")
    metrics = "impressions,reach,saved,likes,comments,shares"
    url = f"{GRAPH_BASE}/{media_id}/insights?metric={metrics}&access_token={token}"
    return http_get(url)


def main():
    parser = argparse.ArgumentParser()
    sub = parser.add_subparsers(dest="cmd", required=True)

    p1 = sub.add_parser("publish_photo")
    p1.add_argument("image_url")
    p1.add_argument("caption")

    p2 = sub.add_parser("publish_carousel")
    p2.add_argument("urls", nargs="+", help="image_url_1 image_url_2 ... (último arg é caption)")

    p3 = sub.add_parser("insights")
    p3.add_argument("media_id")

    args = parser.parse_args()

    if args.cmd == "publish_photo":
        out = publish_photo(args.image_url, args.caption)
    elif args.cmd == "publish_carousel":
        # último arg é caption · resto são URLs
        if len(args.urls) < 2:
            print(json.dumps({"ok": False, "error": "need_>=1_image_+_caption"}))
            sys.exit(2)
        caption = args.urls[-1]
        urls = args.urls[:-1]
        out = publish_carousel(urls, caption)
    elif args.cmd == "insights":
        out = insights(args.media_id)
    else:
        out = {"ok": False, "error": "unknown_cmd"}

    print(json.dumps(out, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
