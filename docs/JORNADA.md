# Pulsar OS — Jornada de Instalação

> *9 etapas conduzidas pelo Pulse via Telegram. ~90 minutos com você na frente do computador.*

A instalação técnica (`installer/install.sh`) leva ~15 min e provisiona infra. Depois disso, o **Pulse desperta no Telegram** e conduz a jornada — onde a empresa **realmente nasce**.

Cada agente nasce em ordem específica. Não é capricho — **ordem importa**:

1. **Simon primeiro** porque dele sai a *cara* da empresa (cultura, voz, vocabulário). Os outros 7 herdam.
2. **Falconi depois** porque infra precisa estar pronta antes dos VPs operacionais entrarem.
3. **Projeto ZERO antes dos VPs operacionais** para que cada um nasça já alinhado às metas.
4. **Donna por último** porque chefe de gabinete só faz sentido com um time já existente para gerenciar.

---

## Etapa 0 · Pulse boas-vindas (~5 min)

**O que acontece:**

- Pulse manda primeira mensagem no Telegram: *"Sou Pulse. CEO digital da sua empresa a partir de hoje."*
- Apresenta o organograma: 1 CEO + 1 Secretária + 6 VPs + ~25 heads
- Explica a ordem de nascimento dos 8 agentes
- Reforça o contrato: você responde no Telegram, ele constrói

**O que você faz:**

- Lê
- Responde "vai" quando estiver pronto

---

## Etapa 1 · Simon nasce (~15 min) — RH e Cultura

> *Simon nasce primeiro porque dele sai a cara da casa.*

**Pulse pergunta:**

- Nome da empresa
- Domínio principal
- Nome do founder + 2-3 linhas de trajetória
- Setor de atuação
- Tom da cultura: formal / casual / técnico / criativo
- Vocabulário: 3 adjetivos da voz + palavras que evita

**O que nasce:**

- **Simon** — VP People — herda toda essa identidade
- A "cara" da empresa fica registrada em `tenant/agents-config.json` no soul do Simon
- Os próximos 7 VPs vão ler o Simon na inicialização — herdarão tom, vocabulário, princípios

**Por que essa ordem:**

Sem Simon primeiro, cada VP nasceria com identidade default. Com Simon primeiro, **a empresa tem voz unificada do dia 1.**

---

## Etapa 2 · Falconi + War Room (~20 min) — Operações

> *Antes dos VPs operacionais, a casa precisa estar de pé.*

**O que o Pulse faz (você só observa):**

- Provisiona Postgres (15 tabelas)
- Aplica seed (30 agentes, 23 skills, brand tokens)
- Sobe War Room na Vercel no seu domínio
- Configura MCP Server
- Conecta os 2 bots Telegram (Pulse + Donna) ao backend

**O que você faz:**

- Valida que `https://warroom.{seudominio}` abre
- Confirma que vê os 8 agentes na lista do War Room

**O que nasce:**

- **Falconi** — VP Ops — guarda a infra, vai monitorar uptime, alertar drift, rodar auditorias semanais
- **War Room operacional** — onde tudo será rastreado daqui pra frente

---

## Etapa 3 · Projeto ZERO (~10 min) — Levantar a empresa

> *Antes dos VPs operacionais nascerem, eles precisam saber pra onde estão indo.*

**Pulse pergunta:**

- Faturamento atual mensal (faixa: <10k / 10-50k / 50-200k / 200k-1M / 1M+)
- Meta de faturamento em 90 dias
- 3 principais bloqueios hoje (escolha múltipla):
  - Pipeline vazio · Sou eu o gargalo · Conteúdo morto · Produto indefinido · Time desalinhado · Não sei se lucro · Outra
- Nome da pessoa que vai ser o "operador" do War Room (você ou alguém do time)

**O que nasce no War Room:**

- **Projeto "Levantar [Nome da Empresa] — 90d"**
- Iniciativas SMART criadas automaticamente baseadas nos bloqueios
- Cada VP que nasce a partir daqui já recebe esse contexto

**Por que essa ordem:**

Os próximos VPs (Flávia, Alfredo, Caio, Dalio) vão ler o Projeto ZERO ao nascer. Eles vão **alinhar suas skills às metas reais da empresa** — não ficam sendo VPs genéricos.

---

## Etapa 4 · Flávia nasce (~8 min) — Produtos

**Pulse pergunta:**

- Carro-chefe (produto principal) + ticket
- Outros produtos da esteira + tickets
- Margem média (estimativa)

**O que nasce:**

- **Flávia** — VP Produtos — calibrada com o catálogo real
- **Catálogo no War Room** — visível em `/produtos`

---

## Etapa 5 · Alfredo nasce (~10 min) — Marketing

**Pulse pergunta:**

- ICP primário (idade, perfil, dor que você resolve)
- ICP secundário (se existir)
- Brand kit: cores principais (hex), logo (URL ou upload), fonte preferida
- 2-3 concorrentes diretos para o radar

**O que nasce:**

- **Alfredo** — VP Marketing — com brand DNA + ICP definido
- **Heads do Alfredo** (Betina copy, Maurício design, Léo Dias radar) já calibrados
- **Radar diário** começa a rodar amanhã às 6h no Telegram

---

## Etapa 6 · Caio nasce (~8 min) — Comercial

**Pulse pergunta:**

- Onde seu cliente está (Instagram / LinkedIn / Google Maps / WhatsApp / outros)
- Ticket médio de venda
- Ciclo médio de fechamento (dias)
- Objeções mais comuns (3 frases)

**O que nasce:**

- **Caio** — VP Comercial — com playbook calibrado
- **Heads do Caio** (Hunter Flávio, Closer Dani, Clarissa CS) prontos
- **Daemon de prospecção** configurado (mas não disparado ainda — você decide quando ligar)

---

## Etapa 7 · Dalio nasce (~7 min) — Financeiro

**Pulse pergunta:**

- Ferramenta atual de financeiro (planilha / Conta Azul / Omie / outro)
- Custos fixos mensais aproximados
- Email para receber alertas de margem
- Frequência de DRE: mensal / quinzenal / semanal

**O que nasce:**

- **Dalio** — VP Financeiro — conectado às metas do Projeto ZERO
- **DRE template** no War Room
- **Alertas automáticos** quando margem cai abaixo do limite

---

## Etapa 8 · Donna nasce (~5 min) — Chefe de Gabinete

> *Donna por último porque ela só faz sentido com time pronto.*

**Pulse pergunta:** (poucas)

- Como prefere ser chamada por ela: nome / "Founder" / outro
- Horário de trabalho (define quando ela cobra prazos)
- Tolerância pra sarcasmo: alta / média / baixa

**O que nasce:**

- **Donna** — Secretária Executiva — tem visão completa do time
- Vira o **filtro entre você e o caos** — todas as cobranças, alertas, escalações passam por ela primeiro

---

## Etapa 9 · Primeira tarefa real (~5 min)

> *Pulse executa algo de verdade pra você ver o time vivo.*

Com base no Projeto ZERO + bloqueios declarados, Pulse propõe a **primeira missão concreta**:

- Pipeline vazio? Caio dispara cold IG (50 leads em 7 dias)
- Conteúdo morto? Alfredo monta esteira editorial (3 carrosséis em 7 dias)
- Não sei se lucro? Dalio reconcilia DRE retroativa (3 meses em 7 dias)

**Pulse manda Telegram:**

> *"Primeira missão proposta. Topa começar amanhã 8h?"*

Você responde "vai" → operação começa amanhã.

---

## Resumo da jornada

```
Tempo total ativo:   ~90 min
Sua participação:    responder perguntas no Telegram
O que sai do zero:   8 agentes vivos · War Room operacional
                     Projeto ZERO com metas SMART
                     Primeira missão proposta + agendada
```

**Quando termina, sua empresa não tem só "ferramentas IA" — tem instituto operacional inteiro rodando, com identidade própria, conectado ao seu negócio real.**

---

> *Pulsar não vende, ilumina.*
>
> **— v1.0 · 2026**
