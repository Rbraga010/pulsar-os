// Pulsar OS · /api/pulsar-os/heartbeat
// Next.js 14 app router · route handler
// Copia esse arquivo pra app/api/pulsar-os/heartbeat/route.ts no projeto onde for receber telemetria

import { NextRequest, NextResponse } from "next/server";
// import { db } from "@/lib/db";  // ajusta conforme stack do projeto host

export const dynamic = "force-dynamic";

type HeartbeatPayload = {
  installId: string;
  version: string;
  lastActive: string;
};

function isValidUuid(v: unknown): v is string {
  return typeof v === "string" && /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
}

function isValidIsoDate(v: unknown): v is string {
  if (typeof v !== "string") return false;
  const d = new Date(v);
  return !isNaN(d.getTime());
}

export async function POST(req: NextRequest) {
  try {
    const body = (await req.json()) as Partial<HeartbeatPayload>;
    const { installId, version, lastActive } = body;

    if (!isValidUuid(installId) || typeof version !== "string" || !isValidIsoDate(lastActive)) {
      return NextResponse.json({ error: "invalid_payload" }, { status: 400 });
    }

    // TODO substituir pelo client db real do projeto host
    // await db.query(`
    //   INSERT INTO pulsar_os_installs (install_id, version, last_active)
    //   VALUES ($1, $2, $3)
    //   ON CONFLICT (install_id) DO UPDATE
    //   SET version = $2, last_active = $3, updated_at = NOW()
    // `, [installId, version, lastActive]);

    console.log(`[heartbeat] install=${installId} version=${version} active=${lastActive}`);

    return NextResponse.json({ ok: true });
  } catch (err) {
    console.error("[heartbeat] error:", err);
    return NextResponse.json({ error: "server_error" }, { status: 500 });
  }
}

// Rate limit recomendado: 1 req/install/dia · usa Cloudflare WAF ou middleware proprio
