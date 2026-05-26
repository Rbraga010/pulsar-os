#!/usr/bin/env node
// generate.mjs · Clara · gera imagem por prompt via Imagen 4 (Google AI Studio)
// Uso: node generate.mjs "<prompt>" [--aspect=1:1|3:4|4:5|9:16] [--out=path.png]
// Lê GOOGLE_AI_API_KEY do .env da workspace.

import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { dirname, resolve } from "node:path";

const WORKSPACE = "/opt/clones/clara/workspace";
const ENV_PATH = `${WORKSPACE}/.env`;
const IMAGES_DIR = `${WORKSPACE}/data/images`;

const MODEL = "imagen-4.0-generate-001";
const ENDPOINT = (key) =>
  `https://generativelanguage.googleapis.com/v1beta/models/${MODEL}:predict?key=${key}`;

const MSG_NO_KEY =
  "Pra gerar imagem com IA preciso da chave Google AI Studio. Pega em https://aistudio.google.com/apikey (gratuita), me passa que eu plugo.";

function loadEnv(path) {
  const out = {};
  if (!existsSync(path)) return out;
  for (const line of readFileSync(path, "utf8").split(/\r?\n/)) {
    if (!line || line.startsWith("#")) continue;
    const m = line.match(/^([A-Z_][A-Z0-9_]*)=(.*)$/);
    if (m) out[m[1]] = m[2].replace(/^"|"$/g, "");
  }
  return out;
}

function parseArgs(argv) {
  const args = { prompt: null, aspect: "1:1", out: null };
  const rest = [];
  for (const a of argv) {
    if (a.startsWith("--aspect=")) args.aspect = a.slice(9);
    else if (a.startsWith("--out=")) args.out = a.slice(6);
    else rest.push(a);
  }
  args.prompt = rest.join(" ").trim();
  return args;
}

const ALLOWED_ASPECT = new Set(["1:1", "3:4", "4:5", "9:16", "4:3", "16:9"]);

async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (!args.prompt) {
    console.error('Uso: node generate.mjs "<prompt>" [--aspect=1:1|3:4|4:5|9:16] [--out=path.png]');
    process.exit(1);
  }
  if (!ALLOWED_ASPECT.has(args.aspect)) {
    console.error(`Aspecto inválido: ${args.aspect}. Aceito: ${[...ALLOWED_ASPECT].join(", ")}`);
    process.exit(1);
  }

  const env = { ...loadEnv(ENV_PATH), ...process.env };
  const KEY = env.GOOGLE_AI_API_KEY;
  if (!KEY) {
    console.error(MSG_NO_KEY);
    process.exit(2);
  }

  if (!existsSync(IMAGES_DIR)) mkdirSync(IMAGES_DIR, { recursive: true });
  const ts = new Date().toISOString().replace(/[:.]/g, "-");
  const outPath = args.out ? resolve(args.out) : `${IMAGES_DIR}/${ts}.png`;
  const outDir = dirname(outPath);
  if (!existsSync(outDir)) mkdirSync(outDir, { recursive: true });

  const body = {
    instances: [{ prompt: args.prompt }],
    parameters: {
      sampleCount: 1,
      aspectRatio: args.aspect,
      personGeneration: "allow_adult",
    },
  };

  const t0 = Date.now();
  let r;
  try {
    r = await fetch(ENDPOINT(KEY), {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    });
  } catch (err) {
    console.error(`Falha de rede ao chamar Imagen: ${err.message}`);
    process.exit(3);
  }

  if (!r.ok) {
    const errText = await r.text();
    console.error(`HTTP ${r.status} ${r.statusText}`);
    console.error(errText.slice(0, 1500));
    if (r.status === 429) {
      console.error("\nQuota Google AI Studio estourou. Espera 1 min ou abre conta paga em https://aistudio.google.com/apikey");
    } else if (r.status === 400 || r.status === 403) {
      console.error("\nChave inválida ou Imagen não habilitado no projeto. Confere em https://aistudio.google.com/apikey");
    }
    process.exit(4);
  }

  const j = await r.json();
  const b64 = j?.predictions?.[0]?.bytesBase64Encoded;
  if (!b64) {
    console.error("Resposta sem bytesBase64Encoded.");
    console.error(JSON.stringify(j).slice(0, 1500));
    process.exit(5);
  }

  const buf = Buffer.from(b64, "base64");
  writeFileSync(outPath, buf);
  const dt = ((Date.now() - t0) / 1000).toFixed(1);
  console.error(`[image-gen] OK ${dt}s · ${(buf.length / 1024).toFixed(0)}KB · ${args.aspect} -> ${outPath}`);
  // stdout limpo · só o path (pra Clara consumir)
  console.log(outPath);
}

main().catch((err) => {
  console.error(`Erro inesperado: ${err.message}`);
  process.exit(99);
});
