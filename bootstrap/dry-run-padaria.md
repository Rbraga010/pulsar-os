# Dry-run — Padaria do Ze (prova conceitual do Pulse-state-machine-viva)

Simulacao linha-por-linha do PROMPT.md em acao. Tenant ficticio: Padaria do Ze, Founder Jose Silva, em Belo Horizonte. Demonstra que o ciclo de turn do Claude Code, conduzido pelo prompt, ja FUNCIONA como state machine — sem codigo de orquestracao, sem `pipeline_runs`, sem `state.json` no DB. Apenas Read, Write, mcp_telegram_reply.

---

## T0 — Cliente cola PROMPT.md

Jose copia o bloco do PROMPT.md, cola no Claude Code recem-aberto na pasta do Pulsar OS instalado.

### Pulse (chain of thought visivel ao Jose, antes de qualquer tool):

"Ok. Sou Pulseh. Vou carregar o contexto da casa antes de tocar no Telegram."

### Pulse — tools em sequencia:

1. `Read /tenant/onboarding-answers.json` -> retorna erro "file not found". Pulse interpreta: sessao nova, comeca do zero.
2. `Read /core/onboarding/welcome-script.md` -> ok
3. `Read /core/onboarding/interview-tree.md` -> ok
4. `Read /core/onboarding/render-pipeline.md` -> ok
5. `Read /core/onboarding/team-presentation.md` -> ok
6. `Read /core/onboarding/first-mission-router.md` -> ok
7. `Read /core/CLAUDE.md.template` -> ok
8. `Read /core/agents-config.default.json` -> ok
9. `Read /tenant/.env.local` -> retorna `FOUNDER_CHAT_ID=5566778899`

### Pulse pensa:

"Tenho contexto. chat_id pareado. Sem mensagem previa do Jose pra reagir. Disparar Mensagem 1 do welcome direto."

### Pulse — tool:

`mcp_telegram_reply({chat_id: "5566778899", text: "Sou Pulseh. CEO digital da sua empresa a partir de hoje.\n\nAntes de eu comecar a operar, preciso te entrevistar. Vou fazer 12 perguntas curtas — empresa, ICP, produto, time, dor de hoje. Voce escolhe se quer personalizar a inspiracao do meu time tambem.\n\nNao invento nada sobre voce. Se nao souber, prefiro deixar em branco a chutar."})`

---

## T+5s — Jose le a Mensagem 1 no Telegram

Jose responde: `"ok, vamos"`

### Pulse recebe channel msg, processa:

"Resposta generica de aceite. Disparo Mensagem 2 + 3 conforme welcome-script."

### Pulse — tool:

`mcp_telegram_reply` com Mensagem 2 (contrato, ~470 chars).

Jose responde: `"beleza"`

### Pulse — tool:

`mcp_telegram_reply({chat_id, text: "P1 de 12.\n\nQual o nome da sua empresa?"})`

---

## T+45s — P1

Jose: `"Padaria do Ze"`

### Pulse:

"Resposta valida (13 chars, sem URL, dentro de 2-50). Slot empresa.nome = 'Padaria do Ze'. Tenant_slug derivado = 'padaria-do-ze'. Persistir."

### Pulse — tools:

1. `Write /tenant/onboarding-answers.json` com:
   ```json
   {
     "tenant_slug": "padaria-do-ze",
     "started_at": "2026-05-05T10:14:00-03:00",
     "answers": {"empresa.nome": "Padaria do Ze"},
     "skipped_slots": [],
     "review_needed": []
   }
   ```
2. `Write /tenant/.last-question-id` com `P2`
3. `mcp_telegram_reply({chat_id, text: "P2 de 12.\n\nQual o dominio principal (ex: minhaempresa.com.br) e qual a tagline em uma linha? Se nao tem tagline, manda so o dominio."})`

---

## T+1m30s — P2

Jose: `"padariadoze.com.br\nO pao de queijo que abraca"`

### Pulse:

"Parser: linha 1 com ponto = dominio. Linha 2 = tagline. Persistir."

### Pulse — tools:

1. `Write /tenant/onboarding-answers.json` (merge): adiciona `empresa.dominio` e `empresa.tagline`
2. `Write /tenant/.last-question-id` com `P3`
3. `mcp_telegram_reply` com P3 (Founder + bio)

---

## T+2m — P3

Jose: `"Jose Silva\nfilho de padeiro, abri a padaria em 2014, 4 funcionarios, 80% bairro 20% delivery"`

### Pulse:

"Linha 1 = nome. Resto = bio (75 chars, > 30 minimo, ok). Persistir, NAO adornar."

### Pulse — tools:

Persiste `founder.nome` e `founder.bio` (literal). Avanca P4.

---

## T+3m — P4 a P11 (resumido)

Sequencia rapida. Cada uma: Pulse manda pergunta, Jose responde, Pulse Write em answers.json, Write .last-question-id, dispara proxima.

- **P4 ICP primario:** "Familias do bairro 30-60 anos, raio 2km" -> grava
- **P5 ICP secundario:** "Empresas vizinhas, kit cafe da manha corporativo" -> grava
- **P6 produto:** "Pao de queijo artesanal mineiro\nPao de queijo, paes, bolos, cafe, kit corporativo" -> grava `produtos.principal` e `produtos.lista`
- **P7 equipe:** "4" -> `equipe.headcount_humano = 4`
- **P8 voz:** "caloroso, mineiro, familiar\nuso 'sô', 'uai', evito 'cliente' (uso 'freguesia')" -> grava
- **P9 URLs:** Jose manda `pula\nhttps://github.com/zesilva/padaria\nhttps://padariadoze.com.br` -> warroom = `[a entrevistar]` (installer supre), repo e lp gravados
- **P10 foco intel:** "padarias artesanais, marketing de bairro, tendencias de consumo de pao mineiro\nPadaria Pao Nosso, Forneria Sao Sebastiao" -> grava
- **P11 git email:** "jose.silva.padaria@gmail.com" -> grava

A cada P, mini-status: apos P3 e P6 e P9, Pulse insere `"3 de 12. Vamos."` etc.

---

## T+8m — P12 (dor atual — gatilho do roteador)

### Pulse — tool:

`mcp_telegram_reply` com lista numerada de 7 dores.

Jose: `"1 e 3 — vendo pouco e meu instagram ta morto"`

### Pulse:

"Multipla escolha 1+3. Codigo combinado: vende-pouco + conteudo-morto. Persistir, P13 segue normal, ramo combinado dispara apos render."

### Pulse — tool:

Persiste `answers.dor_atual = ["vende-pouco", "conteudo-morto"]`. Avanca P13.

---

## T+9m — P13 (personalizacao opcional)

Jose: `"1: Steve Jobs"`

### Pulse:

"Override 1 declarado: Pulseh -> Steve Jobs. Disparar P13b loop, 1 iteracao."

### Pulse — tool:

`mcp_telegram_reply` com P13b: "Sobre Steve Jobs no papel de CEO orquestrador: em 1-2 frases, por que essa inspiracao? (Eu NUNCA invento — se preferir, manda 'pulse escreve' e eu monto bio publica generica.)"

Jose: `"pulse escreve"`

### Pulse:

"Bio publica generica, flag review-needed. Persistir override, FIM da entrevista."

### Pulse — tool:

`mcp_telegram_reply({text: "Pegou tudo. Vou montar o cerebro da casa em 30s. Volta ja."})` + react `tools` na ultima.

---

## T+9m30s — RENDER (provao do conceito)

Pulse executa linha por linha do render-pipeline.md secao 3, todo via tool calls visiveis:

1. `Read /core/CLAUDE.md.template`
2. Substitui mentalmente cada `{{tenant.X}}` pelo valor de answers (`tenant.empresa.nome` -> "Padaria do Ze", `tenant.founder.nome` -> "Jose Silva", etc).
3. `Write /tenant/CLAUDE.md` com texto final renderizado.
4. `Read /core/agents-config.default.json`
5. Aplica override `pulseh.identity.inspiration_name = "Steve Jobs"`, `inspiration_bio_short = "[generica gerada por Pulse — review-needed]"`. Substitui top-level (`tenant_slug = "padaria-do-ze"`, etc).
6. `Write /tenant/agents-config.json`
7. `Write /tenant/onboarding-followup.md` com slots vazios (so `urls.warroom` neste caso, marcado como [install-step]).
8. Validacao checklist secao 4.3: blocos FIXOS intactos? sim. Slots criticos preenchidos? sim. Schema valida? sim. 30 agents? sim. tenant_slug bate? sim. PASSA.
9. `mcp_warroom_log_agent_memory({agentSlug: "pulseh", type: "milestone", title: "Onboarding Padaria do Ze concluido", content: "12 perguntas em 9min30. 1 override (Pulseh -> Steve Jobs, bio review-needed). Dor combinada: vende-pouco + conteudo-morto. Rota: Caio + Alfredo em paralelo, 7d."})`

---

## T+10m — Apresentacao do time

### Pulse — tool:

`mcp_telegram_reply` com team-presentation.md renderizado:

```
Cerebro montado. Te apresento o time.

Eu, Pulseh, sou o CEO digital de Padaria do Ze. Inspiracao: Steve Jobs. Orquestrador, NAO executor — recebo tua direcao, eco o que entendi, delego pro time, cobro entrega.

Donna (Donna Paulsen) e a secretaria executiva. Filtra o caos antes de chegar em voce. Cobra prazo, alerta atraso, provoca quando precisa.

Time de VPs:
- Alfredo (Alfredo Soares) — Comercial e Marketing.
- Caio (Caio Carneiro) — Comercial Vendas.
- Flavia (Flavia Lippi) — Produtos.
- Falconi (Vicente Falconi) — Operacoes.
- Simon (Simon Sinek) — Pessoas.
- Dalio (Ray Dalio) — Financeiro.

[...resto do texto institucional...]

Ja tenho a primeira missao, baseada na dor que voce me passou. Manda ja.
```

---

## T+10m20s — First-mission (rota combinada vende-pouco + conteudo-morto)

### Pulse — 3 mensagens em sequencia (mcp_telegram_reply x3):

**M1 — proposta combinada (~500 chars):**

"Primeira missao dupla, 7 dias nas duas frentes.\n\nFrente 1 (Caio, VP Vendas): mapeamento funil + 50 leads cold IG/email + script abordagem + 3 fechamentos calibrando.\n\nFrente 2 (Alfredo, VP Marketing): 3 carrosseis publicaveis na semana 1, radar Leo Dias diario, esteira editorial 4 semanas.\n\nDois cards no Kanban /projetos. Mesma semana, equipes diferentes. Voce aprova material antes de publicar."

**M2 — porque unificado (~400 chars):**

"Por que essa combinada.\n\nPipeline vazio + IG morto sao a mesma doenca: sem canal vivo. Caio destrava demanda ativa em 7d. Alfredo vira teu IG em ativo, nao tarefa. Atacar uma so deixa a outra sangrando. Em 7 dias voce tem maquina basica + presenca digital andando — nao promessa."

**M3 — confirmacao:**

"Topa comecar amanha 8h? Caio e Alfredo te chamam no Telegram com perguntas curtas pra calibrar. Manda 'vai' e eu inicio as duas frentes."

---

## T+11m — Aguarda confirmacao

Jose: `"vai!"`

### Pulse:

"Confirmacao explicita. Disparar inicio das 2 missoes. (No produto v1, isso ja sai do escopo do bootstrap — entra no ciclo operacional normal Pulseh -> VPs)."

### Pulse — tools:

- `mcp_warroom_create_project` (1 card vendas, 1 card marketing) — ou equivalente do War Room do tenant
- `mcp_telegram_reply`: "Iniciado. Caio te chama em 30s, Alfredo logo apos. Bom comeco, Jose."

---

## Conclusao da prova

**O ciclo de turn do Claude Code, conduzido pelo prompt, FUNCIONA como state machine viva.** Cada transicao da entrevista corresponde a:

- `Read` (carrega estado) -> `mcp_telegram_reply` (envia pergunta) -> aguarda channel msg -> `Write` (persiste resposta) -> `Write` (avanca ponteiro) -> proxima iteracao.

Sem codigo de orquestracao. Sem tabela `pipeline_runs`. Sem `state.json` em backend. Apenas:

- 1 prompt markdown (PROMPT.md)
- 8 specs markdown carregados via Read (welcome, interview-tree, render-pipeline, team-presentation, first-mission-router, CLAUDE.md.template, agents-config.default.json, .env.local)
- 2 arquivos persistentes (onboarding-answers.json, .last-question-id)
- 1 ferramenta de I/O (mcp_telegram_reply + react)
- O LLM rodando no Claude Code do cliente

Padaria do Ze: 12 perguntas em 9m30s, render em 30s, apresentacao + 1a missao em 1m. Total ~11 minutos do "cole o prompt" ao "vai".

Prova validada conceitualmente. Implementacao real depende apenas do installer (Iniciativa 4) entregar `/tenant/.env.local` com FOUNDER_CHAT_ID e o zip com todos os specs em `/core/`.
