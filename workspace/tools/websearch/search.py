#!/usr/bin/env python3
"""search.py · Clara · pesquisa web.

Default GRÁTIS: DuckDuckGo HTML scrape (sem API key · sem cadastro).
Alternativa: Brave Search API (variável BRAVE_SEARCH_API_KEY · melhor relevância).

Uso:
    python3 tools/websearch/search.py "<query>" [--engine=ddg|brave] [--limit=5]

Saída: JSON na stdout · [{"title": ..., "url": ..., "snippet": ...}]
"""
from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from urllib.parse import quote_plus

WORKSPACE = Path("/opt/clones/clara/workspace")
ENV_PATH = WORKSPACE / ".env"


def load_env(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.exists():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        k, _, v = line.partition("=")
        out[k.strip()] = v.strip().strip('"')
    return out


def search_ddg(query: str, limit: int) -> list[dict]:
    """DuckDuckGo HTML scrape · sem API key."""
    try:
        import requests
        from bs4 import BeautifulSoup
    except ImportError:
        print(
            "[websearch] dependências ausentes. Roda 1x:\n"
            "  pip install --user requests beautifulsoup4",
            file=sys.stderr,
        )
        sys.exit(3)

    url = f"https://html.duckduckgo.com/html/?q={quote_plus(query)}"
    headers = {
        "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36",
        "Accept-Language": "pt-BR,pt;q=0.9,en;q=0.8",
    }
    r = requests.get(url, headers=headers, timeout=15)
    if r.status_code != 200:
        print(f"[websearch] DDG HTTP {r.status_code}", file=sys.stderr)
        return []

    soup = BeautifulSoup(r.text, "html.parser")
    results: list[dict] = []
    for block in soup.select("div.result"):
        a = block.select_one("a.result__a")
        snip = block.select_one(".result__snippet")
        if not a:
            continue
        href = a.get("href", "")
        title = a.get_text(strip=True)
        snippet = snip.get_text(strip=True) if snip else ""
        if not title or not href:
            continue
        results.append({"title": title, "url": href, "snippet": snippet})
        if len(results) >= limit:
            break

    return results


def search_brave(query: str, limit: int, api_key: str) -> list[dict]:
    try:
        import requests
    except ImportError:
        print("[websearch] requests ausente. Roda: pip install --user requests", file=sys.stderr)
        sys.exit(3)

    url = "https://api.search.brave.com/res/v1/web/search"
    headers = {
        "Accept": "application/json",
        "X-Subscription-Token": api_key,
    }
    params = {"q": query, "count": limit, "country": "BR", "search_lang": "pt"}
    r = requests.get(url, headers=headers, params=params, timeout=15)
    if r.status_code != 200:
        print(f"[websearch] Brave HTTP {r.status_code}: {r.text[:300]}", file=sys.stderr)
        return []
    data = r.json()
    web = data.get("web", {}).get("results", [])
    out = []
    for item in web[:limit]:
        out.append({
            "title": item.get("title", ""),
            "url": item.get("url", ""),
            "snippet": item.get("description", ""),
        })
    return out


def main() -> int:
    parser = argparse.ArgumentParser(description="Clara websearch · DuckDuckGo grátis · Brave opcional.")
    parser.add_argument("query", help="Termo de busca")
    parser.add_argument("--engine", default="ddg", choices=["ddg", "brave"], help="Motor de busca")
    parser.add_argument("--limit", type=int, default=5, help="Quantos resultados")
    args = parser.parse_args()

    env = {**load_env(ENV_PATH), **os.environ}

    if args.engine == "brave":
        key = env.get("BRAVE_SEARCH_API_KEY")
        if not key:
            print("[websearch] BRAVE_SEARCH_API_KEY ausente · caindo no DuckDuckGo", file=sys.stderr)
            results = search_ddg(args.query, args.limit)
        else:
            results = search_brave(args.query, args.limit, key)
    else:
        results = search_ddg(args.query, args.limit)

    print(json.dumps(results, ensure_ascii=False, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
