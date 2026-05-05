# Pulsar OS — Installer (Iniciativa 4a)

Instalador da infra base: Postgres + repo + Vercel + MCP. Sem Telegram (a 4b cuida disso).

## Pre-requisitos

| Item | Como obter |
|---|---|
| VPS Ubuntu/Debian 22+ root SSH | DigitalOcean / Hostinger / Hetzner — minimo 2GB RAM, 5GB disk |
| Claude Code instalado | https://docs.anthropic.com/claude-code |
| Assinatura Claude Max | https://www.anthropic.com/pricing |
| Conta Vercel + email correto | https://vercel.com — guarde o email exato |
| Dominio aponta pra IP da VPS (A record) | Registrador (GoDaddy / Registro.br / Cloudflare) |

## Comando unico

```bash
curl -fsSL https://pulsar-os.io/install.sh | bash
```

Ou local:

```bash
git clone "${PULSAR_OS_REPO_URL:-https://github.com/pulsarh-ai/pulsar-os.git}" ~/pulsar-os
cd ~/pulsar-os && bash installer/install.sh
```

## O que o instalador faz (em ordem, ~12-18 min)

1. **Pre-flight** — checa OS, disco, portas, conexao GitHub, Claude Code instalado, DNS.
2. **Coleta tenant basics** — slug, nome, dominio, IP VPS, email Vercel do founder.
3. **Instala dependencias** — Docker, Node 20, psql, gh CLI, Vercel CLI, jq.
4. **Clona repo** Pulsar OS + forca `git config user.email` correto.
5. **Provisiona Postgres** via docker-compose + aplica schema (15 tabelas) + roda seed (30 agents, 23 skills, brand tokens).
6. **Setup Vercel** — login, link projeto, env vars, primeiro deploy de validacao.
7. **Instala MCP servers** (warroom + telegram placeholder) em `~/.claude/config.json`.
8. **Cria esqueleto `/tenant/`** — onboarding-answers.json + agents-config.json (copia default) + CLAUDE.md placeholder.

## O que NAO faz (fica pra Iniciativa 4b)

- Criar bots Telegram (founder cria manualmente no @BotFather)
- Capturar `chat_id` do founder
- Iniciar entrevista de onboarding com Pulse
- Smoke test E2E (mensagem real Telegram → Pulse → War Room → resposta)

## Idempotencia

Pode rodar `bash installer/install.sh` quantas vezes quiser. Estado em `tenant/.install-state` rastreia o que ja foi feito. Se um step falhou no meio, corrija e rode de novo — pula os steps OK.

## Troubleshooting (top 5)

### 1. "Deploy Vercel retornou ERROR"
Email do commit autor (`git config user.email`) nao casa com email da conta Vercel team. Solucao: `git config --global user.email <email-vercel-correto>` e re-deploy.

### 2. "Postgres nao ficou ready em 60s"
Porta 5432 ocupada por outro Postgres. Pare o conflitante (`systemctl stop postgresql` ou `docker stop <container>`) e rode `docker compose -f installer/docker-compose.yml up -d` manual.

### 3. "Claude Code nao instalado"
Veja https://docs.anthropic.com/claude-code. Apos instalar, `which claude` precisa retornar caminho.

### 4. "DNS dominio.com nao aponta pra IP"
Cria A record no seu registrador apontando pra IP da VPS. Aguarda propagacao (5min-2h). Pulsar OS funciona local mesmo sem DNS — DNS so importa pra Vercel domain.

### 5. "vercel link falhou"
Provavel: ja existe projeto com mesmo slug em outra team. Solucao: `vercel link --yes --project <slug-unico>`.

## Rollback / re-install

```bash
docker compose -f installer/docker-compose.yml down -v   # apaga DB
rm -rf tenant/                                           # apaga estado
bash installer/install.sh                                 # roda de novo
```

## Proximo passo apos 4a

Rodar `bash installer/wizard-4b.sh` (entregue na Iniciativa 4b) pra:
- Criar bots @BotFather (CEO + Secretaria)
- Pulse capturar chat_id
- Iniciar entrevista de onboarding
- Gerar `/tenant/CLAUDE.md` final
