# Auditoria — `setup-pulsar-os.sh` existente

**Auditor:** Falconi (VP Ops)
**Data:** 05/05/2026
**Arquivo auditado:** `/root/pulsarh-war-room/setup-pulsar-os.sh` (267 linhas)
**Iniciativa:** 4a — Instalador infra base

---

## 1. O que ele faz hoje?

Wizard interativo monolítico em 9 passos:

1. Pré-flight (node 18+, docker, docker-compose, git, openssl)
2. Coleta dados founder (nome, email, empresa, slug, cor)
3. Coleta tokens Telegram (2 bots) + chat_id
4. Escolha de DB (Docker local OU URL externa)
5. Escolha demo (workspace Acme demo OU vazio)
6. Geração `.env` na raiz
7. `docker compose up -d` (Postgres) + wait healthcheck
8. `npm install` + `npx prisma migrate deploy`
9. Seed (`scripts/seed-demo-acme.ts` OU `scripts/seed-empty.ts`)
10. Smoke test (`npm run build`, `npm start`, curl `/api/health`)

Tudo num único arquivo, sem split em libs.

---

## 2. Reaproveitável vs PulsarH-específico

### Reaproveitável (50-60% do código)
- Header ASCII + helpers de cor/log (`step`, `ok`, `warn`, `err`, `ask`, `ask_secret`)
- Pré-flight de dependências (node, docker, git, openssl)
- Geração de `.env` com `openssl rand` pra secrets
- Loop de healthcheck Postgres com `pg_isready`
- Estrutura geral de prompts interativos

### PulsarH-específico ou inadequado pra Iniciativa 4a
- Cor primária default `#7C3AED` (DEPRECADO — Brand v1.0 é gold `#C9A84A`)
- Telegram bots no fluxo principal (Iniciativa 4b — separar)
- `seed-demo-acme.ts` e `seed-empty.ts` referenciam scripts do war-room PulsarH
- Não tem step de Vercel link/env/deploy (faltava)
- Não instala MCP servers no Claude Code do cliente
- Não força `git config user.email` (risco deploy ERROR Vercel)
- Smoke test só roda `npm start` local — Iniciativa 4b deve testar deploy real
- Não tem split em `lib/` — vira monolito de 267 linhas que cresce

### Faltava
- Instalação de docker/node/gh em VPS clean (assume tudo instalado)
- Seed dos 30 agents canônicos + 23 skills generalizadas + brand tokens
- Cópia/render de `CLAUDE.md.template` → `tenant/CLAUDE.md`
- Configuração MCP servers em `~/.claude/config.json`
- Validação domínio aponta pra VPS (`dig +short`)
- Idempotência por função (cada step "já feito? skip")

---

## 3. Decisão final: HÍBRIDA — reaproveitar parcial, refazer estrutura

**Veredicto:** **Refazer estrutura + colar 40-50% das linhas como helpers/funções.**

Razões:
- Monolito de 267 linhas é manutenção ruim. Quebrar em `lib/*.sh` (preflight, postgres, vercel, mcp, repo, env) facilita teste seco e idempotência.
- Iniciativa 4a (infra) e 4b (Telegram + smoke) precisam ser separáveis. Hoje tá tudo grudado.
- Brand tokens, agents canônicos, schema generalizado precisam entrar no seed — não tem hoje.
- Validação Vercel + email author é gap crítico (memória `feedback_vercel_commit_author_email` flagrada Pulse).

**Reaproveitamento concreto:**
- Helpers de cor/log → `installer/lib/log.sh`
- Função `ask`/`ask_secret` → `installer/lib/prompt.sh`
- Pré-flight base → estendido em `installer/lib/preflight.sh`
- Geração `.env` → `installer/lib/env.sh` (sem campos PulsarH)
- Wait Postgres healthcheck → `installer/lib/postgres.sh`

Header ASCII permanece (assinatura do produto).

---

## 4. Próximo passo

Construir `installer/` do zero usando este audit como referência. O `setup-pulsar-os.sh` da raiz fica como **wrapper fino** que chama `installer/install.sh` (1 redirecionamento, mantém URL pública estável).
