#!/usr/bin/env python3
"""say.py · Clara · text-to-speech em PT-BR voz feminina.

Default: Google Cloud TTS (voz pt-BR-Chirp3-HD-Kore · grátis até 4M chars/mês).
Fallback: OpenAI TTS (modelo tts-1 · voz nova · pago baratinho).

Uso:
    python3 tools/tts/say.py "<texto>" [--voice=Kore|Charon|Aoede] [--out=path.ogg] [--engine=google|openai] [--first-run]

Saída: OGG/Opus (nativo do voice note Telegram).
Path do arquivo gerado vai pro stdout (1 linha · pra Clara consumir). Logs vão pro stderr.
"""
from __future__ import annotations

import argparse
import base64
import json
import os
import sys
from datetime import datetime
from pathlib import Path

WORKSPACE = Path("/opt/clones/clara/workspace")
ENV_PATH = WORKSPACE / ".env"
AUDIO_DIR = WORKSPACE / "data" / "audio"

MSG_NO_KEYS = (
    "Pra eu mandar áudio preciso de uma das duas: Google Cloud TTS "
    "(grátis até 4 milhões de caracteres por mês · te ensino em 5 passos) "
    "ou OpenAI (mais simples · poucos centavos por minuto). Qual você prefere?"
)


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


def maybe_pip_install(pkg: str) -> bool:
    """Tenta instalar pacote localmente (--user). Volta True se sucesso."""
    import subprocess

    print(f"[tts] tentando pip install --user {pkg}...", file=sys.stderr)
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "--user", "--quiet", pkg],
            check=True,
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"[tts] pip install falhou: {e}", file=sys.stderr)
        return False


def synth_google(text: str, voice: str, out_path: Path) -> Path:
    """Google Cloud TTS via google-cloud-texttospeech.

    Voz Chirp3-HD (Kore/Charon/Aoede) entrega áudio natural em PT-BR.
    """
    try:
        from google.cloud import texttospeech
    except ImportError:
        print(
            "[tts] google-cloud-texttospeech não instalado. Roda 1x:\n"
            "  pip install --user google-cloud-texttospeech\n"
            "Ou usa --first-run pra eu tentar instalar agora.",
            file=sys.stderr,
        )
        raise SystemExit(3)

    client = texttospeech.TextToSpeechClient()
    voice_name = f"pt-BR-Chirp3-HD-{voice}"
    synthesis_input = texttospeech.SynthesisInput(text=text)
    voice_params = texttospeech.VoiceSelectionParams(
        language_code="pt-BR",
        name=voice_name,
    )
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.OGG_OPUS,
        speaking_rate=1.0,
    )
    response = client.synthesize_speech(
        input=synthesis_input,
        voice=voice_params,
        audio_config=audio_config,
    )
    out_path.write_bytes(response.audio_content)
    return out_path


def synth_openai(text: str, api_key: str, out_path: Path) -> Path:
    """OpenAI TTS fallback. Saída MP3 · convertido pra OGG via ffmpeg se disponível."""
    import subprocess

    try:
        import requests
    except ImportError:
        print("[tts] requests não instalado. Roda: pip install --user requests", file=sys.stderr)
        raise SystemExit(3)

    url = "https://api.openai.com/v1/audio/speech"
    headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
    body = {
        "model": "tts-1",
        "voice": "nova",
        "input": text,
        "response_format": "opus",
    }
    r = requests.post(url, headers=headers, json=body, timeout=60)
    if r.status_code != 200:
        print(f"[tts] OpenAI HTTP {r.status_code}: {r.text[:500]}", file=sys.stderr)
        raise SystemExit(4)

    # OpenAI já entrega opus · só renomear pra .ogg
    tmp_path = out_path.with_suffix(".opus.tmp")
    tmp_path.write_bytes(r.content)

    # Wrap em container OGG via ffmpeg se disponível
    ffmpeg = subprocess.run(["which", "ffmpeg"], capture_output=True, text=True)
    if ffmpeg.returncode == 0:
        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(tmp_path), "-c:a", "copy", str(out_path)],
            check=True,
        )
        tmp_path.unlink(missing_ok=True)
    else:
        # sem ffmpeg · só renomeia (Telegram aceita opus puro mesmo)
        tmp_path.rename(out_path)

    return out_path


def main() -> int:
    parser = argparse.ArgumentParser(description="Clara TTS · Google Cloud por default · OpenAI fallback.")
    parser.add_argument("text", help="Texto pra sintetizar")
    parser.add_argument("--voice", default="Kore", choices=["Kore", "Charon", "Aoede"], help="Voz Chirp3-HD")
    parser.add_argument("--out", default=None, help="Caminho do OGG de saída")
    parser.add_argument("--engine", default="auto", choices=["auto", "google", "openai"], help="Motor TTS")
    parser.add_argument("--first-run", action="store_true", help="Tenta pip install --user na 1a execução")
    args = parser.parse_args()

    env = {**load_env(ENV_PATH), **os.environ}
    has_google = bool(env.get("GOOGLE_APPLICATION_CREDENTIALS"))
    has_openai = bool(env.get("OPENAI_API_KEY"))

    if not has_google and not has_openai:
        print(MSG_NO_KEYS, file=sys.stderr)
        return 2

    AUDIO_DIR.mkdir(parents=True, exist_ok=True)
    ts = datetime.utcnow().strftime("%Y-%m-%dT%H-%M-%S")
    out_path = Path(args.out) if args.out else AUDIO_DIR / f"{ts}.ogg"
    out_path.parent.mkdir(parents=True, exist_ok=True)

    engine = args.engine
    if engine == "auto":
        engine = "google" if has_google else "openai"

    if args.first_run and engine == "google":
        maybe_pip_install("google-cloud-texttospeech")

    if engine == "google":
        if not has_google:
            print("[tts] GOOGLE_APPLICATION_CREDENTIALS ausente · trocando pra openai", file=sys.stderr)
            engine = "openai"
        else:
            # garante variável no processo
            os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = env["GOOGLE_APPLICATION_CREDENTIALS"]
            try:
                synth_google(args.text, args.voice, out_path)
                print(f"[tts] OK Google · voz {args.voice} -> {out_path}", file=sys.stderr)
                print(str(out_path))
                return 0
            except SystemExit:
                raise
            except Exception as e:
                print(f"[tts] Google falhou: {e}", file=sys.stderr)
                if has_openai:
                    print("[tts] caindo no OpenAI...", file=sys.stderr)
                    engine = "openai"
                else:
                    return 5

    if engine == "openai":
        if not has_openai:
            print("[tts] OPENAI_API_KEY ausente", file=sys.stderr)
            return 2
        synth_openai(args.text, env["OPENAI_API_KEY"], out_path)
        print(f"[tts] OK OpenAI -> {out_path}", file=sys.stderr)
        print(str(out_path))
        return 0

    return 99


if __name__ == "__main__":
    sys.exit(main())
