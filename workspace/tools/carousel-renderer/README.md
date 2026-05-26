# carousel-renderer

Renderiza carrosséis Instagram (1080x1350) a partir de template HTML/CSS + JSON. Usado pela Clara quando o lojista pede "faz um carrossel pra mim".

## Stack

- **handlebars** (compilação template → HTML)
- **puppeteer-core** (Chromium do sistema · zero download)
- **Chromium do snap** (já instalado · `/usr/bin/chromium-browser`)

Zero serviço pago. Zero conta externa.

## Setup (1ª vez)

```bash
cd /opt/clones/clara/workspace/tools/carousel-renderer
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install
```

## Uso

```bash
node render.js <template.html> <data.json> <out-dir>
```

### Exemplo

```bash
node render.js \
  templates/T1-claro-30gb.html \
  examples/claro-controle-30gb.json \
  /tmp/clara-test-carousel/
```

Saída:
- `<out-dir>/slide-1.png` ... `slide-6.png` (PNG 1080x1350)
- `<out-dir>/manifest.json` (metadata)
- `stdout`: lista pura de paths PNG (1 por linha) pra Clara consumir

## Templates disponíveis

| ID | Path | Tema |
|----|------|------|
| T1 | `templates/T1-claro-30gb.html` | Claro Controle 30GB · 6 slides · capa/features/pra-quem/preço/comparativo/CTA |

## Adicionar template novo

1. Cria `templates/T<N>-<nome>.html` (use `T1-claro-30gb.html` como referência)
2. Cada slide é um `<section class="slide">` com classe de fundo (`bg-red`, `bg-white`, `bg-cream`, `bg-dark`)
3. Variáveis Handlebars: `{{nome}}` (escapado) ou `{{{nome}}}` (HTML raw)
4. CSS compartilhado em `templates/shared.css` (já injetado inline pelo render.js)
5. Salva exemplo de data em `examples/<nome>.json`
6. Adiciona linha na tabela acima

## Como Clara invoca (exemplo)

```javascript
const { execSync } = require('child_process');
const out = execSync(
  `node /opt/clones/clara/workspace/tools/carousel-renderer/render.js \
   /opt/clones/clara/workspace/tools/carousel-renderer/templates/T1-claro-30gb.html \
   /tmp/clara-data-${id}.json \
   /tmp/clara-carousel-${id}/`,
  { encoding: 'utf-8' }
);
const paths = out.trim().split('\n'); // ['/tmp/clara-carousel-xyz/slide-1.png', ...]
```

Depois Clara anexa via Telegram (`mcp__plugin_telegram_telegram__reply` com `files: [...]`).

## Troubleshooting

- **"Chromium não encontrado"** → `apt install chromium-browser` ou setar `PUPPETEER_EXECUTABLE_PATH=/path/to/chromium`
- **Fontes Google não carregaram** → render.js já aguarda `document.fonts.ready` antes do screenshot
- **Texto cortado** → reduzir font-size no template OU encurtar copy no JSON

## Anti-padrões

- Não baixar Chromium do Puppeteer (usa o do sistema · economiza ~300MB)
- Não inserir API key paga (Canva Pro, etc) · este renderer é GRATIS BY DEFAULT
- Não criar novo template a cada lojista · reusar templates parametrizados via JSON
