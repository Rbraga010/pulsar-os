#!/usr/bin/env python3
"""
Clara · helper de query no SQLite local.

Uso:
    python3 query.py "<SELECT ...>"
    python3 query.py --json "<SELECT ...>"
    python3 query.py --exec "<INSERT/UPDATE/DELETE>"

Stdout retorna resultado tabular (default) ou JSON (com --json).
"""

import sys
import os
import json
import sqlite3
import argparse


DB_PATH = "/opt/clones/clara/workspace/data/clara.db"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("sql", help="SQL a executar")
    parser.add_argument("--json", action="store_true", help="saída JSON")
    parser.add_argument("--exec", dest="exec_mode", action="store_true",
                        help="INSERT/UPDATE/DELETE (commit · sem fetchall)")
    parser.add_argument("--db", default=DB_PATH, help=f"Path DB (default {DB_PATH})")
    args = parser.parse_args()

    if not os.path.exists(args.db):
        print(json.dumps({"ok": False, "error": "db_not_initialized", "hint": "rode init.sh primeiro"}))
        sys.exit(3)

    conn = sqlite3.connect(args.db)
    conn.row_factory = sqlite3.Row
    cur = conn.cursor()

    try:
        cur.execute(args.sql)
        if args.exec_mode:
            conn.commit()
            print(json.dumps({
                "ok": True,
                "rowcount": cur.rowcount,
                "lastrowid": cur.lastrowid,
            }))
        else:
            rows = [dict(r) for r in cur.fetchall()]
            if args.json:
                print(json.dumps({"ok": True, "rows": rows, "count": len(rows)}, ensure_ascii=False, indent=2))
            else:
                if not rows:
                    print("(sem resultados)")
                else:
                    cols = list(rows[0].keys())
                    print(" | ".join(cols))
                    print("-+-".join("-" * len(c) for c in cols))
                    for r in rows:
                        print(" | ".join(str(r[c]) for c in cols))
    except sqlite3.Error as e:
        print(json.dumps({"ok": False, "error": str(e), "sql": args.sql}))
        sys.exit(1)
    finally:
        conn.close()


if __name__ == "__main__":
    main()
