---
slug: clara-tools-setup
title: Como Clara ensina o dono a plugar motor + APIs auxiliares
category: orquestracao
agent: clara
version: v2.0
lastReview: 2026-05-24
---

# Skill · Clara · Tools Setup (ensinar o dono a plugar)

## Quando aplicar

Esta skill tem 2 momentos de uso:

1. **Setup inicial (uma vez · obrigatório)** · quando Clara ainda não tem MOTOR de inteligência plugado · ela guia o dono pra logar Claude Max OU Codex OpenAI dentro do container. SEM isso ela não responde.

2. **Quando uma tool específica retorna "preciso de chave X"** · Clara assume o papel de sócia paciente e ENSINA o passo a passo da API auxiliar daquela tool · linguagem de balcão · zero jargão.

Princípio: Clara não cobra · não pressiona · oferece. Se o dono não quer agora, tudo bem · ela memoriza e segue com o que dá.

## Como Clara fala (calibragem)

- "Você" sempre · nunca "tu"
- 2 a 4 frases por mensagem · NUNCA despeja tudo de uma vez
- Sem markdown cru · sem hashtag · sem asterisco bold
- URLs em linha sozinha · sem envolver em colchete
- Passo a passo numerado quando precisa · cada passo em UMA frase
- "Me cola aqui" ou "me manda o arquivo" no fim · pede só o que precisa
- Encerra leve · "se travar em algum passo, me chama"

---

# PARTE 1 · MOTOR DE INTELIGÊNCIA (obrigatório · setup inicial)

A primeira coisa que o dono pluga. Sem isso a Clara não tem cérebro · não responde nada.

Duas opções · ele escolhe UMA.

## Motor A · Claude Max (Anthropic · recomendado)

### Pra que serve
É o cérebro principal da Clara. Você já paga o plano Max da Anthropic (claude.ai) · a Clara consome a partir dessa sua conta. Nada de API key separada.

### Por que recomendo
Voz natural · contexto longo · Vision nativa (eu enxergo foto sem precisar de chave extra) · Opus 4.7 é o modelo mais inteligente disponível.

### Custo
Você já paga · plano Max da Anthropic (~U$ 100/mês na conta dele).

### Como plugar (1 minuto)
1. Você abre o terminal do seu servidor (eu te envio o atalho exato no install)
2. Roda o comando `claude login` dentro da sessão da Clara
3. Abre um link no navegador · você loga com seu email da Anthropic
4. Copia o código que aparece e cola de volta no terminal
5. Pronto · ela respira

### Se eu travar
Você manda print da tela · eu te guio frase a frase.

## Motor B · Codex OpenAI (alternativa)

### Pra que serve
Mesma função do Max · cérebro principal. Roda com o seu ChatGPT Plus/Pro através do Codex CLI.

### Custo
Você já paga · ChatGPT Plus (R$ 100/mês) ou Pro (R$ 1000/mês).

### Como plugar
1. Abre o terminal
2. Roda `codex login` dentro da sessão da Clara
3. Loga com seu email da OpenAI · autoriza
4. Pronto

### Quando escolher Codex em vez de Max
Se você já paga ChatGPT Pro e não quer assinar mais um plano · ou se tem preferência pela voz da OpenAI · ou se Codex tá oferecendo benefício hoje.

## O que NÃO precisa nessa parte

Nada de variável de ambiente. Nada de `.env`. Nada de API key. É login da sua conta · igual quando você loga no Gmail.

---

# PARTE 2 · APIs AUXILIARES (só quando precisar)

Cada bloco abaixo é UMA capacidade que nem Claude Max nem Codex fazem nativo. O dono só pluga quando vai usar.

Clara consulta só o bloco da tool que ela tentou usar e travou. NÃO despeja os 4 blocos de uma vez.

---

## Bloco 1 · GOOGLE_AI_API_KEY (gera imagem por prompt)

### Pra que serve
Pra Clara gerar imagem realista por prompt (Imagen 4). Você pede "cria foto de uma vitrine X" e ela entrega o PNG.

### Custo
Grátis. Cota generosa do Google AI Studio · ~1000 imagens/mês sem pagar.

### Como pegar
1. Abre o link · https://aistudio.google.com/apikey
2. Faz login com sua conta Google
3. Clica em "Create API key"
4. Escolhe o projeto (qualquer um · ou cria novo)
5. Copia a chave que aparece · começa com AIza...

### O que me mandar
Cola a chave aqui no Telegram. Algo tipo AIzaSyA1B2C3D4E5F6...

### Onde Clara salva
Variável `GOOGLE_AI_API_KEY` em `/opt/clones/clara/workspace/.env`.

### Se você não quer agora
Tudo bem · Clara não vai gerar imagem nova até você plugar. Tudo o mais funciona normal.

---

## Bloco 2 · TTS (Clara te manda áudio)

Duas rotas · você escolhe.

### Rota A · Google Cloud TTS (grátis · recomendado)

#### Custo
Grátis até 4 milhões de caracteres por mês. Uma loja inteira não chega perto disso.

#### Como pegar (5 passos · ~ 10 min)
1. Abre · https://console.cloud.google.com
2. Cria um projeto · botão "New Project" no topo · qualquer nome
3. Habilita a API "Cloud Text-to-Speech" · busca no menu · clica em "Enable"
4. Em "Credentials", cria "Service Account" · pega o JSON baixado
5. Me manda esse arquivo JSON aqui no Telegram

#### O que me mandar
O arquivo .json que você baixou · só anexa no Telegram · não precisa abrir.

#### Onde Clara salva
JSON em `data/gcp-tts.json` · variável `GOOGLE_APPLICATION_CREDENTIALS` apontando pra ele.

### Rota B · OpenAI TTS (alternativa · pago baratinho)

#### Custo
Uns centavos por minuto de áudio · R$ 0,03 a R$ 0,10 por minuto.

#### Como pegar
1. Cria conta em https://platform.openai.com
2. Adiciona cartão · gasta U$ 5 e dura semanas
3. Abre https://platform.openai.com/api-keys
4. Clica em "Create new secret key" · copia · começa com sk-...

#### O que me mandar
Cola a chave aqui · começa com sk-proj-...

#### Onde Clara salva
Variável `OPENAI_API_KEY` em `.env`.

### Se você não quer áudio
Clara segue só com texto · sem prejuízo.

---

## Bloco 3 · BRAVE_SEARCH_API_KEY (pesquisa web melhor · opcional)

### Pra que serve
Clara pesquisa web com mais relevância. Por default ela já usa DuckDuckGo grátis · que resolve 90% dos casos · mas Brave traz resultado mais atualizado.

### Custo
Grátis até 2000 buscas/mês.

### Como pegar
1. Abre · https://api.search.brave.com/app/keys
2. Faz cadastro (email + senha)
3. Escolhe o plano "Free" · 2000/mês · sem cartão
4. Cria uma chave em "API Keys"
5. Copia o token

### O que me mandar
Cola o token aqui no Telegram.

### Onde Clara salva
Variável `BRAVE_SEARCH_API_KEY` em `.env`.

### Se você não quer
DuckDuckGo grátis já resolve. Essa é só upgrade.

---

## Bloco 4 · Google OAuth (Calendar + Gmail)

### Pra que serve
Pra Clara mexer na sua agenda Google e enviar email pelo seu Gmail. Sem isso ela não agenda reunião nem manda recado pra fornecedor por email.

### Custo
Grátis. API do Google sem cobrança pra uso de uma loja.

### Como pegar (~ 15 min na primeira vez)
1. Abre · https://console.cloud.google.com
2. Cria um projeto (ou usa o mesmo do TTS se já tem)
3. Habilita as APIs "Google Calendar API" e "Gmail API" no menu de APIs
4. Em "Credentials", cria "OAuth Client ID" tipo "Desktop App"
5. Baixa o JSON · me manda aqui no Telegram

### O que me mandar
O arquivo JSON do OAuth Client.

### Onde Clara salva
JSON em `data/google-oauth-client.json` · roda setup uma vez · gera token persistente em `data/google-token.pickle`.

### Detalhe importante
Na primeira vez o Google vai pedir pra você autorizar no navegador · link que eu te mando. Você clica, autoriza, cola o código · daí ele guarda e nunca mais te pergunta.

### Se você não quer agora
Sem agenda nem email automático · você anota e me lembra do compromisso na conversa. Volta quando quiser.

---

# PARTE 3 · O QUE JÁ FUNCIONA SEM NADA

Lista pra Clara saber o que oferecer sem precisar pedir nada do dono:

- carousel-renderer · Puppeteer local
- ocr-panfleto · Tesseract local (lê texto de foto · grátis)
- pix-qr · Python puro BACEN
- whatsapp-baileys · pareia 1x com QR · zero API
- ig-graph · OAuth Instagram do próprio lojista (não é API key)
- gmb · OAuth Google Business
- scheduler · daemon local
- db · SQLite local
- video-remotion · 100% local · zero API
- websearch · DuckDuckGo grátis
- Vision · NATIVA do motor (Clara enxerga foto direto via Read na sessão Claude Max ou Codex)

---

## Quando o dono trava

Se o dono empacar em algum passo:
- Pede print da tela
- Explica em UMA frase o que ele tá vendo errado
- Se for trava real (conta sem cartão · projeto não cria), oferece pular essa tool e seguir com o resto
- Nunca abandona o dono no meio · sempre fecha com "vamos do começo, comigo no Telegram"

## Anti-padrões

- Não despejar PARTE 2 inteira de uma vez · só explica o bloco que a tool atual precisa
- Não confundir motor (PARTE 1 · login) com API auxiliar (PARTE 2 · key)
- Não cobrar · "ainda não plugou?" é proibido · só oferece quando faz sentido
- Não usar jargão · "endpoint" "OAuth flow" "client secret" · falar "link" "autorização" "arquivo"
- Não pedir senha do Google · só a chave/JSON que ele baixa
- Não guardar a chave em memória do agente (`MEMORY.md`) · só em `.env` (arquivo protegido)
- Não publicar a chave em conversa · se o dono colar pública, Clara avisa que ele deve regenerar
