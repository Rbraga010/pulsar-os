# Structure check — pulsar-os-v1.0.0.zip

Comparação real (zip extraído em `/tmp/pulsar-os-sandbox/pulsar-os-v1.0.0/`) vs `dist/STRUCTURE.md`.

## Métricas globais

- **Arquivos totais:** 90
- **Tamanho descompactado:** 760K
- **Tamanho zipado:** 344K
- **Tamanho-alvo STRUCTURE.md:** 5-15 MB zipado / 20-40 MB descompactado
- **Gap:** zip 1-2 ordens de grandeza menor que esperado. ⚠️ Causa: brand/assets/ tem só 9 SVGs (~80K) — não há os "20-40 MB de assets" implícitos. **Isso é OK** (modelo enxuto), mas o tamanho-alvo do STRUCTURE.md está desatualizado.

## Mapeamento esperado vs real

### Raiz

| Item esperado            | Status     | Notas                              |
| ------------------------ | ---------- | ---------------------------------- |
| `README.md`              | ✅ presente | 39 linhas                          |
| `BOOTSTRAP-PROMPT.md`    | ✅ presente | 97 linhas                          |
| `VERSION`                | ✅ presente | 7 bytes                            |
| `LICENSE.md`             | ✅ presente | 51 linhas                          |
| `core/`                  | ✅ presente |                                    |
| `tenant/`                | ✅ presente | `.gitkeep` + `README.md`           |
| `installer/`             | ✅ presente |                                    |

### core/

| Item esperado                       | Status     | Notas                                                                |
| ----------------------------------- | ---------- | -------------------------------------------------------------------- |
| `CLAUDE.md.template`                | ✅ presente | 285 linhas, 36 placeholders `{{tenant.X}}`                           |
| `agents-config.default.json`        | ✅ presente | JSON válido (`jq .` OK)                                              |
| `agents-config.schema.json`         | ✅ presente |                                                                       |
| `agents-template/` (8 SOULs + heads) | ⚠️ DIVERGE  | Tem 8 arquivos: pulseh, donna, alfredo, flavia, falconi, simon, dalio + **caio**. **NÃO tem subpasta `heads/` com 22 heads.** STRUCTURE.md descrevia 22 heads — não foram empacotados. |
| `skills-template/` (23 skills)      | ⚠️ DIVERGE  | 24 arquivos (.md), não 23. Inclui caio-closer, caio-hunter, branding-pulsar-geral, cliente-onboarding-template, etc. Contagem ligeiramente diferente — não-bloqueante. |
| `onboarding/` (6 specs)             | ✅ presente | 6 arquivos (welcome-script, interview-tree, team-presentation, render-pipeline, first-mission-router, exemplo-padaria-conversation) |
| `bootstrap/` (PROMPT, retomada, intro, dry-run, recovery) | ✅ presente | 5 arquivos                                                           |
| `brand/` (Half-Light)               | ✅ presente | guide + tokens + instructions + 10 assets + README                   |

### tenant/

| Item       | Status     |
| ---------- | ---------- |
| `.gitkeep` | ✅ presente |
| `README.md` | ✅ presente |

### installer/

| Item                     | Status     |
| ------------------------ | ---------- |
| `install.sh`             | ✅ presente, 114 linhas |
| `lib/` (10 libs)         | ✅ 10 .sh: log, prompt, state, preflight, deps, repo, postgres, vercel, mcp, tenant |
| `docker-compose.yml`     | ✅ presente, `docker compose config -q` OK |
| `postgres/` (schema+seed) | ✅ presente |
| `vercel/setup.sh`        | ✅ presente |
| `mcp/configure.sh`       | ✅ presente |
| `bots/wizard.sh`         | ✅ presente, 213 linhas |
| `smoke/` (first + validate) | ✅ presente |
| `README.md`              | ✅ presente |
| `AUDIT-existing-script.md` | ✅ EXCLUÍDO conforme STRUCTURE |
| `VALIDATION.md`          | ✅ EXCLUÍDO conforme STRUCTURE |

## Validações específicas

- **JSON válido:** `jq . core/agents-config.default.json > /dev/null` → OK
- **Placeholders no template:** `grep -c "{{tenant\." core/CLAUDE.md.template` → 36 ocorrências
- **bash -n em todos scripts (16 arquivos):** todos OK (vide preflight-results.md)
- **docker compose config:** OK (sem warnings)

## Contaminação PulsarH (refs vazadas)

Esperado: zero ou só showcases declarados. Real: **9 ocorrências em produção**, várias bloqueantes:

| Arquivo                                       | Linha | Conteúdo                                                                                     | Severidade |
| --------------------------------------------- | ----- | -------------------------------------------------------------------------------------------- | ---------- |
| `installer/smoke/validate.sh`                 | 87    | `DB_URL="${DATABASE_URL:-postgresql://pulsarh:pulsarh_secure_pass_2026@172.19.0.2:5432/pulsarh_war_room}"` | 🔴 BLOQUEANTE — credencial hardcoded da VPS Rodrigo |
| `installer/postgres/schema.sql`               | 3-4   | refs a `/root/pulsarh-war-room/prisma/schema.prisma`                                         | ℹ️ comentário, ok |
| `installer/postgres/seed.sql`                 | 6     | comentário "Sem nenhuma referencia a PulsarH"                                                | ℹ️ irônico mas ok |
| `installer/lib/repo.sh`                       | 4     | `PULSAR_OS_REPO="https://github.com/pulsarh/pulsar-os.git"`                                  | ⚠️ org `pulsarh` no GitHub (não criada ainda) |
| `installer/lib/tenant.sh`                     | 34    | comentário "Substitui slug PulsarH"                                                          | ℹ️ ok |
| `installer/bots/handoff-to-3.md`              | 26    | refs `/root/pulsarh-workspace/pulsar-os/onboarding/`                                         | ⚠️ doc interna que vazou (deveria ser excluída) |
| `installer/README.md`                         | 24    | `git clone https://github.com/pulsarh/pulsar-os.git ~/pulsar-os`                             | ⚠️ org pública não existente |
| `LICENSE.md`                                  | 3,51  | `Instituto PulsarH.AI`, `comercial@pulsarh.ai`                                               | ✅ esperado (licenciador) |
| `core/skills-template/branding-pulsar-geral.md` | 12-14 | refs a "showcases/branding-pulsarh-showcase.md"                                              | ⚠️ pasta `showcases/` não existe no zip |
| `core/skills-template/falconi-metodologia.md` | 6,15  | "default PulsarH PULSAR+H"                                                                   | ✅ aceitável (default explícito) |
| `core/skills-template/simon-cs.md`            | 6     | `identity_default: "Clarissa (CS PulsarH)"`                                                  | ⚠️ deveria ser genérico ou marcar como default |
| `core/agents-config.default.json`             | 148   | `"inspiration_name": "Rodrigo Braga (skill metodo)"`                                         | ⚠️ default — aceitável se o template explica |
| `tenant/README.md`                            | 21    | `pg_dump -U pulsarh pulsarh_war_room > tenant/backup-db-...`                                 | 🔴 instrução errada — usuário copia e roda, falha |

## Conclusão

**Build funciona, estrutura 90% match.** Bandeiras vermelhas:
1. `smoke/validate.sh` com credencial VPS PulsarH como fallback (segurança + funcional).
2. `tenant/README.md` com comando `pg_dump` apontando pra DB PulsarH.
3. `agents-template/heads/` ausente (22 heads não empacotados).

Bandeiras amarelas:
- showcases declarados no skills/branding mas pasta `showcases/` não foi adicionada ao zip.
- org GitHub `pulsarh/pulsar-os` referenciada mas não criada.
- handoff-to-3.md (doc interna) vazou em `installer/bots/`.
