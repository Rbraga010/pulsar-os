# whatsapp-baileys

WhatsApp self-hosted via [Baileys](https://github.com/WhiskeySockets/Baileys) (lib open source que conversa direto com o protocolo do WhatsApp · zero dependência da WhatsApp Business API paga).

## Stack

- **@whiskeysockets/baileys** (lib gratuita · self-hosted)
- **qrcode-terminal** (gera QR no terminal pro lojista escanear)
- **pino** (logger silencioso)

## Status

**STUB FUNCIONAL.** Código está pronto · lojista precisa parear antes de Clara usar.

## Setup do lojista (1x · primeira vez)

1. **Lojista abre WhatsApp no celular dele** → Aparelhos conectados → Conectar um aparelho
2. Clara/operador roda:
   ```bash
   cd /opt/clones/clara/workspace/tools/whatsapp-baileys
   npm install   # primeira vez só
   node pair.js
   ```
3. QR code aparece no terminal
4. Lojista escaneia com o celular dele
5. Credencial salva em `./session/` · Clara reutiliza nas próximas vezes

## Uso (depois de pareado)

### Enviar mensagem texto

```bash
node send.js 5515999999999 "Oi · tudo bem? Aqui é da Loja do Rodrigo · seu pedido tá pronto"
```

Saída JSON: `{"ok": true, "to": "...", "id": "..."}`

### Postar Status (ex-Stories WhatsApp)

```bash
node status-post.js /tmp/clara-carousel/slide-1.png "Promoção 30GB Claro · R$ 54,90"
```

## Como Clara invoca

Quando lojista pede "manda WhatsApp pro João falando que o pedido tá pronto":
1. Clara consulta memória pra pegar número do João (`cerebro/memory/clientes.md` ou DB `clientes`)
2. Executa `node send.js <num> "<msg>"` via Bash
3. Confere `ok=true` no JSON
4. Reporta pro lojista no Telegram: "mandei · ele recebeu"

Se `ok=false` com `error=session_not_paired`:
- Clara avisa o lojista: "pra eu mandar WhatsApp por você, precisa parear primeiro · pereia agora?"
- Se sim → Clara chama `node pair.js` (em modo manual · operador acompanha pareamento)

## Anti-padrões

- Não usar WhatsApp Business API oficial (Meta · paga · burocrática) · Baileys resolve sem custo
- Não automatizar pareamento (precisa do humano com celular)
- Não enviar spam (banimento WhatsApp é fácil) · enviar só pra contatos do próprio lojista
- Não criar grupo de transmissão grande (>50 destinatários por vez) · respeitar limites do WA

## Riscos conhecidos

- WhatsApp pode banir contas que automatizam demais · Clara deve enviar com **delay humano** (3-8s entre mensagens) e em volume baixo (`<50/dia`)
- Sessão expira eventualmente · lojista precisa re-parear (Clara avisa quando detectar)

## Roadmap (não bloqueia hoje)

- [ ] Helper de envio em lote com delay aleatório (anti-banimento)
- [ ] Listener inbound (Clara vê msg que cliente mandou pro lojista) · permite follow-up automatizado
- [ ] Catálogo · etiqueta · respostas rápidas (precisaria de hook no Baileys além do default)
