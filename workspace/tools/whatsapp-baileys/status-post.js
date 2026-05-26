#!/usr/bin/env node
/**
 * Clara · WhatsApp Status (posta no Status do lojista · ex-Stories WhatsApp)
 *
 * Uso:
 *   node status-post.js <caminho_imagem.png> [legenda]
 *
 * Baileys suporta `sendMessage(jid='status@broadcast', {image, caption})`.
 *
 * Stub funcional · lojista precisa estar pareado.
 */

const { default: makeWASocket, useMultiFileAuthState } = require('@whiskeysockets/baileys');
const pino = require('pino');
const path = require('path');
const fs = require('fs');

const SESSION_DIR = path.join(__dirname, 'session');

async function postStatus(imagePath, caption = '') {
  if (!fs.existsSync(SESSION_DIR)) {
    console.log(JSON.stringify({ ok: false, error: 'session_not_paired' }));
    process.exit(2);
  }
  if (!fs.existsSync(imagePath)) {
    console.log(JSON.stringify({ ok: false, error: 'image_not_found', path: imagePath }));
    process.exit(3);
  }

  const { state, saveCreds } = await useMultiFileAuthState(SESSION_DIR);
  const sock = makeWASocket({
    auth: state,
    logger: pino({ level: 'silent' }),
    printQRInTerminal: false,
  });
  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', async (update) => {
    if (update.connection === 'open') {
      try {
        const buffer = fs.readFileSync(imagePath);
        const res = await sock.sendMessage('status@broadcast', {
          image: buffer,
          caption: caption || undefined,
        });
        console.log(JSON.stringify({
          ok: true,
          status_id: res?.key?.id,
          image: imagePath,
          caption,
          ts: new Date().toISOString(),
        }));
        setTimeout(() => process.exit(0), 1500);
      } catch (err) {
        console.log(JSON.stringify({ ok: false, error: err.message }));
        process.exit(1);
      }
    }
  });
}

const [, , imagePath, ...captionParts] = process.argv;
if (!imagePath) {
  console.log(JSON.stringify({ ok: false, error: 'usage', hint: 'node status-post.js <imagem> [legenda]' }));
  process.exit(2);
}
postStatus(imagePath, captionParts.join(' '));
