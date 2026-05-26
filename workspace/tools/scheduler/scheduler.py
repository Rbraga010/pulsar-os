#!/usr/bin/env python3
"""
Clara · Scheduler
Daemon que varre `posts_agendados` no SQLite, renderiza (carousel-renderer)
e publica no canal certo (IG Graph, WhatsApp Status, GMB).

Uso:
    python3 scheduler.py            # daemon (loop infinito · interval check 60s)
    python3 scheduler.py --once     # processa 1x e sai
    python3 scheduler.py --dry-run  # mostra o que faria, sem executar

Pode rodar como systemd service (ver `clara-scheduler.service` em README).
"""

import os
import sys
import json
import argparse
import sqlite3
import subprocess
import time
import logging
from datetime import datetime, timezone

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s",
)
log = logging.getLogger("clara-scheduler")

DB_PATH = "/opt/clones/clara/workspace/data/clara.db"
TOOLS_DIR = "/opt/clones/clara/workspace/tools"
RENDER_OUT_BASE = "/opt/clones/clara/workspace/data/renders"
TICK_SECONDS = 60


def now_iso():
    return datetime.now(timezone.utc).astimezone().isoformat(timespec="seconds")


def db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def pick_due_posts(conn, lookahead_seconds=120):
    """Posts agendados que devem rodar agora (ou no próximo tick)."""
    cur = conn.cursor()
    cur.execute(
        """
        SELECT * FROM posts_agendados
        WHERE status IN ('agendado', 'pronto')
          AND agendado_para <= datetime('now', ?)
        ORDER BY agendado_para
        LIMIT 5
        """,
        (f"+{lookahead_seconds} seconds",),
    )
    return [dict(r) for r in cur.fetchall()]


def update_post(conn, post_id, **fields):
    fields["updated_at"] = now_iso()
    keys = ", ".join(f"{k} = ?" for k in fields)
    values = list(fields.values()) + [post_id]
    conn.execute(f"UPDATE posts_agendados SET {keys} WHERE id = ?", values)
    conn.commit()


def render_carousel(post, dry_run=False):
    """Invoca carousel-renderer/render.js · retorna lista de paths PNG."""
    template = post.get("template")
    data_json = post.get("data_json")
    if not template or not data_json:
        return {"ok": False, "error": "missing_template_or_data"}

    template_path = os.path.join(TOOLS_DIR, "carousel-renderer", "templates", f"{template}.html")
    if not os.path.exists(template_path):
        return {"ok": False, "error": "template_not_found", "template": template_path}

    out_dir = os.path.join(RENDER_OUT_BASE, f"post-{post['id']}")
    data_file = os.path.join(out_dir, "data.json")
    os.makedirs(out_dir, exist_ok=True)
    with open(data_file, "w", encoding="utf-8") as f:
        f.write(data_json)

    cmd = [
        "node",
        os.path.join(TOOLS_DIR, "carousel-renderer", "render.js"),
        template_path,
        data_file,
        out_dir,
    ]
    if dry_run:
        log.info("[dry-run] rodaria: %s", " ".join(cmd))
        return {"ok": True, "dry_run": True, "paths": []}

    env = os.environ.copy()
    env.setdefault("PUPPETEER_EXECUTABLE_PATH", "/usr/bin/chromium-browser")

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=180, env=env)
        if result.returncode != 0:
            return {"ok": False, "error": "render_failed", "stderr": result.stderr.strip()[:500]}
        paths = [p for p in result.stdout.strip().splitlines() if p]
        return {"ok": True, "paths": paths}
    except subprocess.TimeoutExpired:
        return {"ok": False, "error": "render_timeout"}


def publish(post, midias, dry_run=False):
    """
    Publica em canal apropriado.
    Hoje: STUB pra cada canal (precisa OAuth). Retorna ok=False com hint
    informativo até lojista autenticar.
    """
    canal = post["canal"]
    log.info("publish canal=%s midias=%d post_id=%s", canal, len(midias), post["id"])

    if dry_run:
        return {"ok": True, "dry_run": True, "would_publish_on": canal}

    if canal == "instagram":
        return {
            "ok": False,
            "error": "ig_oauth_pending",
            "hint": "Lojista precisa configurar IG_USER_ID + IG_ACCESS_TOKEN no .env (ver tools/ig-graph/README.md)",
        }
    if canal == "whatsapp_status":
        return {
            "ok": False,
            "error": "wa_session_pending",
            "hint": "Lojista precisa parear via tools/whatsapp-baileys/pair.js",
        }
    if canal == "gmb":
        return {
            "ok": False,
            "error": "gmb_oauth_pending",
            "hint": "Lojista precisa OAuth no Google Cloud (ver tools/gmb/README.md)",
        }
    return {"ok": False, "error": "canal_unknown", "canal": canal}


def process_post(conn, post, dry_run=False):
    log.info("processando post id=%s canal=%s agendado=%s", post["id"], post["canal"], post["agendado_para"])

    # 1. render se ainda não rendou
    midias_paths = post.get("midias_paths")
    if not midias_paths or post["status"] != "pronto":
        update_post(conn, post["id"], status="rendering")
        render_res = render_carousel(post, dry_run=dry_run)
        if not render_res.get("ok"):
            update_post(conn, post["id"], status="falhou", erro=json.dumps(render_res))
            log.error("render falhou post=%s err=%s", post["id"], render_res)
            return
        midias_paths = json.dumps(render_res["paths"])
        update_post(conn, post["id"], midias_paths=midias_paths, status="pronto")

    # 2. publicar
    paths = json.loads(midias_paths) if midias_paths else []
    pub_res = publish(post, paths, dry_run=dry_run)
    if pub_res.get("ok"):
        update_post(conn, post["id"], status="publicado", posted_media_id=pub_res.get("media_id"), published_at=now_iso())
        log.info("publicado post=%s media_id=%s", post["id"], pub_res.get("media_id"))
    else:
        update_post(conn, post["id"], status="falhou", erro=json.dumps(pub_res))
        log.warning("publicação pendente post=%s err=%s", post["id"], pub_res.get("error"))


def tick(dry_run=False):
    conn = db()
    try:
        due = pick_due_posts(conn)
        if not due:
            log.debug("nenhum post devido")
            return 0
        for post in due:
            process_post(conn, post, dry_run=dry_run)
        return len(due)
    finally:
        conn.close()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--once", action="store_true", help="processa 1x e sai")
    parser.add_argument("--dry-run", action="store_true", help="mostra o que faria")
    parser.add_argument("--interval", type=int, default=TICK_SECONDS, help=f"intervalo em segundos (default {TICK_SECONDS})")
    args = parser.parse_args()

    if not os.path.exists(DB_PATH):
        log.error("DB não inicializado em %s · rode `bash tools/db/init.sh`", DB_PATH)
        sys.exit(2)

    if args.once:
        n = tick(dry_run=args.dry_run)
        log.info("tick único · %d post(s) processado(s)", n)
        return

    log.info("scheduler ON · interval=%ds dry_run=%s", args.interval, args.dry_run)
    while True:
        try:
            tick(dry_run=args.dry_run)
        except Exception as e:
            log.exception("erro no tick: %s", e)
        time.sleep(args.interval)


if __name__ == "__main__":
    main()
