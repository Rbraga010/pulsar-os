# Troubleshooting top 5 — Pulsar OS v1.0 DIY

Fluxo Founder do zip à primeira interação. Top 5 problemas mais prováveis, com diagnóstico e fix.

---

## 1. Vercel CLI auth com email errado → deploy ERROR

**Sintoma:** `install.sh` termina mas War Room do tenant aparece "deploy error" no painel Vercel.

**Diagnóstico:**
```bash
vercel whoami
# se retornar email diferente do cadastrado na compra → causa
git -C ~/pulsar-os/tenant/war-room log -1 --pretty='%ae'
# se != email do Vercel → deploy falha
```

**Fix:**
```bash
git -C ~/pulsar-os/tenant/war-room config user.email "<email-vercel-correto>"
git -C ~/pulsar-os/tenant/war-room commit --allow-empty -m "trigger redeploy" && git push
```

---

## 2. BotFather não responde / token inválido

**Sintoma:** `wizard.sh` pede token, Founder cola, valida e diz "token inválido".

**Diagnóstico:**
```bash
TOKEN=<seu-token>
curl -s "https://api.telegram.org/bot${TOKEN}/getMe"
# se retorna {"ok":false,...} → token errado/revogado
# se "ok":true → wizard.sh com bug
```

**Fix:**
- Refazer no @BotFather: `/mybots` → seu bot → `API Token` → `Revoke current token` → copiar novo.
- Confirmar que copiou inteiro (formato `123456789:ABCDEF...` 46 caracteres).

---

## 3. Postgres porta 5432 ocupada

**Sintoma:** `docker compose up` falha com "bind: address already in use".

**Diagnóstico:**
```bash
ss -tlnp | grep :5432
# ou
lsof -iTCP:5432 -sTCP:LISTEN
```

**Fix:** parar postgres host (`systemctl stop postgresql`) ou alterar `docker-compose.yml`:
```yaml
postgres:
  ports:
    - "5433:5432"
```
Atualizar `DATABASE_URL` no `.env` pra `localhost:5433`.

---

## 4. Claude Code não vê o MCP War Room

**Sintoma:** `claude code` abre, mas comandos `mcp__warroom__*` não disponíveis.

**Diagnóstico:**
```bash
cat ~/.claude/config.json | jq '.mcpServers.warroom'
# se null → mcp/configure.sh não rodou
# se objeto presente → restart Claude Code:
pkill -f "claude" && claude code
```

**Fix:** rodar `bash installer/mcp/configure.sh` manualmente. Reiniciar Claude Code.

---

## 5. Onboarding interrompeu, Pulse não retoma

**Sintoma:** Founder fechou laptop no meio das 12 perguntas. Volta, abre Claude Code, Pulse recomeça do zero.

**Diagnóstico:**
```bash
ls ~/pulsar-os/tenant/.onboarding-state
cat ~/pulsar-os/tenant/.onboarding-state | jq .
# se arquivo existe → Pulse não está lendo. Bug.
# se não existe → onboarding nunca persistiu (bug no welcome-script.md)
```

**Fix:**
- Colar `core/bootstrap/PROMPT-modo-retomada.md` no Claude Code em vez do PROMPT.md inicial.
- Se mesmo assim falhar, reset: `rm tenant/.onboarding-state && rm tenant/CLAUDE.md` e recomeça (perde progresso, ~10 min).

**Recomendação Falconi pra suporte:** gravar 1 vídeo de 90s "perdi progresso, e agora?" e linkar no README.md. Reduz ticket comum.
