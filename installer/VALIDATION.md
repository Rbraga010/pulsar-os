# Validation — Iniciativa 4a (instalador infra base)

**Data:** 05/05/2026
**Validador:** Falconi (VP Ops)
**Tipo:** validacao seca (NAO rodada em VPS de producao)

---

## Checklist

| Item | Status | Comando | Resultado |
|---|---|---|---|
| `bash -n install.sh` | OK | `bash -n install.sh` | sintaxe OK |
| `bash -n lib/*.sh` (10 libs) | OK | for f in lib/*.sh; do bash -n "$f"; done | todas OK (log, prompt, state, preflight, deps, repo, postgres, vercel, mcp, tenant) |
| `bash -n vercel/setup.sh` | OK | `bash -n vercel/setup.sh` | OK |
| `bash -n mcp/configure.sh` | OK | `bash -n mcp/configure.sh` | OK |
| `docker compose config -q` | OK | `POSTGRES_USER=pulsar POSTGRES_PASSWORD=test POSTGRES_DB=pulsar_os docker compose -f docker-compose.yml config -q` | OK (warning `version` removido apos fix) |
| `shellcheck` | N/A | `which shellcheck` | shellcheck nao instalado na VPS dev — pular (sintaxe ja validada por bash -n) |
| Schema cobre tabelas core | OK | `grep "^CREATE TABLE" postgres/schema.sql \| wc -l` | 15 tabelas (agents, skill_references, agent_memory, projects, initiatives, bau_tasks, pipeline_runs, content, inspirations, prospects, leads, automations, expenses, revenues, brand_tokens) |
| Seed: 30 agents | OK | `awk '/^INSERT INTO agents/,/ON CONFLICT/' postgres/seed.sql \| grep -cE "^\('[a-z-]+',"` | **30** (8 oficiais + 22 heads) |
| Seed: 23 skills | OK | `awk '/^INSERT INTO skill_references/,/ON CONFLICT/' postgres/seed.sql \| grep -cE "^\('[a-z-]+',"` | **24** (23 templates + 1 cliente-onboarding-template) — meta era >=23 |
| Seed: brand v1.0 Half-Light | OK | `grep "v1.0-half-light" postgres/seed.sql` | tokens completos (cor, typography, motion, hairline, rules) |
| Seed: 1 projeto default | OK | `grep "Onboarding Pulsar OS" postgres/seed.sql` | 1 row em projects |
| Sem refs PulsarH/Rodrigo/Instituto | OK | `grep -iE "pulsarh\|rodrigo\|instituto" postgres/*.sql \| grep -v "^--"` | LIMPO (so comentarios explicativos no header) |

---

## Notas

1. **Compose warning corrigido:** `version: "3.9"` removido (obsoleto no docker compose v2+).
2. **Sem rodada real:** instalador NAO foi executado em VPS de producao por restricao de escopo (anti-pattern explicito da iniciativa).
3. **Smoke E2E pertence a 4b:** validacao real (mensagem Telegram → Pulse → War Room → resposta) sai com a Iniciativa 4b.
4. **shellcheck recomendado pra release:** quando empacotar pra distribuicao, rodar `apt install shellcheck && shellcheck installer/**/*.sh` num CI pra capturar SC2086 etc.

---

## Artefatos criados

```
installer/
├── install.sh                       # orchestrator (~95 LOC)
├── lib/
│   ├── log.sh                       # cores/log helpers
│   ├── prompt.sh                    # ask/ask_secret/ask_yn
│   ├── state.sh                     # state machine idempotencia
│   ├── preflight.sh                 # OS, disco, portas, dns, claude
│   ├── deps.sh                      # docker, node, psql, gh, vercel
│   ├── repo.sh                      # git clone + git config user.email
│   ├── postgres.sh                  # compose up + schema + seed
│   ├── vercel.sh                    # login + link + env + first deploy
│   ├── mcp.sh                       # warroom + telegram (placeholder)
│   └── tenant.sh                    # /tenant skeleton
├── docker-compose.yml               # Postgres 16-alpine + healthcheck
├── postgres/
│   ├── schema.sql                   # 15 tabelas core (sem refs PulsarH)
│   └── seed.sql                     # 30 agents + 24 skills + brand + 1 projeto
├── vercel/setup.sh                  # wizard standalone
├── mcp/configure.sh                 # configure standalone
├── README.md                        # manual founder (1 pagina)
├── AUDIT-existing-script.md         # auditoria do setup-pulsar-os.sh raiz
└── VALIDATION.md                    # este arquivo
```

15 arquivos. Zero linhas executadas em producao.
