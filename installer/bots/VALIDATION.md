# Iniciativa 4b — VALIDATION

Validacao seca dos artefatos do wizard de bots Telegram + smoke. Smoke E2E real NAO foi executado nesta sessao (limitacao inerente: @BotFather exige Founder humano).

## Artefatos criados

| Arquivo | Tipo | LOC |
|---|---|---|
| `installer/bots/wizard.sh` | bash exec 0755 | 217 |
| `installer/bots/clip-instrucao.md` | tutorial Founder | 110 |
| `installer/bots/clip-instrucao-roteiro-video.md` | roteiro 4min | 105 |
| `installer/bots/README-founder.md` | manual 1pg + FAQ 8 perguntas | 100 |
| `installer/bots/handoff-to-3.md` | contrato 4b→3 | 110 |
| `installer/bots/VALIDATION.md` | este arquivo | — |
| `installer/smoke/first-message.sh` | bash exec 0755 | 165 |
| `installer/smoke/validate.sh` | bash exec 0755 | 110 |

## bash -n (syntax check)

| Script | Status |
|---|---|
| wizard.sh | OK |
| first-message.sh | OK |
| validate.sh | OK |

Comando rodado: `bash -n <script>` — todos passaram sem erro.

## Tutorial cobre os 5 passos criticos

`clip-instrucao.md` contem secoes `## Passo 1` a `## Passo 5`:

1. Abrir @BotFather (com selo azul de verificacao)
2. Criar bot Pulse (`/newbot`, nome, username, capturar token)
3. Criar bot Donna (mesma sequencia)
4. Configuracoes essenciais (`/setjoingroups Disable`, `/setdescription`, `/setuserpic`)
5. Voltar ao terminal e colar tokens (input mascarado)

`grep -c "^## Passo"` retornou 5.

## Roteiro de video — 4 secoes de tempo

`clip-instrucao-roteiro-video.md` cobre 00:00-04:00 com notas de regravacao em 3 pontos sensiveis (BotFather UI, setjoingroups menu, welcome-script.md mudancas).

## Idempotencia do wizard

- `env_get` le `tenant/.env.local` antes de pedir token
- Se token ja salvo, `validate_token` chama `getMe` — se `ok=true`, pula direto
- `merge_mcp_telegram` usa `jq` non-destructive (`(.field // {})` pattern)
- `first-message.sh` checa `agents-config.json` por `founder_chat_id` existente antes de polling

## Handoff to 3 — paths verificados

Todos os 6 artefatos referenciados em `handoff-to-3.md` existem:

| Path | Status |
|---|---|
| `/root/pulsarh-workspace/pulsar-os/onboarding/welcome-script.md` | OK |
| `/root/pulsarh-workspace/pulsar-os/onboarding/interview-tree.md` | OK |
| `/root/pulsarh-workspace/pulsar-os/onboarding/render-pipeline.md` | OK |
| `/root/pulsarh-workspace/pulsar-os/onboarding/team-presentation.md` | OK |
| `/root/pulsarh-workspace/pulsar-os/onboarding/first-mission-router.md` | OK |
| `/root/pulsarh-workspace/pulsar-os/onboarding/exemplo-padaria-conversation.md` | OK |

## Seguranca

- `tenant/.env.local` chmod 0600 (so root le)
- Tokens nunca aparecem em stdout (input via `read -s`)
- `.env.local` deve estar em `.gitignore` raiz do Pulsar OS
- MCP merge nao sobrescreve outras keys em `~/.claude/config.json`

## O que NAO foi executado (pendente do Founder humano)

- Smoke E2E real: criar 2 bots no @BotFather, validar tokens, capturar chat_id, primeira msg chegar no Telegram do Founder
- Resposta do Founder validando interview-tree P1
- Validate.sh rodando contra ambiente live (sem chat_id e tokens reais, todos os checks falham por design)

## Marco

Pulsar OS v1.0 GA — todas as 5 iniciativas (1, 2, 2.5, 3, 4a, 4b) entregues. Falta apenas a primeira execucao real do wizard contra um Founder + Telegram. Nao ha mais codigo a escrever pra primeira venda.
