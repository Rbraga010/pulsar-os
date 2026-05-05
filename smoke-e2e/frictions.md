# Fricções top 5 — encontradas no smoke seco

Apenas fricções reais observadas no build/extract/preflight. Sem invenção.

---

## 🔴 #1 — `smoke/validate.sh` aponta pra DB de produção PulsarH (BLOQUEANTE)

**Sintoma:** linha 87 de `installer/smoke/validate.sh`:
```bash
DB_URL="${DATABASE_URL:-postgresql://pulsarh:pulsarh_secure_pass_2026@172.19.0.2:5432/pulsarh_war_room}"
```
Tenant que rode validate.sh **sem** `DATABASE_URL` setada vai tentar conectar **na VPS Rodrigo (172.19.0.2)** com a senha real do War Room. No melhor cenário falha (firewall). No pior, vaza credencial em log/troubleshooting.

**Causa raiz:** copy-paste do War Room sem sanitização final. Esquecimento na hora de gerar o template.

**Fix sugerido:**
```bash
DB_URL="${DATABASE_URL:-postgresql://pulsar:pulsar@localhost:5432/pulsar_os}"
```
Default localhost + senha placeholder. **5 min de fix, 1 commit.**

**Impacto Founder:** alto — credencial PulsarH no zip público é vazamento de segurança. NUNCA pode ir GA assim.

---

## 🔴 #2 — `tenant/README.md` instrui `pg_dump -U pulsarh pulsarh_war_room` (BLOQUEANTE)

**Sintoma:** o tenant README sugere comando `pg_dump -U pulsarh pulsarh_war_room`. Founder tenta rodar, falha (DB não existe), abre ticket suporte ou desiste.

**Causa raiz:** template tenant-readme.md em `dist/templates/` ainda traz nomes hardcoded.

**Fix sugerido:** trocar por `${TENANT_DB_NAME}` ou exemplo genérico (`pg_dump -U <SEU_USER> <SEU_DB>`). **5 min, 1 commit.**

**Impacto Founder:** suporte 1× por venda. NPS -10.

---

## 🔴 #3 — `agents-template/heads/` ausente do zip

**Sintoma:** STRUCTURE.md descreve `agents-template/heads/` com 22 heads. Real: pasta não existe, 8 arquivos no agents-template/ (7 VPs + caio).

**Causa raiz:** ou o build.sh não copia uma pasta que não existe na origem (`/root/pulsarh-workspace/pulsar-os/agents-template/heads/` está vazio/inexistente), ou STRUCTURE.md está desatualizado.

```bash
ls /root/pulsarh-workspace/pulsar-os/agents-template/
# alfredo.md  caio.md  dalio.md  donna.md  falconi.md  flavia.md  pulseh.md  simon.md
```
Confirmado: heads/ **não existe** na origem. Não é bug do build, é entrega faltando.

**Fix sugerido:** dois caminhos.
- (a) Criar `agents-template/heads/` com os 22 heads (Betina, Mauricio, Leo Dias, Talles, Clovis, Ladeira, Rodrigo-skill, Betinho, Neto, Rebecca, Pacheco, Franceschi, Bernardinho, Cortella, Abilio, Clarissa, Beto, Lemann, Barsi, Flavio + 2 que sumiram). 4-6 horas de trabalho.
- (b) Atualizar STRUCTURE.md pra refletir que heads = skills (modelo "heads são skills dos VPs", consistente com CLAUDE.md atual). 30 min.

**Impacto Founder:** se vendemos "30 agents", entregamos 8. NPS -20 quando descobre. Recomendação: rota (b) — alinhar STRUCTURE com modelo real (skills-as-heads).

---

## ⚠️ #4 — Org GitHub `pulsarh/pulsar-os` referenciada mas não existe

**Sintoma:** `installer/lib/repo.sh` e `installer/README.md` apontam pra `https://github.com/pulsarh/pulsar-os.git`. Org pública `pulsarh` no GitHub não foi criada. `git clone` vai falhar com 404.

**Causa raiz:** TODO de Ops (criar org pulsarh, criar repo público, push do core).

**Fix sugerido:**
1. Criar org GitHub `pulsarh-ai` (pulsarh já existe e não é nossa).
2. Repo público `pulsarh-ai/pulsar-os-core` com só os arquivos do `core/`.
3. Atualizar URL em `repo.sh` e `README.md`.

**Tempo:** 30 min Founder + 10 min ajuste código.

**Impacto Founder:** install.sh falha em passo crítico (clone do core). 100% bloqueante pra GA.

---

## ⚠️ #5 — `installer/bots/handoff-to-3.md` (doc interna) vazou no zip

**Sintoma:** Founder ao explorar o zip vê doc com path `/root/pulsarh-workspace/pulsar-os/onboarding/` — exposição de filesystem do dev.

**Causa raiz:** build.sh exclui só `AUDIT-existing-script.md` e `VALIDATION.md`. `handoff-to-3.md` passou.

**Fix sugerido:** adicionar `--exclude='handoff-to-*.md'` ou regex `--exclude='*handoff*'` no rsync de `dist/build.sh` (linha 95-99).

**Tempo:** 2 min.

**Impacto Founder:** baixo (cosmético) mas reduz percepção de profissionalismo.

---

## Resumo de bandeiras

| #  | Severidade | Bloqueante GA? | Fix em                |
| -- | ---------- | -------------- | --------------------- |
| 1  | 🔴 alta    | SIM            | 5 min                 |
| 2  | 🔴 alta    | SIM            | 5 min                 |
| 3  | 🔴 alta    | SIM (NPS)      | 30min (rota b) ou 4-6h (rota a) |
| 4  | ⚠️ média  | SIM (funcional) | 40 min                |
| 5  | ℹ️ baixa  | não            | 2 min                 |

**Total fix bloqueante GA:** ~1h se for pelo caminho mais rápido (rota b da #3). Realista, factível.
