#!/usr/bin/env node
/**
 * Clara · WhatsApp envio (Baileys)
 *
 * Uso:
 *   node send.js <numero_E164> <mensagem>
 *
 * Exemplo:
 *   node send.js 5515999999999 "Oi · tudo bem? Aqui é da Loja do Rodrigo"
 *
 * Lojista precisa ter pareado antes (node pair.js).
 *
 * Stdout JSON:
 *   {"ok": true, "to": "5515999999999@s.whatsapp.net", "id": "ABC..."}
 */

const { default: makeWASocket, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const pino = require('pino');
const path = require('path');
const fs = require('fs');

const SESSION_DIR = path.join(__dirname, 'session');

async function send(numero, mensagem) {
  if (!fs.existsSync(SESSION_DIR)) {
    console.log(JSON.stringify({
      ok: false,
      error: 'session_not_paired',
      hint: 'Rode `node pair.js` primeiro · lojista precisa escanear QR no WhatsApp dele',
    }));
    process.exit(2);
  }

  const { state, saveCreds } = await useMultiFileAuthState(SESSION_DIR);
  const sock = makeWASocket({
    auth: state,
    logger: pino({ level: 'silent' }),
    printQRInTerminal: false,
  });

  sock.ev.on('creds.update', saveCreds);

  return new Promise((resolve, reject) => {
    sock.ev.on('connection.update', async (update) => {
      if (update.connection === 'open') {
        try {
          const jid = numero.includes('@') ? numero : `${numero}@s.whatsapp.net`;
          const res = await sock.sendMessage(jid, { text: mensagem });
          console.log(JSON.stringify({
            ok: true,
            to: jid,
            id: res?.key?.id,
            ts: new Date().toISOString(),
          }));
          setTimeout(() => process.exit(0), 1000);
        } catch (err) {
          console.log(JSON.stringify({ ok: false, error: err.message }));
          process.exit(1);
        }
      }
      if (update.connection === 'close') {
        const code = update.lastDisconnect?.error?.output?.statusCode;
        console.log(JSON.stringify({ ok: false, error: `connection_closed code=${code}` }));
        process.exit(1);
      }
    });
  });
}

const [, , numero, ...msgParts] = process.argv;
if (!numero || msgParts.length === 0) {
  console.log(JSON.stringify({
    ok: false,
    error: 'usage',
    hint: 'node send.js <numero_E164> <mensagem>',
  }));
  process.exit(2);
}
send(numero, msgParts.join(' '));
