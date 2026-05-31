#!/usr/bin/env python3
"""
Clara · carteiro (bot Telegram externo, desacoplado do agente).

Roda como processo SEPARADO do claude. Sobrevive a restart/compactacao do agente:
- recebe mensagem -> reage 👀 -> guarda em inbox/<id>.json -> injeta no agente via tmux send-keys
- varre outbox/<id>.json (a Clara escreve ali a resposta) -> envia -> move pra sent/
Nada se perde se o agente estiver ocupado/reiniciando.

Tudo GRATIS por padrao:
- voz de saida usa o tts local (Google · tools/tts/say.py), NUNCA ElevenLabs.
- voz de entrada (Whisper local) so liga com VOICE_IN=1 (pesa em VPS pequena).

Usa so `requests` (ja na imagem) + Telegram Bot API crua. Sem deps novas.
"""
import os, sys, json, time, threading, subprocess
from pathlib import Path
import requests

TOKEN = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
if not TOKEN:
    print("FATAL: TELEGRAM_BOT_TOKEN ausente", flush=True); sys.exit(1)
API = f"https://api.telegram.org/bot{TOKEN}"
FILE_API = f"https://api.telegram.org/file/bot{TOKEN}"

TMUX = os.environ.get("TMUX_SESSION", "clara")
WORKSPACE = os.environ.get("WORKSPACE_DIR", "/workspace")
TTS_TOOL = Path(WORKSPACE) / "tools" / "tts" / "say.py"
VOICE_IN = os.environ.get("VOICE_IN", "0") == "1"

CHANNEL_DIR = Path(os.environ.get("TELEGRAM_STATE_DIR", "/root/.claude/channels/telegram-clara"))
INBOX, OUTBOX, SENT = CHANNEL_DIR / "inbox", CHANNEL_DIR / "outbox", CHANNEL_DIR / "sent"
AUDIO, STATE, LOGS = CHANNEL_DIR / "audio", CHANNEL_DIR / "state", CHANNEL_DIR / "logs"
ACCESS = CHANNEL_DIR / "access.json"
OFFSET_FILE = STATE / "last-update-id.txt"
LOG = LOGS / "bot.log"
for d in (INBOX, OUTBOX, SENT, AUDIO, STATE, LOGS):
    d.mkdir(parents=True, exist_ok=True)


def log(msg):
    line = f"{time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())} {msg}"
    print(line, flush=True)
    try:
        with open(LOG, "a") as f:
            f.write(line + "\n")
    except Exception:
        pass


def api(method, **params):
    try:
        return requests.post(f"{API}/{method}", json=params, timeout=65).json()
    except Exception as e:
        log(f"api {method} erro: {e}")
        return {"ok": False}


# ---------- allowlist / pairing ----------
def load_access():
    try:
        return json.loads(ACCESS.read_text())
    except Exception:
        return {"dmPolicy": "pairing", "allowFrom": [], "groups": {}, "pending": {}}


def is_allowed(uid):
    a = load_access()
    allow = [str(x) for x in a.get("allowFrom", [])]
    if allow:
        return str(uid) in allow
    # allowFrom vazio = pareia o primeiro que falar (o dono) e trava nele
    a.setdefault("allowFrom", []).append(str(uid))
    try:
        ACCESS.write_text(json.dumps(a, ensure_ascii=False, indent=2))
        log(f"pairing: dono travado = {uid}")
    except Exception as e:
        log(f"pairing save erro: {e}")
    return True


# ---------- offset ----------
def get_offset():
    try:
        return int(OFFSET_FILE.read_text().strip())
    except Exception:
        return 0


def set_offset(v):
    try:
        OFFSET_FILE.write_text(str(v))
    except Exception:
        pass


# ---------- injeta no agente (tmux) ----------
def inject(text, msg_id, voice=False, extra=""):
    prefix = f"[telegram msg_id={msg_id}]"
    if voice:
        prefix += " [voice]"
    if extra:
        prefix += f" {extra}"
    payload = f"{prefix} {text}".strip()
    subprocess.run(["tmux", "send-keys", "-t", TMUX, "-l", payload], check=False)
    time.sleep(0.3)
    subprocess.run(["tmux", "send-keys", "-t", TMUX, "Enter"], check=False)


def download_file(file_id, dest):
    j = api("getFile", file_id=file_id)
    if not j.get("ok"):
        return None
    try:
        r = requests.get(f"{FILE_API}/{j['result']['file_path']}", timeout=60)
        Path(dest).write_bytes(r.content)
        return str(dest)
    except Exception as e:
        log(f"download erro: {e}")
        return None


def transcribe(ogg):
    if not VOICE_IN or not ogg:
        return None
    try:
        out = AUDIO / "tx"
        out.mkdir(exist_ok=True)
        subprocess.run(["whisper", str(ogg), "--language", "pt", "--model", "small",
                        "--output_format", "txt", "--output_dir", str(out)],
                       capture_output=True, timeout=180)
        txt = out / (Path(ogg).stem + ".txt")
        return txt.read_text().strip() if txt.exists() else None
    except Exception as e:
        log(f"whisper erro: {e}")
        return None


# ---------- inbound ----------
def handle(update):
    msg = update.get("message") or update.get("edited_message")
    if not msg:
        return
    uid = (msg.get("from") or {}).get("id")
    if not uid or not is_allowed(uid):
        log(f"drop user nao autorizado: {uid}")
        return
    msg_id, chat_id = msg["message_id"], msg["chat"]["id"]
    rec = {"msg_id": msg_id, "chat_id": chat_id, "user_id": uid,
           "received_at": time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())}
    api("setMessageReaction", chat_id=chat_id, message_id=msg_id,
        reaction=[{"type": "emoji", "emoji": "👀"}])

    if msg.get("text"):
        rec["text"] = msg["text"]
        inject(msg["text"], msg_id)
    elif msg.get("voice") or msg.get("audio"):
        fid = (msg.get("voice") or msg.get("audio"))["file_id"]
        ogg = download_file(fid, AUDIO / f"in_{msg_id}.ogg")
        tx = transcribe(ogg)
        if tx:
            rec.update(voice=True, text=tx)
            inject(tx, msg_id, voice=True)
        else:
            api("sendMessage", chat_id=chat_id, reply_to_message_id=msg_id,
                text="Recebi seu áudio, mas tô configurada pra texto. Me manda escrito?")
            return
    elif msg.get("photo"):
        p = download_file(msg["photo"][-1]["file_id"], AUDIO / f"photo_{msg_id}.jpg")
        cap = msg.get("caption", "[imagem sem legenda]")
        rec.update(text=cap, photo_path=p)
        inject(cap, msg_id, extra=f"[photo at {p}]")
    elif msg.get("document"):
        d = msg["document"]
        name = d.get("file_name", "file").replace("/", "_")
        p = download_file(d["file_id"], AUDIO / f"doc_{msg_id}_{name}")
        cap = msg.get("caption", "[documento]")
        rec.update(text=cap, doc_path=p)
        inject(cap, msg_id, extra=f"[document at {p}]")
    else:
        log(f"tipo nao suportado msg {msg_id}")
        return

    (INBOX / f"{msg_id}.json").write_text(json.dumps(rec, ensure_ascii=False, indent=2))
    log(f"inbox {msg_id}")


def poll_loop():
    log("poll loop on")
    offset = get_offset()
    backoff = 3
    while True:
        try:
            j = requests.get(f"{API}/getUpdates",
                             params={"offset": offset + 1, "timeout": 30}, timeout=40).json()
            if not j.get("ok"):
                time.sleep(backoff)
                backoff = min(backoff * 2, 60)
                continue
            backoff = 3
            for upd in j["result"]:
                offset = upd["update_id"]
                set_offset(offset)
                try:
                    handle(upd)
                except Exception as e:
                    log(f"handle erro: {e}")
        except requests.exceptions.Timeout:
            continue
        except Exception as e:
            log(f"poll erro: {e}")
            time.sleep(backoff)
            backoff = min(backoff * 2, 60)


# ---------- outbound (a Clara escreve em outbox/<id>.json) ----------
def voice_ogg(text):
    """Sintetiza voz com o tts local (Google grátis). Retorna caminho do .ogg ou None."""
    try:
        out = AUDIO / f"out_{int(time.time() * 1000)}.ogg"
        r = subprocess.run(["python3", str(TTS_TOOL), text, "--out", str(out), "--engine", "google"],
                           capture_output=True, text=True, timeout=120)
        if out.exists() and out.stat().st_size > 0:
            return out
        log(f"tts falhou: {r.stderr[:200]}")
    except Exception as e:
        log(f"tts erro: {e}")
    return None


def send_one(f):
    data = json.loads(f.read_text())
    chat_id = data["chat_id"]
    kwargs = {"chat_id": chat_id}
    if data.get("reply_to_message_id"):
        kwargs["reply_to_message_id"] = data["reply_to_message_id"]

    # reação pura (sem texto)
    if data.get("react"):
        api("setMessageReaction", chat_id=chat_id, message_id=data["react"]["message_id"],
            reaction=[{"type": "emoji", "emoji": data["react"].get("emoji", "👀")}])
        if not data.get("text"):
            return True

    text = data.get("text", "")
    if data.get("voice") and text:
        ogg = voice_ogg(text)
        if ogg:
            with open(ogg, "rb") as vf:
                r = requests.post(f"{API}/sendVoice", data=kwargs,
                                  files={"voice": vf}, timeout=120).json()
            return r.get("ok", False)
        # fallback: manda texto se a voz falhar
    r = api("sendMessage", text=text, **kwargs)
    return r.get("ok", False)


def outbox_loop():
    log("outbox loop on")
    while True:
        try:
            for f in sorted(OUTBOX.glob("*.json")):
                try:
                    if send_one(f):
                        f.rename(SENT / f.name)
                        log(f"sent {f.name}")
                    else:
                        (OUTBOX / "errors").mkdir(exist_ok=True)
                        f.rename(OUTBOX / "errors" / f.name)
                        log(f"falha enviar {f.name}")
                except Exception as e:
                    log(f"outbox item {f.name} erro: {e}")
                    (OUTBOX / "errors").mkdir(exist_ok=True)
                    try:
                        f.rename(OUTBOX / "errors" / f.name)
                    except Exception:
                        pass
        except Exception as e:
            log(f"outbox loop erro: {e}")
        time.sleep(2)


def main():
    log(f"carteiro Clara iniciando · tmux={TMUX} · voice_in={VOICE_IN}")
    threading.Thread(target=outbox_loop, daemon=True).start()
    poll_loop()


if __name__ == "__main__":
    main()
