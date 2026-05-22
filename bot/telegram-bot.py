#!/usr/bin/env python3
"""
Naia Telegram Bot - External daemon
Independente do Claude Code. NUNCA morre quando Claude reinicia.
- Recebe msgs via long polling (resilient)
- Salva em inbox/, notifica Naia via tmux send-keys
- Watch outbox/ e envia respostas via API
"""
import os, json, time, logging, signal, sys, subprocess, threading, re, hashlib, secrets
from pathlib import Path
from datetime import datetime, timezone
import requests

BOT_DIR = Path(os.environ.get('BOT_DIR', '/opt/naia-bot'))
INBOX = BOT_DIR / 'inbox'
OUTBOX = BOT_DIR / 'outbox'
SENT = BOT_DIR / 'sent'
PROCESSED = BOT_DIR / 'processed'
STATE = BOT_DIR / 'state'
LOGS = BOT_DIR / 'logs'
ENV_FILE = BOT_DIR / '.env'

env = {}
if ENV_FILE.exists():
    for line in ENV_FILE.read_text().split('\n'):
        if '=' in line and not line.startswith('#'):
            k, v = line.split('=', 1)
            env[k.strip()] = v.strip()

TOKEN = env.get('TELEGRAM_BOT_TOKEN') or os.environ.get('TELEGRAM_BOT_TOKEN')
if not TOKEN:
    sys.exit('TELEGRAM_BOT_TOKEN missing')

ALLOWED_USERS = set(env.get('ALLOWED_USERS', '629399338').split(','))
TMUX_SESSION = env.get('TMUX_SESSION', 'naia')
TMUX_USER = env.get('TMUX_USER', 'naia')

for d in (INBOX, OUTBOX, SENT, PROCESSED, STATE, LOGS):
    d.mkdir(parents=True, exist_ok=True)

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[logging.FileHandler(LOGS / 'bot.log'), logging.StreamHandler()]
)
log = logging.getLogger(__name__)

API = f'https://api.telegram.org/bot{TOKEN}'
OPENAI_KEY = env.get('OPENAI_API_KEY') or os.environ.get('OPENAI_API_KEY', '')
ELEVENLABS_KEY = env.get('ELEVENLABS_API_KEY') or os.environ.get('ELEVENLABS_API_KEY', '')
ELEVENLABS_VOICE = env.get('ELEVENLABS_VOICE_ID') or os.environ.get('ELEVENLABS_VOICE_ID', '21m00Tcm4TlvDq8ikWAM')
AUDIO_IN = BOT_DIR / 'audio' / 'incoming'
AUDIO_OUT = BOT_DIR / 'audio' / 'outgoing'
AUDIO_IN.mkdir(parents=True, exist_ok=True)
AUDIO_OUT.mkdir(parents=True, exist_ok=True)

# Comandos CRITICOS que disparam botao no Telegram em vez de auto-aprovar
CRITICAL_PATTERNS = [
    r'rm\s+-rf\s+/(?!tmp|home/[^/]+/[^/]+)',  # rm -rf em raiz
    r'rm\s+-rf\s+--no-preserve-root',
    r'DROP\s+DATABASE',
    r'DROP\s+TABLE',
    r'DROP\s+SCHEMA',
    r'TRUNCATE\s+TABLE',
    r'DELETE\s+FROM\s+\w+\s*;',  # delete sem WHERE
    r'git\s+push.*--force',
    r'git\s+push\s+-f\s',
    r'git\s+reset\s+--hard',
    r'systemctl\s+stop\s+(?!naia)',  # stop services exceto naia mesmo
    r'shutdown',
    r'reboot',
    r'>\s*/dev/sd[a-z]',  # write em disco fisico
    r'mkfs',  # format
    r'dd\s+.*of=/dev',
    r'chmod\s+-R\s+777\s+/',
    r'pkill\s+-9\s+-u\s+(?!naia)',
    r'kill\s+-9\s+-1',
]

PENDING_APPROVALS_FILE = STATE / 'pending-approvals.json'
critical_seen_hashes = {}  # hash -> timestamp para nao spamar

def load_pending():
    try:
        return json.loads(PENDING_APPROVALS_FILE.read_text())
    except: return {}

def save_pending(p):
    PENDING_APPROVALS_FILE.write_text(json.dumps(p, indent=2))

def is_critical_command(tmux_tail):
    for pattern in CRITICAL_PATTERNS:
        if re.search(pattern, tmux_tail, re.IGNORECASE):
            return True
    return False

def extract_command_from_prompt(tmux_tail):
    """Extrai descricao do comando do prompt do Claude Code"""
    lines = tmux_tail.split('\n')
    cmd_lines = []
    for line in lines:
        if 'Do you want to' in line:
            break
        if line.strip():
            cmd_lines.append(line.strip())
    # Pega ultimas 12 linhas antes do prompt
    return '\n'.join(cmd_lines[-12:])

def request_user_approval(tmux_tail):
    """Envia mensagem com inline keyboard pro user"""
    cmd = extract_command_from_prompt(tmux_tail)
    request_id = secrets.token_hex(4)
    pending = load_pending()
    pending[request_id] = {
        'cmd': cmd[:2000],
        'created_at': time.time()
    }
    save_pending(pending)

    chat_id = int(list(ALLOWED_USERS)[0])
    text = f'⚠️ APROVACAO NECESSARIA (comando critico detectado)\n\n'
    payload = {
        'chat_id': chat_id,
        'text': text,
        'parse_mode': 'Markdown',
        'reply_markup': {
            'inline_keyboard': [[
                {'text': '✅ Aprovar', 'callback_data': f'apv:{request_id}'},
                {'text': '❌ Negar', 'callback_data': f'dny:{request_id}'}
            ]]
        }
    }
    try:
        r = requests.post(f'{API}/sendMessage', json=payload, timeout=10)
        log.info(f'aprovacao solicitada req_id={request_id} status={r.status_code}')
    except Exception as e:
        log.error(f'request_user_approval error: {e}')

def handle_callback(callback_query):
    """Processa clique do user no botao Aprovar/Negar"""
    data = callback_query.get('data', '')
    cb_id = callback_query.get('id', '')
    user_id = str(callback_query.get('from', {}).get('id', ''))

    if user_id not in ALLOWED_USERS:
        log.warning(f'callback de user nao autorizado: {user_id}')
        return

    if not data.startswith(('apv:', 'dny:')):
        try:
            requests.post(f'{API}/answerCallbackQuery',
                json={'callback_query_id': cb_id}, timeout=5)
        except: pass
        return

    action, req_id = data.split(':', 1)
    pending = load_pending()

    if req_id not in pending:
        try:
            requests.post(f'{API}/answerCallbackQuery',
                json={'callback_query_id': cb_id, 'text': 'Aprovacao expirada ou ja processada'}, timeout=5)
        except: pass
        return

    # Manda decisao pro tmux
    send_key = '1' if action == 'apv' else '3'  # 1=Yes, 3=No (padrao Claude Code)
    try:
        subprocess.run(['tmux', 'send-keys', '-t', TMUX_SESSION, send_key],
            timeout=3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        time.sleep(0.3)
        subprocess.run(['tmux', 'send-keys', '-t', TMUX_SESSION, 'C-m'],
            timeout=3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        log.info(f'callback {action} req_id={req_id} enviado pro tmux')
    except Exception as e:
        log.error(f'send_key error: {e}')

    del pending[req_id]
    save_pending(pending)

    # Edita msg pra mostrar decisao
    msg = callback_query.get('message', {})
    if msg:
        new_text = msg.get('text', '') + ('\n\n✅ APROVADO' if action == 'apv' else '\n\n❌ NEGADO')
        try:
            requests.post(f'{API}/editMessageText', json={
                'chat_id': msg['chat']['id'],
                'message_id': msg['message_id'],
                'text': new_text[:4000]
            }, timeout=5)
        except: pass

    try:
        requests.post(f'{API}/answerCallbackQuery', json={
            'callback_query_id': cb_id,
            'text': '✅ Aprovado' if action == 'apv' else '❌ Negado'
        }, timeout=5)
    except: pass

# Typing indicator: chat_id -> timestamp ate quando manter typing ativo
typing_until = {}
typing_lock = threading.Lock()
running = True

def signal_handler(sig, frame):
    global running
    log.info(f'Signal {sig} - parando graciosamente')
    running = False

signal.signal(signal.SIGTERM, signal_handler)
signal.signal(signal.SIGINT, signal_handler)
signal.signal(signal.SIGHUP, signal_handler)

def get_offset():
    f = STATE / 'last-update-id.txt'
    return int(f.read_text().strip()) + 1 if f.exists() else 0

def save_offset(uid):
    (STATE / 'last-update-id.txt').write_text(str(uid))

def notify_naia(msg_id, text, user):
    try:
        # Escapa aspas e quebras de linha pra tmux
        safe = text.replace('\\', '\\\\').replace('"', '\\"').replace('\n', ' ')
        if len(safe) > 4000:
            safe = safe[:4000] + '...'
        prompt = f'[telegram from {user} msg_id={msg_id}] {safe}'
        # Manda texto literal e depois Enter separado (mais confiavel)
        subprocess.run(
            ['tmux', 'send-keys', '-t', TMUX_SESSION, '-l', prompt],
            check=False, timeout=5,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        time.sleep(0.3)  # tmux precisa de um pouco pra registrar input
        subprocess.run(
            ['tmux', 'send-keys', '-t', TMUX_SESSION, 'C-m'],
            check=False, timeout=5,
            stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL
        )
        log.info(f'Naia notificada msg_id={msg_id}')
    except Exception as e:
        log.error(f'notify_naia error: {e}')

def react(chat_id, msg_id, emoji='👀'):
    try:
        requests.post(f'{API}/setMessageReaction', json={
            'chat_id': chat_id, 'message_id': msg_id,
            'reaction': [{'type': 'emoji', 'emoji': emoji}]
        }, timeout=5)
    except Exception:
        pass

def start_typing(chat_id, duration=600):
    with typing_lock:
        typing_until[int(chat_id)] = time.time() + duration

def stop_typing(chat_id):
    with typing_lock:
        typing_until.pop(int(chat_id), None)

def auto_approve_loop():
    """A cada 5s, checa tmux da Naia e se houver prompt interativo, auto-aprova."""
    log.info('auto-approve loop iniciado (5s interval)')
    last_approved = 0
    while running:
        try:
            r = subprocess.run(
                ['tmux', 'capture-pane', '-t', TMUX_SESSION, '-p'],
                capture_output=True, text=True, timeout=3
            )
            tail = '\n'.join(r.stdout.split('\n')[-15:])
            now = time.time()
            # Detecta prompts comuns do Claude Code
            patterns = ['Do you want to', '1. Yes', '❯ 1.', 'Yes, and allow Claude', 'Esc to cancel']
            if any(p in tail for p in patterns) and (now - last_approved) > 10:
                if is_critical_command(tail):
                    cmd_hash = hashlib.md5(tail.encode()).hexdigest()[:12]
                    if cmd_hash not in critical_seen_hashes or (now - critical_seen_hashes[cmd_hash]) > 60:
                        log.warning('PROMPT CRITICO - solicitando aprovacao do user via botao')
                        request_user_approval(tail)
                        critical_seen_hashes[cmd_hash] = now
                else:
                    log.info('PROMPT comum detectado, auto-aprovando com 1+Enter')
                    subprocess.run(['tmux', 'send-keys', '-t', TMUX_SESSION, '1'],
                        timeout=3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    time.sleep(0.3)
                    subprocess.run(['tmux', 'send-keys', '-t', TMUX_SESSION, 'C-m'],
                        timeout=3, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
                    last_approved = now
        except Exception as e:
            log.debug(f'auto-approve error: {e}')
        time.sleep(5)

def typing_loop():
    log.info('typing indicator loop iniciado')
    while running:
        try:
            now = time.time()
            with typing_lock:
                active = [cid for cid, until in typing_until.items() if until > now]
                expired = [cid for cid, until in typing_until.items() if until <= now]
                for cid in expired:
                    del typing_until[cid]
            for cid in active:
                try:
                    requests.post(f'{API}/sendChatAction',
                        json={'chat_id': cid, 'action': 'typing'},
                        timeout=3)
                except Exception:
                    pass
        except Exception as e:
            log.debug(f'typing error: {e}')
        time.sleep(4)

def download_telegram_file(file_id, dest_dir, msg_id):
    """Baixa arquivo do Telegram. Retorna path ou None"""
    try:
        r = requests.get(f'{API}/getFile', params={'file_id': file_id}, timeout=10)
        if r.status_code != 200 or not r.json().get('ok'):
            log.error(f'getFile failed: {r.text[:200]}')
            return None
        fp = r.json()['result']['file_path']
        url = f'https://api.telegram.org/file/bot{TOKEN}/{fp}'
        ext = fp.split('.')[-1] if '.' in fp else 'ogg'
        dest = dest_dir / f'{msg_id}.{ext}'
        r2 = requests.get(url, timeout=30)
        if r2.status_code != 200:
            log.error(f'download failed: {r2.status_code}')
            return None
        dest.write_bytes(r2.content)
        log.info(f'audio baixado msg_id={msg_id} ({len(r2.content)} bytes)')
        return dest
    except Exception as e:
        log.error(f'download_telegram_file error: {e}')
        return None

def transcribe_whisper(audio_path):
    """Transcreve audio via OpenAI Whisper API. Retorna texto ou None"""
    if not OPENAI_KEY:
        log.error('OPENAI_API_KEY missing - cannot transcribe')
        return None
    try:
        with open(audio_path, 'rb') as f:
            files = {'file': (audio_path.name, f, 'audio/ogg')}
            data = {'model': 'whisper-1', 'language': 'pt'}
            r = requests.post(
                'https://api.openai.com/v1/audio/transcriptions',
                headers={'Authorization': f'Bearer {OPENAI_KEY}'},
                files=files, data=data, timeout=60
            )
        if r.status_code == 200:
            text = r.json().get('text', '').strip()
            log.info(f'whisper transcribed: {text[:100]}')
            return text
        else:
            log.error(f'whisper http {r.status_code}: {r.text[:200]}')
            return None
    except Exception as e:
        log.error(f'whisper error: {e}')
        return None

def synthesize_elevenlabs(text, msg_id):
    """Gera audio MP3 via ElevenLabs e converte pra OGG opus (formato Telegram voice).
    Retorna path do .ogg ou None"""
    if not ELEVENLABS_KEY:
        log.error('ELEVENLABS_API_KEY missing')
        return None
    try:
        url = f'https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE}'
        r = requests.post(url,
            headers={
                'xi-api-key': ELEVENLABS_KEY,
                'Content-Type': 'application/json',
                'Accept': 'audio/mpeg'
            },
            json={
                'text': text,
                'model_id': 'eleven_multilingual_v2',
                'voice_settings': {'stability': 0.5, 'similarity_boost': 0.75}
            },
            timeout=60
        )
        if r.status_code != 200:
            log.error(f'elevenlabs http {r.status_code}: {r.text[:200]}')
            return None
        mp3_path = AUDIO_OUT / f'{msg_id}.mp3'
        ogg_path = AUDIO_OUT / f'{msg_id}.ogg'
        mp3_path.write_bytes(r.content)
        # Converte mp3 -> ogg opus (formato voice do Telegram)
        result = subprocess.run(
            ['ffmpeg', '-y', '-i', str(mp3_path), '-c:a', 'libopus', '-b:a', '48k', str(ogg_path)],
            capture_output=True, timeout=30
        )
        if result.returncode != 0:
            log.error(f'ffmpeg failed: {result.stderr.decode()[:200]}')
            return None
        log.info(f'elevenlabs gerou audio: {ogg_path} ({ogg_path.stat().st_size} bytes)')
        return ogg_path
    except Exception as e:
        log.error(f'elevenlabs error: {e}')
        return None

def handle_update(update):
    msg = update.get('message') or update.get('edited_message')
    if not msg:
        return
    user_id = str(msg.get('from', {}).get('id', ''))
    if user_id not in ALLOWED_USERS:
        log.info(f'drop user nao autorizado: {user_id}')
        return
    msg_id = msg.get('message_id')
    chat_id = msg.get('chat', {}).get('id')
    text = msg.get('text') or msg.get('caption') or ''

    # Audio handling
    audio_file_id = None
    audio_kind = None
    for kind in ('voice', 'audio', 'video_note'):
        if kind in msg:
            audio_file_id = msg[kind].get('file_id')
            audio_kind = kind
            break
    audio_path = None
    transcript = None
    if audio_file_id:
        audio_path = download_telegram_file(audio_file_id, AUDIO_IN, msg.get('message_id'))
        if audio_path:
            transcript = transcribe_whisper(audio_path)
        if transcript:
            text = f'[{audio_kind}] {transcript}'
        elif not text:
            text = f'({audio_kind} - transcricao falhou)'
    if not text:
        text = '(non-text)' 
    user_name = msg.get('from', {}).get('first_name', user_id)
    
    inbox_file = INBOX / f'{msg_id}.json'
    inbox_data = {
        'msg_id': msg_id, 'chat_id': chat_id, 'user_id': user_id,
        'user_name': user_name, 'text': text,
        'timestamp': datetime.now(timezone.utc).isoformat(),
        'raw': msg
    }
    if audio_path:
        inbox_data['audio_file'] = str(audio_path)
        inbox_data['audio_kind'] = audio_kind
        inbox_data['transcript'] = transcript
    inbox_file.write_text(json.dumps(inbox_data, indent=2, ensure_ascii=False))
    log.info(f'msg recebida msg_id={msg_id} from={user_name}: {text[:80]}')
    
    react(chat_id, msg_id, '👀')
    start_typing(chat_id, duration=600)  # mantem digitando ate resposta
    notify_naia(msg_id, text, user_name)

def poll_loop():
    log.info('polling loop iniciado')
    backoff = 1
    while running:
        try:
            offset = get_offset()
            r = requests.get(f'{API}/getUpdates',
                params={'offset': offset, 'timeout': 30, 'limit': 100},
                timeout=35)
            if r.status_code != 200:
                log.warning(f'http {r.status_code}: {r.text[:200]}')
                time.sleep(backoff); backoff = min(backoff * 2, 60); continue
            data = r.json()
            if not data.get('ok'):
                log.warning(f'!ok: {data}')
                time.sleep(backoff); backoff = min(backoff * 2, 60); continue
            backoff = 1
            for update in data.get('result', []):
                if 'callback_query' in update:
                    handle_callback(update['callback_query'])
                else:
                    handle_update(update)
                save_offset(update['update_id'])
        except requests.exceptions.Timeout:
            continue
        except Exception as e:
            log.error(f'poll error: {e}')
            time.sleep(backoff); backoff = min(backoff * 2, 60)

def outbox_loop():
    log.info('outbox watcher iniciado')
    while running:
        try:
            for f in sorted(OUTBOX.glob('*.json')):
                try:
                    data = json.loads(f.read_text())
                    chat_id = data.get('chat_id', 629399338)
                    text = data.get('text', '')
                    reply_to = data.get('reply_to_message_id')
                    if not text:
                        log.warning(f'outbox {f.name} sem text, skip')
                        f.rename(f.with_suffix('.empty'))
                        continue
                    use_voice = data.get('voice') is True or data.get('audio') is True
                    if use_voice:
                        # Gera audio com ElevenLabs e envia como voice
                        ogg = synthesize_elevenlabs(text, f.stem)
                        if ogg:
                            with open(ogg, 'rb') as af:
                                files = {'voice': (ogg.name, af, 'audio/ogg')}
                                form = {'chat_id': chat_id}
                                if reply_to:
                                    form['reply_parameters'] = json.dumps({'message_id': int(reply_to)})
                                r = requests.post(f'{API}/sendVoice', data=form, files=files, timeout=30)
                        else:
                            log.warning(f'voice synthesis falhou, fallback texto: {f.name}')
                            payload = {'chat_id': chat_id, 'text': text}
                            if reply_to:
                                payload['reply_parameters'] = {'message_id': int(reply_to)}
                            r = requests.post(f'{API}/sendMessage', json=payload, timeout=10)
                    else:
                        payload = {'chat_id': chat_id, 'text': text}
                        if reply_to:
                            payload['reply_parameters'] = {'message_id': int(reply_to)}
                        r = requests.post(f'{API}/sendMessage', json=payload, timeout=10)
                    if r.status_code == 200 and r.json().get('ok'):
                        stop_typing(chat_id)
                        sent_file = SENT / f.name
                        sent_file.write_text(json.dumps({
                            **data,
                            'sent_at': datetime.now(timezone.utc).isoformat(),
                            'response': r.json().get('result', {})
                        }, indent=2, ensure_ascii=False))
                        f.unlink()
                        log.info(f'sent {f.name}')
                    else:
                        log.warning(f'send fail {f.name}: {r.text[:200]}')
                        f.rename(f.with_suffix('.failed'))
                except Exception as e:
                    log.error(f'outbox error {f.name}: {e}')
                    try: f.rename(f.with_suffix('.failed'))
                    except: pass
        except Exception as e:
            log.error(f'outbox loop error: {e}')
        time.sleep(2)

if __name__ == '__main__':
    log.info('=== Naia Telegram Bot iniciando ===')
    try:
        r = requests.get(f'{API}/getMe', timeout=10)
        info = r.json().get('result', {})
        log.info(f'bot: @{info.get("username")} ({info.get("first_name")})')
    except Exception as e:
        log.error(f'getMe falhou: {e}')
        sys.exit(1)
    
    threading.Thread(target=outbox_loop, daemon=True).start()
    threading.Thread(target=typing_loop, daemon=True).start()
    threading.Thread(target=auto_approve_loop, daemon=True).start()
    
    try:
        poll_loop()
    except KeyboardInterrupt:
        pass
    log.info('=== bot encerrado ===')
