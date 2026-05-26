#!/usr/bin/env python3
"""
forecast · projeção de vendas dos próximos 4 períodos

Roda em cima da tabela `vendas` do SQLite local da Clara.
Usa média móvel ponderada (suavizada) sobre as últimas N semanas de dados.

Uso:
  python3 forecast.py [--db=/path/clara.db] [--horizonte=4] [--por=produto|categoria]

Output (stdout · 1 linha JSON):
  {
    "ok": true,
    "janela_historica_semanas": 8,
    "horizonte_semanas": 4,
    "itens": [
      {
        "chave": "Tênis Nike Air Force",
        "vendas_por_semana": [...],
        "media_movel": float,
        "tendencia": "subindo|estavel|caindo",
        "previsao_proximas_4_semanas": float,
        "estoque_atual": int,
        "sugestao_compra": int,
        "confianca": "alta|media|baixa"
      }
    ]
  }

Princípio:
- Clara NUNCA compra do fornecedor sem o lojista aprovar
- Tool só sugere · decisão final é humana
- Se não tem dado suficiente, retorna confianca=baixa + mensagem clara
"""

import argparse
import json
import sqlite3
import statistics
import sys
from datetime import datetime, timedelta
from pathlib import Path

DEFAULT_DB = "/workspace/data/clara.db"
ALT_DB = "/opt/clones/clara/workspace/data/clara.db"


def open_db(path: str) -> sqlite3.Connection:
    p = Path(path)
    if not p.exists():
        # tentativa fallback
        if path == DEFAULT_DB and Path(ALT_DB).exists():
            p = Path(ALT_DB)
        else:
            print(json.dumps({"ok": False, "erro": f"DB não existe em {path}"}, ensure_ascii=False))
            sys.exit(0)
    conn = sqlite3.connect(str(p))
    conn.row_factory = sqlite3.Row
    return conn


def week_of(iso_ts: str) -> str:
    """Retorna 'YYYY-Www' (segunda-feira da semana ISO)"""
    dt = datetime.fromisoformat(iso_ts.replace("Z", "+00:00")) if "T" in iso_ts else datetime.strptime(iso_ts[:10], "%Y-%m-%d")
    iso = dt.isocalendar()
    return f"{iso[0]}-W{iso[1]:02d}"


def fetch_vendas(conn: sqlite3.Connection, por: str, semanas_back: int = 8) -> dict:
    """
    Retorna {chave: {semana: qtd_vendida}}
    chave = produto_nome OR categoria
    """
    cutoff = (datetime.utcnow() - timedelta(weeks=semanas_back)).isoformat(timespec="seconds")
    coluna_chave = "produto_nome" if por == "produto" else "categoria"

    rows = conn.execute(
        f"""
        SELECT {coluna_chave} AS chave, qtd, vendida_em
        FROM vendas
        WHERE vendida_em >= ? AND {coluna_chave} IS NOT NULL AND {coluna_chave} != ''
        """,
        (cutoff,),
    ).fetchall()

    by_key: dict[str, dict[str, int]] = {}
    for r in rows:
        chave = r["chave"]
        semana = week_of(r["vendida_em"])
        by_key.setdefault(chave, {}).setdefault(semana, 0)
        by_key[chave][semana] += r["qtd"]
    return by_key


def estoque(conn: sqlite3.Connection, chave: str, por: str) -> int:
    if por == "produto":
        row = conn.execute(
            "SELECT COALESCE(SUM(estoque), 0) AS e FROM produtos_loja WHERE nome = ? AND ativo = 1",
            (chave,),
        ).fetchone()
    else:
        row = conn.execute(
            "SELECT COALESCE(SUM(estoque), 0) AS e FROM produtos_loja WHERE categoria = ? AND ativo = 1",
            (chave,),
        ).fetchone()
    return int(row["e"] or 0)


def tendencia(semanas: list[int]) -> str:
    if len(semanas) < 3:
        return "estavel"
    primeira_metade = statistics.mean(semanas[: len(semanas) // 2])
    segunda_metade = statistics.mean(semanas[len(semanas) // 2:])
    if segunda_metade > primeira_metade * 1.15:
        return "subindo"
    if segunda_metade < primeira_metade * 0.85:
        return "caindo"
    return "estavel"


def media_movel_ponderada(serie: list[int], janela: int = 4) -> float:
    """Pondera mais as semanas recentes."""
    s = serie[-janela:] if len(serie) >= janela else serie
    if not s:
        return 0.0
    pesos = list(range(1, len(s) + 1))  # 1, 2, 3, 4 (mais recente = maior peso)
    return sum(v * p for v, p in zip(s, pesos)) / sum(pesos)


def confianca(n_semanas: int) -> str:
    if n_semanas >= 6:
        return "alta"
    if n_semanas >= 3:
        return "media"
    return "baixa"


def main() -> int:
    parser = argparse.ArgumentParser(description="Projeta venda dos próximos N períodos")
    parser.add_argument("--db", default=DEFAULT_DB, help="path do SQLite")
    parser.add_argument("--horizonte", type=int, default=4, help="quantas semanas projetar")
    parser.add_argument("--por", choices=["produto", "categoria"], default="produto")
    parser.add_argument("--janela", type=int, default=8, help="quantas semanas históricas considerar")
    args = parser.parse_args()

    conn = open_db(args.db)
    by_key = fetch_vendas(conn, args.por, args.janela)

    if not by_key:
        print(json.dumps({
            "ok": True,
            "itens": [],
            "alerta": "Sem vendas registradas nos últimos {} semanas. Registre vendas no CRM (tabela 'vendas') pra Clara projetar.".format(args.janela),
        }, ensure_ascii=False))
        return 0

    # ordena semanas
    todas_semanas = sorted({s for v in by_key.values() for s in v.keys()})

    itens = []
    for chave, semanas_dict in by_key.items():
        serie = [semanas_dict.get(s, 0) for s in todas_semanas]
        m = media_movel_ponderada(serie, janela=4)
        previsao = round(m * args.horizonte, 1)
        n_sem = sum(1 for v in serie if v > 0)
        est = estoque(conn, chave, args.por)
        gap = max(0, int(previsao) - est)
        itens.append({
            "chave": chave,
            "vendas_por_semana": serie,
            "media_movel": round(m, 2),
            "tendencia": tendencia(serie),
            "previsao_proximas_{}_semanas".format(args.horizonte): previsao,
            "estoque_atual": est,
            "sugestao_compra": gap,
            "confianca": confianca(n_sem),
        })

    # ordena por previsao descrescente (mais relevantes em cima)
    itens.sort(key=lambda x: x["previsao_proximas_{}_semanas".format(args.horizonte)], reverse=True)

    print(json.dumps({
        "ok": True,
        "janela_historica_semanas": args.janela,
        "horizonte_semanas": args.horizonte,
        "por": args.por,
        "n_itens": len(itens),
        "itens": itens,
    }, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
