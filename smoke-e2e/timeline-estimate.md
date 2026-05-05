# Timeline estimado — Founder DIY (zip → primeira interação)

Baseado em inspeção de install.sh (114 linhas), wizard.sh (213), onboarding/interview-tree.md, e benchmarks operacionais reais (deploy War Room atual + experiência VPS PulsarH).

## Cronograma honesto

| # | Passo                                                  | Tempo realista | Bloqueador?        | Notas                                                                 |
| - | ------------------------------------------------------ | -------------- | ------------------ | --------------------------------------------------------------------- |
| 1 | Comprar VPS + apontar DNS + login SSH                  | 10-20 min      | humano-dependente  | Hetzner/DO — fora do "12-18 min" da LP                                |
| 2 | Baixar zip + descompactar                              | 30 s           | -                  | `wget` + `unzip`                                                      |
| 3 | `bash installer/install.sh` — preflight + deps         | 1-2 min        | -                  | apt install, docker, jq                                               |
| 4 | install.sh — docker pull (postgres + redis + n8n + mcp) | 3-6 min        | rede VPS           | n8n + postgres+redis + mcp ~700MB combinados                          |
| 5 | install.sh — schema.sql + seed.sql                     | 30 s           | -                  | idempotente                                                            |
| 6 | install.sh — Vercel CLI auth                           | 2-3 min        | humano-dependente  | OAuth no browser do laptop, copia URL                                 |
| 7 | install.sh — Vercel project + deploy War Room          | 2-4 min        | rede + Vercel      | npm install + next build + deploy                                     |
| 8 | install.sh — MCP configure                             | 30 s           | -                  | edita ~/.claude/config.json                                           |
| 9 | `bash installer/bots/wizard.sh` — criar 2 bots BotFather | 5-8 min        | humano-dependente  | falar com @BotFather no Telegram, criar 2 bots, copiar tokens        |
| 10 | Colar BOOTSTRAP-PROMPT.md no Claude Code              | 30 s           | -                  | abre `claude code`, cola prompt                                        |
| 11 | Onboarding interview-tree (12-13 perguntas)           | 8-12 min       | humano-dependente  | nome empresa, ICPs, voz, manifesto, paleta etc                         |
| 12 | Pulse renderiza CLAUDE.md.template + agents + skills  | 1-2 min        | -                  | sem rede, processamento local                                         |
| 13 | Smoke first-message (ping bot Telegram → resposta)    | 30 s           | -                  | valida loop completo                                                  |

**Total realista:** **35-60 min** do zip até "Pulse responde".  
**LP atual ("12-18 min"):** ❌ **incorreto/agressivo.** Subestima em 2-4×.  
**Subset que cabe em 12-18 min:** **só** os passos 3-8 (install.sh stack + Vercel) — ignora compra de VPS, BotFather, onboarding.

## Recomendação de copy LP

Três opções:

### A. Copy honesto (recomendado)
> "Em 30-60 minutos do download ao primeiro recado da Pulse pelo Telegram. Os 30 minutos são pra você comprar a VPS, criar 2 bots no Telegram e responder 12 perguntas sobre seu negócio. Sem código, sem rebuild."

### B. Copy fracionado
> "Instalação 8 minutos. Configuração da equipe 10 minutos. Primeira conversa com Pulse 30 segundos."  
> (omite VPS+BotFather, foco no que é "Pulsar OS" puro)

### C. Manter "12-18 min" mas otimizar install
- Pré-cachear imagens docker (build própria com tag `pulsar-os/postgres:14-pulsar` no GHCR).
- Paralelizar `docker pull` + `vercel login` (impossível: precisa do OAuth humano antes do projeto).
- Pular onboarding (default empresa-genérica) — destrói diferencial.
- **Custo de engenharia:** 2-3 dias. **Ganho:** 2-4 min. **Veredicto:** baixo ROI.

## Bandeira amarela ⚠️

A LP está vendendo **"12-18 minutos"** mas a realidade é **35-60 min** (incluindo BotFather + onboarding humano). Isso vira NPS ruim ("prometeram 18, levei 50"). **Decisão Founder antes de GA:** ajustar copy LP (rota A ou B) **ou** investir 2-3 dias otimizando o install.

Recomendação Falconi: **rota A** (honestidade vende mais retenção do que velocidade falsa).
