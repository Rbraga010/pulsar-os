"""_oauth.py · OAuth Google compartilhado entre calendar.py e gmail.py.

Carrega token salvo em data/google-token.pickle. Refresca se expirou.
"""
from __future__ import annotations

import os
import pickle
from pathlib import Path

WORKSPACE = Path("/opt/clones/clara/workspace")
TOKEN_PATH = WORKSPACE / "data" / "google-token.pickle"
CLIENT_SECRET_PATH = WORKSPACE / "data" / "google-oauth-client.json"

SCOPES = [
    "https://www.googleapis.com/auth/calendar",
    "https://www.googleapis.com/auth/gmail.send",
]

MSG_NO_TOKEN = (
    "OAuth Google não rodou ainda. Roda 1x:\n"
    "  python3 tools/google-workspace/setup.py\n"
    "Depois Clara pode mexer em agenda e enviar email."
)


def load_credentials():
    """Volta google.oauth2.credentials.Credentials ou levanta SystemExit."""
    try:
        from google.auth.transport.requests import Request
    except ImportError:
        print(
            "[google-workspace] pacotes ausentes. Roda 1x:\n"
            "  pip install --user google-auth-oauthlib google-api-python-client",
        )
        raise SystemExit(3)

    if not TOKEN_PATH.exists():
        print(MSG_NO_TOKEN)
        raise SystemExit(2)

    with TOKEN_PATH.open("rb") as fh:
        creds = pickle.load(fh)

    if creds and creds.expired and creds.refresh_token:
        creds.refresh(Request())
        with TOKEN_PATH.open("wb") as fh:
            pickle.dump(creds, fh)

    if not creds or not creds.valid:
        print(MSG_NO_TOKEN)
        raise SystemExit(2)

    return creds
