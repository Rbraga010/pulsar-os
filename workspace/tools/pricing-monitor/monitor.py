#!/usr/bin/env python3
"""
pricing-monitor · varredura de preço de produto na web

Uso:
  python3 monitor.py "<descricao do produto>" [--cidade=Sorocaba] [--max=10]

Output (stdout · 1 linha JSON):
  {
    "produto": "...",
    "fontes": [{"loja":"...","preco":...,"url":"..."}],
    "preco_mediano": float,
    "preco_minimo": float,
    "preco_maximo": float,
    "sugestao": float,
    "confianca": "alta|media|baixa"
  }

Princípios:
- GRATIS · usa websearch (DuckDuckGo via tools/websearch/search.py · gratuito)
- LOCAL · zero API key obrigatória
- HONESTO · se não achar fontes suficientes, retorna confianca=baixa
- NUNCA decide preço sozinha · sugere SEMPRE pedindo aprovação humana

Clara NUNCA muda preço de produto do lojista sem o lojista responder OK
explicitamente. Esta tool é só sensor de mercado · a decisão é dele.
"""

import argparse
import json
import re
import statistics
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
WORKSPACE = HERE.parent.parent
WEBSEARCH = WORKSPACE / "tools" / "websearch" / "search.py"

PRICE_RE = re.compile(r"R\$\s*([\d.]+,\d{2}|\d{1,3}(?:\.\d{3})*,\d{2}|\d+)")


def parse_brl(text: str) -> float | None:
    """Converte 'R$ 1.299,90' -> 1299.90"""
    m = PRICE_RE.search(text)
    if not m:
        return None
    raw = m.group(1)
    # remove milhar com ponto, troca vírgula decimal
    raw = raw.replace(".", "").replace(",", ".")
    try:
        v = float(raw)
        # filtro de sanidade: ignora preço absurdamente baixo ou alto pra varejo BR
        if 1.0 <= v <= 999999.0:
            return v
    except ValueError:
        pass
    return None


def search_web(query: str, max_results: int = 8) -> list[dict]:
    """Roda tool websearch · retorna [{title, url, snippet}]"""
    if not WEBSEARCH.exists():
        print(
            f"[pricing-monitor] tool websearch nao encontrada em {WEBSEARCH} · sem fontes",
            file=sys.stderr,
        )
        return []
    try:
        out = subprocess.check_output(
            ["python3", str(WEBSEARCH), query, f"--max={max_results}"],
            stderr=subprocess.DEVNULL,
            timeout=60,
        )
        return json.loads(out.decode("utf-8"))
    except (subprocess.CalledProcessError, subprocess.TimeoutExpired, json.JSONDecodeError) as e:
        print(f"[pricing-monitor] websearch falhou: {e}", file=sys.stderr)
        return []


def extract_store(url: str) -> str:
    """Extrai nome da loja a partir da URL"""
    if not url:
        return "?"
    m = re.search(r"https?://(?:www\.)?([^/]+)", url)
    if not m:
        return "?"
    host = m.group(1).split(":")[0]
    # remove TLDs comuns
    return host.replace(".com.br", "").replace(".com", "").replace(".br", "")


def confianca(n_fontes: int) -> str:
    if n_fontes >= 5:
        return "alta"
    if n_fontes >= 2:
        return "media"
    return "baixa"


def main() -> int:
    parser = argparse.ArgumentParser(description="Monitora preço de produto na web BR")
    parser.add_argument("produto", help="descrição do produto (ex: 'tênis nike air force 1 branco 42')")
    parser.add_argument("--cidade", default="", help="cidade pra refinar busca local")
    parser.add_argument("--max", type=int, default=10, help="máx resultados")
    args = parser.parse_args()

    query = args.produto
    if args.cidade:
        query = f"{query} {args.cidade}"
    query = f"{query} preço comprar"

    results = search_web(query, args.max)
    fontes = []
    precos = []
    for r in results:
        text_blob = " ".join([r.get("title") or "", r.get("snippet") or ""])
        preco = parse_brl(text_blob)
        if preco is None:
            continue
        loja = extract_store(r.get("url", ""))
        fontes.append({"loja": loja, "preco": preco, "url": r.get("url"), "titulo": r.get("title")})
        precos.append(preco)

    if not precos:
        print(json.dumps({
            "produto": args.produto,
            "fontes": [],
            "confianca": "baixa",
            "erro": "nenhuma fonte com preço extraído",
        }, ensure_ascii=False))
        return 0

    out = {
        "produto": args.produto,
        "fontes": fontes,
        "preco_mediano": round(statistics.median(precos), 2),
        "preco_minimo": min(precos),
        "preco_maximo": max(precos),
        "sugestao": round(statistics.median(precos), 2),
        "confianca": confianca(len(precos)),
        "n_fontes": len(precos),
    }
    print(json.dumps(out, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
