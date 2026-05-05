<!--
  Pulsar OS v1.0 — Interview Tree (Simon-first sequence)
  Substitui a v1 anterior (12 perguntas em ordem aleatória) por
  9 etapas onde cada VP nasce na sua hora.

  Total perguntas: ~16 (era 12). Mas distribuídas e contextualizadas
  por etapa — cliente sente progresso, não interrogatório.
-->

# Interview Tree v1.0 — 9 Etapas, nascimento ordenado

> *Cada etapa tem perguntas focadas no VP que vai nascer. Pulse anuncia "Etapa N de 9" no início. Apresenta o VP correspondente no fim de cada etapa via `team-presentation.md`.*

---

## ETAPA 0 — Pulse boas-vindas

Sem perguntas. 3 mensagens de welcome (ver `welcome-script.md`).

---

## ETAPA 1 — Simon nasce (RH/Cultura)

> *Dele sai a CARA da empresa. Os outros 7 VPs herdam.*

### E1.P1 — Nome da empresa

- **Slot:** `tenant.empresa.nome` (alimenta `tenant_slug`, `tenant_name`, `company_name`)
- **Pergunta:** "Qual o nome da sua empresa?"
- **Tipo:** free-text 2-50 chars
- **Skip:** ❌ não (essencial pra render)

### E1.P2 — Founder + bio

- **Slots:** `tenant.founder.nome`, `tenant.founder.bio`
- **Pergunta:** "Qual seu nome (founder) e em 2-3 linhas, sua trajetória? Quanto tempo nesse negócio, o que te trouxe aqui."
- **Tipo:** free-text multi-linha
- **Parser:** primeira linha = nome. Resto = bio.
- **Validação bio:** se < 30 chars, Pulse cobra UMA vez. Sem cobrança forçada.
- **Skip:** nome ❌ não. Bio ✅ ok ([a entrevistar] — Donna cobra T+24h)

### E1.P3 — Domínio + setor

- **Slots:** `tenant.empresa.dominio`, `tenant.empresa.setor`
- **Pergunta:** "Domínio principal (ex: minhaempresa.com.br) e setor de atuação numa frase. Uma linha cada."
- **Tipo:** free-text 2 linhas
- **Validação domínio:** regex
- **Skip:** parcial — domínio essencial

### E1.P4 — Tom + vocabulário (ALMA DO SIMON)

- **Slots:** `tenant.brand.voz`, `tenant.brand.vocabulario`
- **Pergunta:** "Tom da casa em 3 adjetivos (ex: editorial / direto / técnico). Tem palavra que a marca usa muito ou evita? (ex: 'a gente' em vez de 'vocês')."
- **Tipo:** free-text 2-blocos
- **Parser:** linha 1 = voz. Resto = vocabulário.
- **Skip:** ✅ ok ([a entrevistar])

→ **Apresentação: Simon nasceu** (`team-presentation.md` E1)

---

## ETAPA 2 — Falconi + War Room

> *Provisão pura. Sem perguntas pro founder — installer/script já tem o que precisa.*

Não tem perguntas nesta etapa. Pulse roda:
1. `installer/install.sh` se ainda não rodou (verificação idempotente)
2. Sobe War Room na Vercel
3. Aplica seed
4. Ativa MCP

→ **Apresentação: Falconi nasceu** (`team-presentation.md` E2) com link `https://warroom.{{dominio}}`

---

## ETAPA 3 — Projeto ZERO (metas SMART)

> *Antes dos VPs operacionais nascerem, eles precisam saber pra onde a empresa vai.*

### E3.P1 — Faturamento atual

- **Slot:** `tenant.financeiro.faturamento_atual`
- **Pergunta:** "Faturamento mensal atual. Qual faixa: 1) <10k · 2) 10-50k · 3) 50-200k · 4) 200k-1M · 5) 1M+"
- **Tipo:** choice 1-5
- **Skip:** ✅ ok ([a entrevistar])

### E3.P2 — Meta 90 dias

- **Slot:** `tenant.financeiro.meta_90d`
- **Pergunta:** "Meta de faturamento mensal em 90 dias. Número direto (ex: '50k', '200k'). Pode chutar."
- **Tipo:** free-text número/faixa
- **Skip:** ✅ ok ([a entrevistar])

### E3.P3 — Bloqueios

- **Slot:** `tenant.dor_atual` (multi)
- **Pergunta:** "Top 3 bloqueios hoje. Marca os números:
  1. Pipeline vazio / vendo pouco
  2. Sou eu o gargalo / não escalo
  3. Conteúdo morto / IG sem tração
  4. Produto novo / nicho indefinido
  5. Time desalinhado
  6. Não sei se lucro
  7. Outra (escreve em uma frase)"
- **Tipo:** choice multi (ex: "1, 3" ou "2 e 6")
- **Parser:** vira lista de buckets (alimenta `first-mission-router.md`)
- **Skip:** vai pra "outras" → Donna cobra T+24h

### E3.P4 — Operador do War Room

- **Slot:** `tenant.team.warroom_operator`
- **Pergunta:** "Quem vai abrir o War Room dia a dia: você mesmo, ou alguém do time? Se for outra pessoa, qual o nome dela?"
- **Tipo:** free-text
- **Skip:** ✅ ok (assume = founder)

→ **Apresentação: Projeto ZERO criado** (`team-presentation.md` E3)

Pulse executa:
- `mcp__warroom__warroom_create_project(name="Levantar {{empresa.nome}} — 90d")`
- Cria 1 iniciativa por bloqueio mapeado em E3.P3

---

## ETAPA 4 — Flávia nasce (Produtos)

### E4.P1 — Carro-chefe

- **Slots:** `tenant.produtos.principal`, `tenant.produtos.principal_ticket`
- **Pergunta:** "Qual o produto carro-chefe e o ticket médio? Formato: 'Nome do Produto · R$ valor'."
- **Skip:** parcial — nome essencial

### E4.P2 — Esteira

- **Slots:** `tenant.produtos.esteira` (lista)
- **Pergunta:** "Outros produtos da esteira? Lista no formato 'Nome · R$ ticket', um por linha. Ou 'só um' se for só o carro-chefe."
- **Skip:** ✅ ok

### E4.P3 — Margem

- **Slot:** `tenant.produtos.margem_media`
- **Pergunta:** "Margem média estimada (em %). Não precisa ser exata. Faixa: 1) <20% · 2) 20-40% · 3) 40-60% · 4) 60%+ · 5) não sei"
- **Tipo:** choice 1-5
- **Skip:** vira "5" (não sei)

→ **Apresentação: Flávia nasceu** (`team-presentation.md` E4)

---

## ETAPA 5 — Alfredo nasce (Marketing)

### E5.P1 — ICP primário

- **Slot:** `tenant.icp.primary`
- **Pergunta:** "Quem é seu cliente ideal hoje? Idade, perfil, dor que você resolve. Uma frase."
- **Skip:** ✅ ok ([a entrevistar])

### E5.P2 — ICP secundário

- **Slot:** `tenant.icp.secondary`
- **Condicional:** dispara se P1 respondida
- **Pergunta:** "Tem um segundo público que você já vende? Manda 'não' se for só um."
- **Skip:** ✅ ok

### E5.P3 — Brand kit

- **Slots:** `tenant.brand.cores`, `tenant.brand.logo_url`, `tenant.brand.fonte`
- **Pergunta:** "Cores principais (até 3 hex, ex: #C9A84A), URL do logo (ou 'sem logo'), e fonte preferida (ex: Inter, Fraunces, ou 'sem preferência')."
- **Tipo:** free-text 3 linhas
- **Parser:** regex hex / URL / texto
- **Skip:** ✅ ok (Maurício gera brand v1 placeholder Half-Light)

### E5.P4 — Concorrentes diretos

- **Slot:** `tenant.concorrentes`
- **Pergunta:** "2-3 concorrentes diretos pro Léo Dias monitorar no radar diário. Manda os @s do Instagram ou URLs."
- **Skip:** ✅ ok

→ **Apresentação: Alfredo + heads nasceram** (`team-presentation.md` E5)

---

## ETAPA 6 — Caio nasce (Comercial)

### E6.P1 — Canais de prospecção

- **Slot:** `tenant.canais_comercial`
- **Pergunta:** "Onde seu cliente está? Marca os canais: 1) Instagram · 2) LinkedIn · 3) Google Maps · 4) WhatsApp · 5) Outro (escreve)"
- **Tipo:** choice multi
- **Skip:** ✅ ok (default = IG)

### E6.P2 — Ticket + ciclo

- **Slots:** `tenant.comercial.ticket_medio`, `tenant.comercial.ciclo_medio`
- **Pergunta:** "Ticket médio de venda (R$) e ciclo de fechamento médio (em dias). Formato: 'R$ valor · N dias'."
- **Skip:** ✅ ok ([a entrevistar])

### E6.P3 — Objeções comuns

- **Slot:** `tenant.comercial.objecoes`
- **Pergunta:** "3 objeções mais comuns que você ouve do cliente antes de comprar. Uma por linha."
- **Skip:** ✅ ok

→ **Apresentação: Caio + heads nasceram** (`team-presentation.md` E6)

Daemons de prospecção configurados mas **não disparados** (decisão do founder ligar depois).

---

## ETAPA 7 — Dalio nasce (Financeiro)

### E7.P1 — Ferramenta atual

- **Slot:** `tenant.financeiro.ferramenta`
- **Pergunta:** "Como controla o financeiro hoje: 1) Planilha · 2) Conta Azul · 3) Omie · 4) Bling · 5) Outro · 6) Não controlo"
- **Tipo:** choice 1-6
- **Skip:** ✅ ok

### E7.P2 — Custos fixos

- **Slot:** `tenant.financeiro.custos_fixos_mes`
- **Pergunta:** "Custos fixos mensais aproximados (R$). Não precisa exato. Faixa: 1) <5k · 2) 5-20k · 3) 20-50k · 4) 50-100k · 5) 100k+"
- **Skip:** ✅ ok

### E7.P3 — Email alerta + frequência

- **Slots:** `tenant.financeiro.email_alerta`, `tenant.financeiro.frequencia_dre`
- **Pergunta:** "Email pra receber alertas de margem crítica? E frequência da DRE: 1) Mensal · 2) Quinzenal · 3) Semanal."
- **Skip:** ✅ ok (default = email do founder + mensal)

→ **Apresentação: Dalio nasceu** (`team-presentation.md` E7)

---

## ETAPA 8 — Donna nasce (Chefe de Gabinete)

### E8.P1 — Como chamar

- **Slot:** `donna.identity.address_form`
- **Pergunta:** "Como prefere ser chamado pela Donna: 1) Pelo seu nome · 2) Founder · 3) Outro (escreve)"
- **Skip:** vira "1" (nome)

### E8.P2 — Horário trabalho

- **Slot:** `tenant.team.work_hours`
- **Pergunta:** "Horário de trabalho típico (ex: '9-18 seg-sex'). Donna cobra prazos respeitando isso."
- **Skip:** ✅ ok (default = 9-18 seg-sex)

### E8.P3 — Tolerância sarcasmo

- **Slot:** `donna.style.sarcasm_level`
- **Pergunta:** "Tolerância pra sarcasmo da Donna: 1) Alta (manda ver) · 2) Média (na medida) · 3) Baixa (educadinha)"
- **Skip:** vira "2" (média)

### E8.P4 — Personalização de identidades (OPCIONAL)

> *Substitui o antigo P13/P13b — agrupado aqui no fim, antes da apresentação final.*

- **Pergunta:** "Quer trocar a inspiração de algum agente? Padrões:
  1. Pulseh — Tallis Gomes
  2. Donna — Donna Paulsen
  3. Alfredo — Alfredo Soares
  4. Caio — Caio Carneiro
  5. Flávia — Flávia Lippi
  6. Falconi — Vicente Falconi
  7. Simon — Simon Sinek
  8. Dalio — Ray Dalio
  
  Pode trocar até 3. Formato: '1: Steve Jobs; 3: Seth Godin'. Ou 'default' pra herdar tudo."
- **Tipo:** free-text estruturado OR "default"
- **Skip:** ✅ ok (= default)

→ **Apresentação: Donna nasceu + time inteiro** (`team-presentation.md` E8)

---

## ETAPA 9 — Primeira tarefa real

Pulse executa a primeira missão real baseada nos bloqueios mapeados em E3.P3:

- Pipeline vazio → Caio dispara cold IG (50 leads em 7d)
- Conteúdo morto → Alfredo monta esteira editorial (3 carrosséis em 7d)  
- Não sei se lucro → Dalio reconcilia DRE (3 meses retroativo em 7d)
- (etc — ver `first-mission-router.md`)

→ **Mensagem final:** *"Sua operação tá no ar."* (`team-presentation.md` E9)

---

## Comandos especiais (todas etapas)

| Comando | Ação |
|---|---|
| `/skip` | Pula a pergunta atual, slot vira `[a entrevistar]` |
| `/pausa` | Marca state `awaiting_user`, Pulse para. Donna cobra +24h |
| `/skip-all` | Pula todas perguntas restantes, render com defaults |
| `/voltar` | Volta 1 pergunta (rewind) |
| `/status` | Pulse mostra: "Etapa N de 9, pergunta X. Falta ~Y min." |

---

## Cobertura de slots

**Total slots tenant:** 28 (era 18 + agora +10 de Dalio/Donna/Brand expandidos)

- Pulse coleta via entrevista: 22
- Installer pre-popula: 6 (vps_ip, db_url, repo_path, vercel_team, bots.pulseh, bots.donna)
- agents-config.json gerado a partir de E8.P4 + defaults

**Cobertura 100% pra render do CLAUDE.md final + agents-config.json.**

---

## Por que mudou da v1 anterior

**v1 anterior:** 12 perguntas em ordem técnica (P1 nome, P2 domínio, P3 founder, ... P12 dor). Cliente respondia mas não sentia "magia".

**v1.0 nova:** 9 etapas onde cada VP nasce na sua hora. Cliente **vivencia 8 nascimentos em sequência**, com Simon-first imprimindo DNA, depois infra, depois metas, depois VPs operacionais alinhados, depois Donna fechando.

**Mais perguntas (16 vs 12) mas distribuídas em narrativa.** Cliente não percebe que respondeu 16 — sente que viveu uma jornada de 90 min.

Isso é o que faz R$297 valer.
