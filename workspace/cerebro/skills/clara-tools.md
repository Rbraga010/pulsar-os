---
slug: clara-tools
title: Mapa das ferramentas locais · quando e como Clara invoca cada uma
category: orchestration
agent: clara
version: v1.0
lastReview: 2026-05-23
---

# Skill · Clara Tools

## Quando ler esta skill

Toda vez que Clara classifica intent e precisa **executar** algo (gerar imagem · enviar WhatsApp · gerar Pix · agendar post · consultar CRM).

## Princípio

**GRATIS BY DEFAULT.** Toda tool em `tools/` é gratuita · local · auditável. Clara NUNCA recomenda solução paga (Canva Pro, agência, PSP, etc) sem o lojista pedir explicitamente.

**Tool antes de criatividade.** Se existe tool, USA · não improvisa. Se não existe, Clara pode propor criar (vira issue pro Rodrigo).

**Tool exige API key?** Skill `clara-tools-setup.md` ensina o dono a pegar cada chave em linguagem de balcão. Quando uma tool retorna `exit 2` com mensagem "preciso de chave X", Clara consulta essa skill e GUIA o dono · não despeja erro técnico.

---

## Tabela de invocação

| Intent do lojista | Tool | Comando |
|-------------------|------|---------|
| "faz um carrossel pra mim" | `carousel-renderer` | `node tools/carousel-renderer/render.js <template> <data.json> <out-dir>` |
| "lê esse panfleto" (foto anexa) | `ocr-panfleto` | `python3 tools/ocr-panfleto/ocr.py <imagem>` |
| "gera Pix de R$ X" | `pix-qr` | `python3 tools/pix-qr/pix.py <chave> <valor> <nome> <cidade> [desc]` |
| "manda WhatsApp pro João" | `whatsapp-baileys` | `node tools/whatsapp-baileys/send.js <num> <msg>` |
| "posta no meu Insta" | `ig-graph` | `python3 tools/ig-graph/ig.py publish_carousel <urls...> <caption>` |
| "publica no Google Meu Negócio" | `gmb` | `python3 tools/gmb/gmb.py create_post <loc_id> "<texto>" --image=URL` |
| "responde os reviews do Google" | `gmb` | `python3 tools/gmb/gmb.py list_reviews <loc> ⇒ reply_review <name> "<resposta>"` |
| "agenda esse post pra terça 9h" | `db` + `scheduler` | INSERT em `posts_agendados` · scheduler dispara na hora |
| "lembra de me cobrar isso amanhã" | `db.follow_ups` | INSERT em `follow_ups` |
| "quem do CRM tá há +30 dias sem contato?" | `db.clientes` | SELECT com filtro `ultima_visita` |
| "cria uma foto de X pra eu postar" | `image-gen` | `node tools/image-gen/generate.mjs "<prompt>" [--aspect=...]` · exige `GOOGLE_AI_API_KEY` |
| "responde em áudio" / "manda essa msg falada" | `tts` | `python3 tools/tts/say.py "<texto>" [--voice=Kore]` · exige `GOOGLE_APPLICATION_CREDENTIALS` ou `OPENAI_API_KEY` |
| "faz um reels disso" / "vídeo curto vertical" | `video-remotion` | `bash tools/video-remotion/render.sh <props.json>` · sem API · 100% local |
| "pesquisa pra mim sobre X" / "qual a notícia hoje" | `websearch` | `python3 tools/websearch/search.py "<query>"` · grátis com DDG (default) ou Brave |
| "olha essa foto e me diz X" / "lê esse contrato" | Vision **nativa** | `Read <foto.jpg>` direto na sessão (Claude Max ou Codex enxergam · zero API extra) |
| "agenda reunião com X amanhã" | `google-workspace/calendar` | `python3 tools/google-workspace/calendar.py create_event --title=... --start=...` · exige OAuth Google |
| "lista meus compromissos hoje" | `google-workspace/calendar` | `python3 tools/google-workspace/calendar.py list_events` · exige OAuth Google |
| "manda email pro fornecedor" | `google-workspace/gmail` | `python3 tools/google-workspace/gmail.py send_email --to=... --subject=... --body=...` · exige OAuth Google |
| "como tá meu preço do tênis X?" / "tô caro?" | `pricing-monitor` | `python3 tools/pricing-monitor/monitor.py "<descricao>" --cidade=<cidade>` · grátis · websearch DDG · skill `clara-pricing.md` |
| "quanto vou vender de Y semana que vem?" / "preciso comprar do fornecedor?" | `forecast` | `python3 tools/forecast/forecast.py --por=produto --horizonte=4` · lê tabela `vendas` do SQLite · skill `clara-forecast.md` |
| "manda pesquisa pro cliente que comprou semana passada" | flow NPS via scheduler + whatsapp-baileys | scheduler agenda T+7 · whatsapp-baileys envia · Clara classifica resposta automaticamente · skill `clara-nps.md` |

---

## Detalhe por tool

### 1. carousel-renderer (PRIORIDADE MÁXIMA)

Renderiza carrossel Instagram 1080x1350 a partir de template HTML + JSON.

**Quando usar:**
- Lojista pede post promocional novo
- Lojista mandou ideia/copy e quer ver "como ficaria"
- Clara propõe campanha (Black Friday · Volta às aulas · plano novo Claro)

**Templates disponíveis:**
- `T1-claro-30gb` · Claro Controle 30GB R$ 54,90 · 6 slides (capa · features · pra-quem · preço · objection · CTA)

**Padrão de invocação (Bash interno Clara):**

```bash
# 1. monta data.json a partir da memória do lojista + oferta
cat > /tmp/clara-data-${session}.json <<EOF
{
  "store_name": "${loja_nome}",
  "store_address": "${endereco}",
  "store_whatsapp": "${whatsapp}",
  "store_instagram": "${instagram}",
  ...
}
EOF

# 2. roda renderer
out=$(PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser \
  node /opt/clones/clara/workspace/tools/carousel-renderer/render.js \
  /opt/clones/clara/workspace/tools/carousel-renderer/templates/T1-claro-30gb.html \
  /tmp/clara-data-${session}.json \
  /tmp/clara-carousel-${session}/)

# 3. paths em $out (1 por linha) · Clara anexa via Telegram
```

**Depois de renderizar:**
- Salva os PNGs em `data/renders/manual-{timestamp}/`
- Manda os 6 PNGs no Telegram pro lojista aprovar
- Se aprovado · pergunta se quer publicar agora (IG/WA Status) ou agendar
- Se agendar · INSERT em `posts_agendados`

---

### 2. ocr-panfleto

Extrai texto de foto de panfleto.

**Quando usar:**
- Lojista mandou foto da promoção da concorrência ("olha o que a Vivo tá fazendo")
- Lojista mandou foto da própria oferta antiga e quer "atualizar"

**Padrão:**
```bash
result=$(python3 /opt/clones/clara/workspace/tools/ocr-panfleto/ocr.py /tmp/foto.jpg)
texto=$(echo "$result" | jq -r .text)
conf=$(echo "$result" | jq -r .confidence_estimate)

if [ "$conf" = "low" ]; then
  # fallback: Clara olha a imagem direto (Claude Vision já no contexto)
  echo "Texto curto/ruidoso · vou olhar a foto direto"
fi
```

---

### 3. pix-qr

Gera Pix Copia-e-Cola + QR code PNG.

**Quando usar:**
- Lojista vai cobrar cliente direto via Pix (sem maquininha · sem PSP)
- Cliente preferiu pagar via Pix em vez de cartão

**Padrão:**
```bash
# pega chave Pix da memória da loja
chave=$(cat cerebro/memory/loja.md | grep "chave_pix:" | cut -d: -f2- | xargs)
# ou direto do DB:
chave=$(python3 tools/db/query.py --json "SELECT chave_pix, pix_nome, pix_cidade FROM lojista WHERE id=1")

python3 /opt/clones/clara/workspace/tools/pix-qr/pix.py \
  "$chave" 54.90 "$pix_nome" "$pix_cidade" "Claro 30GB · cliente João" \
  --out=/tmp/pix-cliente.png

# devolve: payload (texto copia-e-cola) + PNG (foto Telegram)
```

---

### 4. whatsapp-baileys

WhatsApp self-hosted (sem WhatsApp Business API paga).

**Pré-requisito:** lojista pareou antes via `pair.js`.

**Quando usar:**
- Lojista pede pra enviar WhatsApp pro cliente
- Follow-up automático (scheduler invoca scheduler → DB → mensagem)
- Notificação pós-venda

**Padrão:**
```bash
# 1. checa se sessão existe
if [ ! -d /opt/clones/clara/workspace/tools/whatsapp-baileys/session ]; then
  echo "lojista precisa parear primeiro"
  # Clara: "pra eu mandar WhatsApp por você, precisa parear · pereia agora?"
  exit 0
fi

# 2. envia
node /opt/clones/clara/workspace/tools/whatsapp-baileys/send.js \
  "5515999999999" "Oi · seu pedido tá pronto · pode buscar quando quiser"
```

---

### 5. ig-graph

Instagram Graph API (publicar foto · carrossel · insights).

**Pré-requisito:** lojista fez OAuth (`.env` com `IG_USER_ID` + `IG_ACCESS_TOKEN`).

**Padrão:**
```bash
# se .env não tem, Clara pede pro lojista fazer setup (link guiado em tools/ig-graph/README.md)
[ -z "$IG_USER_ID" ] && echo "OAuth IG pendente"

# publish carrossel
python3 tools/ig-graph/ig.py publish_carousel \
  https://cdn.lojista.com/slide-1.png \
  https://cdn.lojista.com/slide-2.png \
  ... \
  "Promoção Claro · arrasta pra ver"
```

**Limitação:** IG exige URL pública das imagens · Clara precisa subir PNGs pro CDN do lojista (Nginx local ou Cloudflare R2 ou GitHub Pages) · ver roadmap.

---

### 6. gmb

Google Meu Negócio.

**Pré-requisito:** OAuth no Google Cloud · `.env` com `GMB_ACCESS_TOKEN` + `GMB_ACCOUNT_ID`.

**Padrão:**
```bash
# listar reviews novos não respondidos
reviews=$(python3 tools/gmb/gmb.py list_reviews "accounts/X/locations/Y")
# pra cada review · Clara gera resposta no tom do lojista · pede aprovação · responde
```

---

### 7. scheduler

Daemon que executa o calendário editorial.

**Quando usar:**
- Lojista quer agendar post pra futuro ("publica isso terça 9h")

**Padrão:**
```bash
# Clara INSERT em posts_agendados
python3 tools/db/query.py --exec "
  INSERT INTO posts_agendados
    (agendado_para, canal, tipo, template, data_json, caption, status)
  VALUES
    ('2026-05-27T09:00:00', 'instagram', 'carrossel', 'T1-claro-30gb',
     '$(cat data.json | jq -c .)',
     'Promoção da semana · 30GB Claro',
     'agendado')
"
# scheduler systemd vai pegar na hora certa
```

---

### 8. db

SQLite local. Tudo persistente: lojista · produtos · clientes · follow-ups · posts · eventos.

**Padrão (Clara consulta):**
```bash
# JSON pra processar
python3 tools/db/query.py --json "SELECT * FROM v_followups_pendentes"

# Tabular pra debug humano
python3 tools/db/query.py "SELECT nome, whatsapp, ticket_total FROM clientes ORDER BY ticket_total DESC LIMIT 10"

# Exec
python3 tools/db/query.py --exec "INSERT INTO clientes (nome, whatsapp, origem) VALUES ('João', '5515999999999', 'balcao')"
```

---

### 9. image-gen

Gera imagem realista por prompt (Imagen 4 do Google AI Studio).

**Quando usar:**
- Lojista pede "cria uma foto pra eu postar" sem mandar imagem própria
- Clara propõe capa visual pra carrossel/reel (gera o hero, joga no template)

**Pré-requisito:** `GOOGLE_AI_API_KEY` no `.env`. Se ausente, tool sai com `exit 2` · Clara puxa skill `clara-tools-setup.md` e GUIA o dono.

**Padrão:**
```bash
out=$(node /opt/clones/clara/workspace/tools/image-gen/generate.mjs \
  "Foto editorial de vitrine de loja de bairro, luz quente" \
  --aspect=3:4 \
  --out=/tmp/clara-img-${session}.png)
# anexa $out no Telegram via reply files=[]
```

### 10. tts (text-to-speech)

Manda áudio com voz feminina natural em PT-BR. Default Google Cloud TTS (grátis 4M chars/mês), fallback OpenAI.

**Quando usar:**
- Lojista pediu "responde em áudio" / "manda falando"
- Mensagem longa que fica melhor ouvindo (acolhimento · explicação)
- Lojista tá dirigindo / cozinhando / não pode ler

**Pré-requisito:** UMA das duas keys (`GOOGLE_APPLICATION_CREDENTIALS` ou `OPENAI_API_KEY`).

**Padrão:**
```bash
out=$(python3 /opt/clones/clara/workspace/tools/tts/say.py \
  "Oi João, hoje eu sugiro a gente atacar os top 5 clientes que sumiram." \
  --voice=Kore \
  --out=/tmp/clara-voice-${session}.ogg)
# manda $out como voice note (reply files=[$out])
```

### 11. video-remotion

Renderiza reel vertical 1080x1920 de 15s (3 cards animados). 100% local · sem API.

**Quando usar:**
- Lojista pede "faz um reels"
- Clara propõe formato vídeo curto (Stories · TikTok · Shorts)

**Sem pré-requisito de API.** Roda local · primeira execução baixa Remotion ~200MB (1x só).

**Padrão:**
```bash
cat > /tmp/clara-reel-${session}.json <<EOF
{"hook": "$hook", "oferta": "$oferta", "cta": "$cta",
 "color1": "#C9A84A", "color2": "#0B0C1F", "foto": ""}
EOF

out=$(bash /opt/clones/clara/workspace/tools/video-remotion/render.sh \
  /tmp/clara-reel-${session}.json \
  --out=/tmp/clara-reel-${session}.mp4)
```

### 12. websearch

Pesquisa web · DuckDuckGo grátis (default) · Brave (alternativa paga grátis até 2k/mês).

**Quando usar:**
- Lojista pergunta info factual ("preço do gás esta semana?", "horário do Banco em Sorocaba?")
- Clara precisa cruzar notícia/dado externo

**Sem pré-requisito de API por default.** DDG funciona out-of-the-box.

**Padrão:**
```bash
results=$(python3 /opt/clones/clara/workspace/tools/websearch/search.py \
  "preço botijão gás Sorocaba 2026" --limit=5)
echo "$results" | jq -r '.[].snippet'
```

### 13. Vision · NATIVA da sessão (sem tool externa)

Vision é capacidade nativa do motor (Claude Max OU Codex OpenAI · ambos enxergam foto). Clara usa direto a sessão dela · NÃO precisa de script Python · NÃO precisa de API key separada.

**Quando usar:**
- Foto de vitrine · "tá organizada?" · "o que melhoraria?"
- Foto de contrato · "quais os 3 pontos críticos?"
- Print WhatsApp do cliente · "o que ele quer?"
- Foto de estoque · "o que falta?"

**Decision:** texto impresso simples → `ocr-panfleto` (Tesseract grátis · funciona offline · não consome cota do motor); cena/análise/conversa → Vision nativa.

**Padrão:**
- Foto chega no bot Telegram · bot baixa pra disco local · expõe path pra Clara
- Clara usa `Read <caminho-da-foto.jpg>` na sessão atual
- Claude/Codex vê a imagem direto · responde com análise

Sem subprocess. Sem `python3 tools/...`. Sem API key avulsa.

### 14. google-workspace (calendar + gmail)

Agenda Google + envio de email via Gmail do dono.

**Quando usar:**
- Lojista pede "agenda reunião com X amanhã 9h"
- Lojista pede "manda email pro fornecedor pedindo Y"
- Lojista pergunta "o que tenho na agenda hoje?"

**Pré-requisito:** OAuth feito 1x (`python3 tools/google-workspace/setup.py`).

**Padrão calendar:**
```bash
python3 /opt/clones/clara/workspace/tools/google-workspace/calendar.py create_event \
  --title="Reunião Pedro" --start="2026-05-26T09:00" --duration=60
```

**Padrão gmail:**
```bash
python3 /opt/clones/clara/workspace/tools/google-workspace/gmail.py send_email \
  --to=fornecedor@x.com --subject="Pedido tabela" --body="Oi · ..."
```

---

## Anti-padrões

❌ Clara não verbaliza "vou usar a tool X" pro lojista · ela diz "deixa comigo · daqui pouco te mostro"
❌ Clara não baixa Canva · não cria conta de SaaS pago sem o lojista pedir
❌ Clara não inventa template novo se T1 já resolve (parametriza via JSON em vez de criar T2)
❌ Clara não salta o DB · toda info de CRM vai pra `clientes`/`follow_ups`/`eventos` · nunca em memory soltinha
❌ Clara não invoca tool sem antes ler a memória do lojista (chave Pix · WhatsApp · IG handle ficam em `lojista` table)
❌ Clara não responde "fiz o post" sem ter rodado a tool de verdade · checa exit code + paths gerados

## Loop de aprendizado

Toda nova tool adicionada em `tools/`:
1. README explica o que faz · exemplo de invocação · anti-padrões
2. Atualiza tabela em `clara-tools.md` (essa skill)
3. Atualiza tabela em `CLAUDE.md` (boot)
4. Atualiza decision tree em `clara-orquestracao.md` (intent → tool)
5. Cron de higiene valida: existe tool · README · skill atualizada · 3 fontes sincronizadas
