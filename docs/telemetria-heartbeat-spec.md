# Pulsar OS · Heartbeat Telemetria · Spec

## Objetivo
Contar quantas instalacoes Pulsar OS estao ATIVAS sem coletar nada pessoal/comercial do lojista. Dado e anonimo · so install ID + versao + timestamp.

## Endpoint (servidor Pulsar OS central · qualquer deploy: Vercel, Cloudflare Worker, etc)

### POST /api/pulsar-os/heartbeat

**Request:**
```http
POST /api/pulsar-os/heartbeat HTTP/1.1
Host: pulsarh.com.br
Content-Type: application/json

{
  "installId": "uuid-v4",
  "version": "0.1.0",
  "lastActive": "2026-05-22T18:42:00Z"
}
```

**Response 200:**
```json
{ "ok": true }
```

**Response 4xx:**
```json
{ "error": "invalid_payload" }
```

## Logica server-side (pseudo)
```ts
// app/api/pulsar-os/heartbeat/route.ts (Next.js 14 app router)
import { NextRequest, NextResponse } from "next/server";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const { installId, version, lastActive } = body;

    // Valida payload
    if (!installId || !version || !lastActive) {
      return NextResponse.json({ error: "invalid_payload" }, { status: 400 });
    }

    // Persistir (Postgres ou KV)
    await db.query(`
      INSERT INTO pulsar_os_installs (install_id, version, last_active)
      VALUES ($1, $2, $3)
      ON CONFLICT (install_id) DO UPDATE
      SET version = $2, last_active = $3, updated_at = NOW()
    `, [installId, version, lastActive]);

    return NextResponse.json({ ok: true });
  } catch (err) {
    return NextResponse.json({ error: "server_error" }, { status: 500 });
  }
}
```

## Schema Postgres
```sql
CREATE TABLE IF NOT EXISTS pulsar_os_installs (
  install_id UUID PRIMARY KEY,
  version TEXT NOT NULL,
  last_active TIMESTAMPTZ NOT NULL,
  first_seen TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_pulsar_os_installs_last_active 
  ON pulsar_os_installs (last_active DESC);
```

## Cron no cliente
Setup script ja configura:
```cron
0 9 * * * curl -s -X POST -H 'Content-Type: application/json' \
  -d '{"installId":"<UUID>","version":"<VER>","lastActive":"<ISO>"}' \
  https://pulsarh.com.br/api/pulsar-os/heartbeat >/dev/null 2>&1
```

## Privacidade
- Sem IP coletado (Cloudflare pode anonimizar antes de logar)
- Sem dados do lojista, sem nome, sem CPF, sem nada comercial
- Apenas: tem instalacao X rodando, versao Y, ultima vez ativa Z
- Lojista pode desativar removendo do crontab

## Dashboard (futuro, fora do MVP)
- Total de installs ativos (ultimos 7 dias)
- Distribuicao de versoes
- Curva de adocao mensal

## Status implementacao
- [x] Spec definida
- [x] Cron configurado no setup-pulsar-os.sh
- [ ] **Endpoint server-side a implementar** (escolher onde plugar: Vercel, Cloudflare Worker, etc)
- [ ] Schema Postgres criado
- [ ] Dashboard interno (v0.2+)
