# video-remotion

Renderiza reels verticais 1080x1920 de 15 segundos · 3 cards animados (hook · oferta · CTA) com fade + scale. Sem API · 100% local · grátis pra sempre.

## Stack

- Node.js + **Remotion** (React-based video renderer)
- TypeScript · Chromium do sistema (reutiliza o do carousel-renderer)
- Sem API key · sem serviço externo

## Custo

Zero. Tudo roda local. Único custo é tempo de CPU (1 a 2 minutos por reel).

## Estrutura

```
video-remotion/
├── package.json
├── tsconfig.json
├── render.sh
├── src/
│   ├── index.ts
│   ├── Root.tsx
│   └── Reel15s.tsx
└── examples/
    └── props.json
```

## Setup (1ª vez)

Primeira execução do `render.sh` baixa Remotion (~200MB · 1x só · ~3 min):

```bash
PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install
```

(O próprio `render.sh` faz isso na 1ª execução · não precisa rodar manual.)

## Uso

```bash
bash tools/video-remotion/render.sh <props.json> [--out=path.mp4]
```

### Exemplo

```bash
bash tools/video-remotion/render.sh \
  tools/video-remotion/examples/props.json \
  --out=/tmp/clara-reel.mp4
```

Saída no `stdout`: path do MP4 (1 linha · pra Clara consumir). Logs vão pro `stderr`.

## props.json

```json
{
  "hook": "Sabia que o seu plano pode custar metade?",
  "oferta": "30GB Claro · R$ 54,90",
  "cta": "Chama no WhatsApp",
  "color1": "#C9A84A",
  "color2": "#0B0C1F",
  "foto": ""
}
```

- `hook` · texto card 1 (gancho · 0-5s)
- `oferta` · texto card 2 (oferta · 5-10s)
- `cta` · texto card 3 (call-to-action · 10-15s)
- `color1` · cor de destaque (dourado por default · usado em texto OU fundo)
- `color2` · cor base (navy por default)
- `foto` · URL OU path local de imagem de fundo (opacidade 18% por baixo) · opcional

## Como Clara invoca (interno)

```bash
cat > /tmp/clara-reel-${session}.json <<EOF
{
  "hook": "$hook",
  "oferta": "$oferta",
  "cta": "$cta",
  "color1": "#C9A84A",
  "color2": "#0B0C1F",
  "foto": ""
}
EOF

out=$(bash /opt/clones/clara/workspace/tools/video-remotion/render.sh \
  /tmp/clara-reel-${session}.json \
  --out=/tmp/clara-reel-${session}.mp4)

# Clara manda $out via Telegram (reply files=[$out])
```

## Anti-padrões

- Não baixar Chromium do Puppeteer · usa o do sistema (já instalado pelo carousel-renderer)
- Não renderizar reel > 30s sem dividir em sequence específica · mantém leve
- Não usar pra carrossel estático · isso é trabalho do carousel-renderer (mais rápido · saída PNG)
- Não usar texto longo em card · cada card aguenta 1 frase curta · senão estoura visualmente

## Troubleshooting

- "Cannot find module 'remotion'" · ainda não rodou install · `cd tools/video-remotion && PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm install`
- Render trava · checa CPU (Remotion é hungry) · concorrência já tá em 1 pra evitar
- Fonte fora do padrão · ajustar `fontFamily` em `Reel15s.tsx` · default usa Inter system

## Tempo de render

- Primeira execução · 2-3 min de download + 1-2 min de render
- Execuções seguintes · 1-2 min de render
