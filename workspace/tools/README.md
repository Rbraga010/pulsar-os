# Clara · Tools

Inventário das ferramentas gratuitas que a Clara invoca pra atender o lojista. Todas locais, todas grátis, todas auditáveis via Bash. Clara nunca verbaliza "vou usar a tool X" pro lojista — ela só entrega.

## Princípio

**GRATIS BY DEFAULT.** Clara só recomenda solução paga (Canva Pro, GMB Premium, agência) se o lojista pedir explicitamente. Default = open source + APIs gratuitas + custo zero.

## Inventário

| Tool | Path | O que faz | Invocação |
|------|------|-----------|-----------|
| carousel-renderer | `tools/carousel-renderer/` | Renderiza 6 slides Instagram (1080x1350) a partir de template HTML + JSON | `node render.js <template> <data.json> <out-dir>` |
| ocr-panfleto | `tools/ocr-panfleto/` | Extrai texto de foto de panfleto (Tesseract PT+EN) | `python3 ocr.py <image_path>` |
| whatsapp-baileys | `tools/whatsapp-baileys/` | Stub Baileys (parear · enviar · status) — lojista pareia antes de Clara usar | `node send.js <num> <msg>` |
| pix-qr | `tools/pix-qr/` | Gera BR Code Pix (padrão Banco Central · gratuito) | `python3 pix.py <chave> <valor> <nome> <cidade> [desc]` |
| ig-graph | `tools/ig-graph/` | Stub Instagram Graph API (foto · carrossel · insights) — lojista cria Facebook Developer App | `python3 ig.py <action> ...` |
| gmb | `tools/gmb/` | Stub Google Meu Negócio (post · review reply) — lojista faz OAuth | `python3 gmb.py <action> ...` |
| scheduler | `tools/scheduler/` | APScheduler daemon · lê `posts_agendados` do SQLite · dispara renderer + canal | `python3 scheduler.py` (ou systemd) |
| db | `tools/db/` | SQLite + schema (lojista · produtos · clientes · follow_ups · posts_agendados) | `bash init.sh` · `python3 query.py <sql>` |

## Decisão Clara · árvore

Quando o lojista pede:

- **"faz um carrossel pra mim"** → `carousel-renderer` (T1 hoje · T2..T8 conforme adicionar templates)
- **"lê esse panfleto da concorrência"** (foto anexa) → `ocr-panfleto`
- **"manda WhatsApp pro fulano"** → `whatsapp-baileys` (se pareado · senão pede pareamento)
- **"gera Pix de R$ X pro cliente"** → `pix-qr`
- **"publica no Insta"** → `ig-graph` (se autenticado · senão pede setup)
- **"responde review do Google"** → `gmb` (se autenticado · senão pede setup)
- **"agenda esse post pra terça 9h"** → `db.posts_agendados` + `scheduler` cuida da hora
- **"lembra disso amanhã"** → `db.follow_ups`

## Anti-padrões

- Clara NÃO instala Canva Pro · NÃO sugere agência · NÃO recomenda assinatura paga sem o lojista pedir
- Clara NÃO toca em Pulse · Donna · War Room PulsarH · esses ficam isolados
- Clara NÃO commita nada no git sem aprovação do dono da VPS

## Como adicionar nova tool

1. Cria subdir em `tools/<nome>/`
2. README explicando o que faz + invocação + exemplo
3. Adiciona linha na tabela acima
4. Atualiza `cerebro/skills/clara-tools.md` (mapa de invocação)
5. Atualiza `cerebro/skills/clara-orquestracao.md` (árvore de decisão)

Última atualização: 2026-05-23
