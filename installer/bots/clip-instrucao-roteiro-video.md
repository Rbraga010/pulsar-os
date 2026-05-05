# Roteiro de video — Pulsar OS bots wizard (3-4 min)

Objetivo: Founder cria os 2 bots no @BotFather e cola tokens no terminal sem ler o markdown — apenas seguindo o video.

Formato: gravacao de tela narrada (Telegram desktop + terminal lado a lado). Voz: tom calmo, ritmo executivo, sem hype.

---

## 00:00 — 00:15 — Hook

(Cena: terminal com prompt do wizard aguardando)

Narracao: "Em quatro minutos, seu Pulse e sua Donna vao estar no ar no Telegram. Voce so vai precisar de duas coisas: o app aberto, e atencao no que eu vou apontar."

(Texto na tela: `pulsar-os bots-wizard` piscando)

---

## 00:15 — 01:30 — Criar Pulse no @BotFather

(Cena: corte pra Telegram. Busca "@BotFather", abre conversa)

Narracao: "Busca @BotFather. E o bot oficial do Telegram pra criar outros bots. Tem o selo azul. Se aparecer outro com o mesmo nome, ignora — o oficial tem o selo."

(Cena: clicar INICIAR, BotFather retorna menu)

Narracao: "Manda `/newbot`. Ele vai te pedir o nome — esse aqui e o que voce ve em cima da conversa. Sugiro `Pulse` mais o nome da sua empresa."

(Demonstrar: digita `Pulse Padaria do Ze`)

Narracao: "Agora o username. Tem duas regras: termina em `bot`, e e unico no Telegram inteiro. Se der `username taken`, voce tenta uma variacao — bota o nome da cidade, um numero, qualquer coisa."

(Demonstrar: digita `padariadozepulse_bot`, BotFather retorna `Done! Congratulations`)

Narracao: "Pronto. Olha esse codigo grande aqui — comeca com numeros, dois pontos, e uma sequencia de letras. Esse e o token. Pensa nele como senha do bot. Pressiona e segura pra copiar inteiro."

(Highlight visual no token, copia animada)

> **Nota de regravacao:** se BotFather mudar o layout da resposta (ja mudou em 2024), regravar so este trecho.

---

## 01:30 — 02:30 — Criar Donna

Narracao: "Mesma coisa pra Donna. `/newbot` de novo."

(Demonstrar rapido: nome `Donna Padaria do Ze`, username `donna_padariadoze_bot`)

Narracao: "Copia o segundo token. Agora voce tem dois tokens guardados — Pulse e Donna. A ordem importa, nao mistura."

(Texto na tela: 2 tokens borrados lado a lado, com labels)

---

## 02:30 — 03:00 — Configuracoes essenciais

Narracao: "Antes de voltar ao terminal, dois ajustes. Primeiro, garante que os bots so funcionam em conversa privada. Manda `/setjoingroups`, escolhe o bot, e clica em **Disable**. Faz pros dois."

(Demonstrar /setjoingroups → escolhe Pulse → Disable, repete pra Donna)

Narracao: "Descricao e foto sao opcionais mas deixam bonito. Pulse pode ter um tom dourado escuro. Donna, algo mais elegante. Pula se quiser."

> **Nota de regravacao:** se voce trocar a paleta da Brand v1.0, refaz so este trecho com a nova cor.

---

## 03:00 — 03:30 — Voltar ao terminal e colar tokens

(Cena: corte pro terminal, wizard aguardando)

Narracao: "Volta pra janela do wizard. Aperta `q` pra fechar o tutorial. Ele pergunta `Voce ja criou o bot Pulse?` — responde `s`. Cola o primeiro token. Note que o input e oculto, voce nao ve os caracteres. E proposital, e seguranca."

(Demonstrar: cola token Pulse → wizard valida → mostra "✅ Pulse: @padariadozepulse_bot")

Narracao: "Validou. Vai pra Donna agora."

(Demonstrar: cola token Donna → "✅ Donna: @donna_padariadoze_bot")

---

## 03:30 — 04:00 — Smoke test ao vivo

Narracao: "Ele pergunta se pode disparar a primeira mensagem do Pulse agora. Responde `s`."

(Demonstrar: wizard pede `/start` → corte rapido pro Telegram → Founder digita /start → corte pro terminal → wizard captura chat_id → primeira mensagem do Pulse aparece no Telegram)

Narracao: "Pulse acabou de te entrevistar. Sao 12 perguntas curtas. A partir daqui, voce conversa direto com ele no Telegram. O onboarding ritual e a proxima etapa — Pulse te guia."

(Tela final: dois bots ativos no Telegram + texto "Pulsar OS v1.0 — vivo no seu Telegram")

---

## Notas de producao

- Resolucao: 1920x1080. Zoom no terminal e no Telegram (legibilidade mobile).
- Borrar tokens reais em pos. Usar tokens fake nas takes.
- Subtitulos PT-BR fechados (acessibilidade + autoplay sem audio).
- Trilha: silencio ou ruido branco baixo. Sem musica de stock.
- CTA final: "Quando os bots estiverem ativos, Pulse te chama." (sem URL, sem upsell)

## Trechos que mais regravam

1. 01:00 (BotFather token format) — cada vez que Telegram muda layout
2. 02:30 (setjoingroups menu) — Telegram as vezes reorganiza
3. 03:30 (mensagem inicial Pulse) — qualquer mudanca no welcome-script.md exige regravar
