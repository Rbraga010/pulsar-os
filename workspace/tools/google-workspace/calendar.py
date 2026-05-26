#!/usr/bin/env python3
"""calendar.py · Clara · Google Calendar (list / create).

Uso:
    python3 tools/google-workspace/calendar.py list_events [--max=10] [--calendar=primary]
    python3 tools/google-workspace/calendar.py create_event --title="..." --start="2026-05-25T14:00" --duration=60 [--description="..."] [--calendar=primary]

Saída list_events: JSON na stdout.
Saída create_event: JSON com o evento criado.
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from _oauth import load_credentials  # noqa: E402

# fuso default: America/Sao_Paulo (UTC-3)
BRT = timezone(timedelta(hours=-3))


def get_service(creds):
    try:
        from googleapiclient.discovery import build
    except ImportError:
        print("[calendar] googleapiclient ausente. Roda: pip install --user google-api-python-client", file=sys.stderr)
        raise SystemExit(3)
    return build("calendar", "v3", credentials=creds, cache_discovery=False)


def list_events(args) -> int:
    creds = load_credentials()
    service = get_service(creds)

    now = datetime.now(timezone.utc).isoformat()
    res = service.events().list(
        calendarId=args.calendar,
        timeMin=now,
        maxResults=args.max,
        singleEvents=True,
        orderBy="startTime",
    ).execute()

    events = res.get("items", [])
    out = []
    for ev in events:
        out.append({
            "id": ev.get("id"),
            "summary": ev.get("summary", ""),
            "start": ev.get("start", {}).get("dateTime") or ev.get("start", {}).get("date"),
            "end": ev.get("end", {}).get("dateTime") or ev.get("end", {}).get("date"),
            "location": ev.get("location", ""),
            "description": ev.get("description", ""),
            "htmlLink": ev.get("htmlLink", ""),
        })
    print(json.dumps(out, ensure_ascii=False, indent=2))
    return 0


def create_event(args) -> int:
    creds = load_credentials()
    service = get_service(creds)

    # parse start
    try:
        start_dt = datetime.fromisoformat(args.start)
    except ValueError:
        print(f"[calendar] formato de --start inválido: {args.start} (use ISO 2026-05-25T14:00)", file=sys.stderr)
        return 1

    # assume BRT se sem timezone
    if start_dt.tzinfo is None:
        start_dt = start_dt.replace(tzinfo=BRT)

    end_dt = start_dt + timedelta(minutes=args.duration)

    body = {
        "summary": args.title,
        "description": args.description or "",
        "start": {"dateTime": start_dt.isoformat(), "timeZone": "America/Sao_Paulo"},
        "end": {"dateTime": end_dt.isoformat(), "timeZone": "America/Sao_Paulo"},
    }
    if args.location:
        body["location"] = args.location

    ev = service.events().insert(calendarId=args.calendar, body=body).execute()
    out = {
        "id": ev.get("id"),
        "summary": ev.get("summary"),
        "start": ev.get("start", {}).get("dateTime"),
        "end": ev.get("end", {}).get("dateTime"),
        "htmlLink": ev.get("htmlLink"),
    }
    print(json.dumps(out, ensure_ascii=False, indent=2))
    print(f"[calendar] evento criado: {ev.get('htmlLink')}", file=sys.stderr)
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Clara · Google Calendar")
    sub = parser.add_subparsers(dest="action", required=True)

    p_list = sub.add_parser("list_events", help="Lista próximos eventos")
    p_list.add_argument("--max", type=int, default=10)
    p_list.add_argument("--calendar", default="primary")
    p_list.set_defaults(func=list_events)

    p_create = sub.add_parser("create_event", help="Cria evento")
    p_create.add_argument("--title", required=True)
    p_create.add_argument("--start", required=True, help="ISO 2026-05-25T14:00 (assume BRT)")
    p_create.add_argument("--duration", type=int, default=60, help="Duração em minutos")
    p_create.add_argument("--description", default="")
    p_create.add_argument("--location", default="")
    p_create.add_argument("--calendar", default="primary")
    p_create.set_defaults(func=create_event)

    args = parser.parse_args()
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
