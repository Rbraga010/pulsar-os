#!/usr/bin/env node
/**
 * Clara · WhatsApp pareamento (Baileys)
 *
 * Uso (1ª vez por lojista):
 *   node pair.js
 *
 * Mostra QR code no terminal · lojista escaneia com WhatsApp do celular dele
 * (Aparelhos conectados → conectar um aparelho).
 *
 * Após pareado, credencial fica salva em `./session/` · Clara reusa em send.js
 * sem precisar parear de novo.
 *
 * GRATIS BY DEFAULT · zero dependência de WhatsApp Business API paga.
 */

const { default: makeWASocket, useMultiFileAuthState, DisconnectReason } = require('@whiskeysockets/baileys');
const qrcode = require('qrcode-terminal');
const pino = require('pino');
const path = require('path');

const SESSION_DIR = path.join(__dirname, 'session');

async function pair() {
  const { state, saveCreds } = await useMultiFileAuthState(SESSION_DIR);

  const sock = makeWASocket({
    auth: state,
    logger: pino({ level: 'silent' }),
    printQRInTerminal: false, // vamos imprimir manualmente
  });

  sock.ev.on('creds.update', saveCreds);

  sock.ev.on('connection.update', (update) => {
    const { connection, lastDisconnect, qr } = update;
    if (qr) {
      console.log('\n=== Escaneia com WhatsApp do celular ===');
      console.log('WhatsApp → Aparelhos conectados → Conectar um aparelho\n');
      qrcode.generate(qr, { small: true });
    }
    if (connection === 'open') {
      console.log('\n[pair] CONECTADO. Credencial salva em', SESSION_DIR);
      console.log('[pair] Pode usar `node send.js <numero> <msg>` agora.');
      process.exit(0);
    }
    if (connection === 'close') {
      const code = lastDisconnect?.error?.output?.statusCode;
      if (code === DisconnectReason.loggedOut) {
        console.log('[pair] Sessão expirou · rode `node pair.js` de novo.');
        process.exit(1);
      } else {
        console.log('[pair] desconectado · code=' + code + ' · tentando reconectar');
        setTimeout(pair, 3000);
      }
    }
  });
}

pair().catch((err) => {
  console.error('[pair] ERRO:', err.message);
  process.exit(1);
});
