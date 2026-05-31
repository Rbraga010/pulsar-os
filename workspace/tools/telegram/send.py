#!/usr/bin/env python3
"""
Clara responde pelo carteiro · escreve um bilhete (JSON) no outbox.
O daemon clara-bot.py varre o outbox a cada 2s e envia pro Telegram.

Uso:
  python3 tools/telegram/send.py --chat <chat_id> --text "resposta" [--reply-to <msg_id>] [--voice]
  python3 tools/telegram/send.py --chat <chat_id> --react 👀 --react-msg <msg_id>

Substitui o antigo plugin: a Clara nunca perde resposta mesmo se reiniciar no meio.
"""
import argparse, json, os, time
from pathlib import Path

CHANNEL_DIR = Path(os.environ.get("TELEGRAM_STATE_DIR", "/root/.claude/channels/telegram-clara"))
OUTBOX = CHANNEL_DIR / "outbox"


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--chat", required=True, help="chat_id de destino")
    p.add_argument("--text", default="", help="texto da resposta")
    p.add_argument("--reply-to", type=int, default=None, help="msg_id pra responder em thread")
    p.add_argument("--voice", action="store_true", help="enviar como áudio (tts Google grátis)")
    p.add_argument("--react", default=None, help="emoji de reação (ex: 👀)")
    p.add_argument("--react-msg", type=int, default=None, help="msg_id que vai receber a reação")
    a = p.parse_args()

    payload = {"chat_id": int(a.chat)}
    if a.text:
        payload["text"] = a.text
    if a.reply_to:
        payload["reply_to_message_id"] = a.reply_to
    if a.voice:
        payload["voice"] = True
    if a.react and a.react_msg:
        payload["react"] = {"message_id": a.react_msg, "emoji": a.react}

    OUTBOX.mkdir(parents=True, exist_ok=True)
    out = OUTBOX / f"{int(time.time() * 1000)}.json"
    out.write_text(json.dumps(payload, ensure_ascii=False))
    print(f"outbox: {out}")


if __name__ == "__main__":
    main()
