#!/usr/bin/env python3
"""setup.py · Clara · roda OAuth do Google 1x · salva token em data/google-token.pickle.

Uso:
    python3 tools/google-workspace/setup.py

Pré-requisito: data/google-oauth-client.json (dono baixa do Google Cloud Console).
Skill clara-tools-setup.md ensina passo a passo de pegar esse arquivo.
"""
from __future__ import annotations

import pickle
import sys
from pathlib import Path

WORKSPACE = Path("/opt/clones/clara/workspace")
TOKEN_PATH = WORKSPACE / "data" / "google-token.pickle"
CLIENT_SECRET_PATH = WORKSPACE / "data" / "google-oauth-client.json"

SCOPES = [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/gmail.send",
]


def main() -> int:
    try:
        from google_auth_oauthlib.flow import InstalledAppFlow
    except ImportError:
        print(
            "Pacotes ausentes. Roda 1x:\n"
            "  pip install --user google-auth-oauthlib google-api-python-client",
            file=sys.stderr,
        )
        return 3

    if not CLIENT_SECRET_PATH.exists():
        print(
            f"Arquivo {CLIENT_SECRET_PATH} não existe.\n"
            "Dono precisa baixar o JSON de OAuth Client ID do Google Cloud Console.\n"
            "Skill clara-tools-setup.md ensina o passo a passo.",
            file=sys.stderr,
        )
        return 1

    flow = InstalledAppFlow.from_client_secrets_file(str(CLIENT_SECRET_PATH), SCOPES)
    # Console flow · sem precisar de browser local na VPS (manda link · dono cola código)
    creds = flow.run_local_server(port=0, open_browser=False)

    TOKEN_PATH.parent.mkdir(parents=True, exist_ok=True)
    with TOKEN_PATH.open("wb") as fh:
        pickle.dump(creds, fh)

    print(f"[google-workspace] OK · token salvo em {TOKEN_PATH}", file=sys.stderr)
    print("Pronto · agora Clara pode mexer em Calendar e Gmail.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
