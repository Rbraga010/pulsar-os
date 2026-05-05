# Checklist GA — Pulsar OS v1.0 vendável

Status hoje (05/05/2026, fim Iniciativa 8). Sinaleiras: ✅ pronto · ⚠️ parcial · 🔴 bloqueante · ℹ️ não-bloqueante.

## Produto (zip)

| Item                                                            | Status | Notas                                                   |
| --------------------------------------------------------------- | ------ | ------------------------------------------------------- |
| `build.sh` produz zip funcional                                 | ✅     | 344K, sha256 gerado, idempotente                        |
| `bash -n` em todos scripts                                      | ✅     | 16/16 OK                                                |
| `docker compose config` válido                                  | ✅     | sem warnings                                            |
| `agents-config.default.json` JSON válido                        | ✅     | jq OK, 36 placeholders no template                      |
| Brand v1.0 Half-Light empacotado                                | ✅     | 10 assets + guide + tokens + instructions               |
| Sem credenciais hardcoded                                       | 🔴     | `smoke/validate.sh:87` aponta pra DB Rodrigo            |
| Sem refs `/root/pulsarh-workspace`                              | 🔴     | `installer/bots/handoff-to-3.md` vazou                  |
| `agents-template/heads/` com 22 heads OU STRUCTURE alinhado     | 🔴     | Heads ausentes; STRUCTURE fala em 22 heads              |
| Repo público GitHub `pulsarh-ai/pulsar-os-core` criado          | 🔴     | Org não existe, `repo.sh` aponta pra 404                |
| Showcases (branding-pulsarh-showcase.md) incluídos              | ⚠️    | Skill referencia, mas pasta `showcases/` não está no zip |
| Smoke real ponta-a-ponta em VPS limpa                           | 🔴     | NÃO feito (precisa 2 bots BotFather de teste + VPS)     |

## Comercial

| Item                                                         | Status | Notas                                                |
| ------------------------------------------------------------ | ------ | ---------------------------------------------------- |
| LP `pulsar-os.io` (ou domínio) no ar                         | 🔴     | Domínio não comprado                                 |
| Copy LP honesto sobre tempo de instalação                    | 🔴     | Atual "12-18 min" é 2-4× mais rápido que real        |
| Checkout Hotmart/Stripe configurado                          | 🔴     | Não montado                                          |
| Order bump R$1.297 (sessão 1h pós-compra) configurado        | 🔴     | Não montado                                          |
| Política de reembolso publicada                              | 🔴     | Não escrita                                          |
| LICENSE.md revisada por jurídico                             | ⚠️    | Texto draft existe, sem revisão jurídica formal      |
| Vídeo demo BotFather (5-7 min) gravado                       | 🔴     | Não gravado                                          |
| Vídeo unboxing (zip → primeira conversa) gravado             | 🔴     | Não gravado                                          |

## Suporte

| Item                                                  | Status | Notas                                              |
| ----------------------------------------------------- | ------ | -------------------------------------------------- |
| Canal suporte (Discord/grupo Telegram/email)          | 🔴     | Não criado                                         |
| Troubleshooting top 5 publicado em `smoke-e2e/`       | ✅     | Este zip                                           |
| FAQ pré-venda (3-5 perguntas mais comuns)             | 🔴     | Não escrito                                        |
| Política de SLA suporte (24h/48h/best-effort)         | 🔴     | Não definida                                       |

## Ops / infra

| Item                                                       | Status | Notas                                  |
| ---------------------------------------------------------- | ------ | -------------------------------------- |
| GitHub org `pulsarh-ai`                                    | 🔴     | Criar                                  |
| Repo `pulsar-os-core` público                              | 🔴     | Criar                                  |
| CDN/storage do zip (R2, S3, Vercel Blob)                   | 🔴     | Não configurado                        |
| Webhook pós-compra → e-mail link de download               | 🔴     | Não configurado                        |
| Monitoramento erros instalação (telemetria opt-in)         | ℹ️    | Nice-to-have, não-bloqueante           |
| DNS pulsar-os.io                                           | 🔴     | Domínio não comprado                   |

## Comunidade / marketing

| Item                                              | Status | Notas                          |
| ------------------------------------------------- | ------ | ------------------------------ |
| Discord servidor criado                           | 🔴     | Não criado                     |
| Docs públicos (docs.pulsar-os.io ou GitHub Pages) | 🔴     | Não publicado                  |
| Changelog v1.0.0 publicado                        | ⚠️    | VERSION existe, changelog não  |

---

## Score GA

- Produto: **6/11** ✅ (build OK, brand OK, schema OK) · **5/11** 🔴 bloqueantes corrigíveis em ~1h
- Comercial: **0/8** ✅ — **8/8** 🔴 — todo o aparato comercial precisa montagem
- Suporte: **1/4** ✅ — **3/4** 🔴
- Ops: **0/6** ✅ — **5/6** 🔴 + 1 ℹ️
- Comunidade: **0/3** ✅ — **2/3** 🔴 + 1 ⚠️

**Veredicto:** **NÃO GA-ready hoje.** Distância pra GA: ~5-7 dias úteis Founder + 1h fix técnico Falconi.

## Top 3 bloqueadores pra primeira venda

1. **Aparato comercial inexistente** (LP, checkout, domínio, vídeo demo). Sem isso, não há "venda" pra fazer.
2. **3 fixes técnicos rápidos no zip** (smoke validate, tenant readme pg_dump, exclude handoff doc). 15 min.
3. **Repo GitHub público** (org `pulsarh-ai` + `pulsar-os-core`) — sem isso install.sh quebra na clonagem do core.

## Caminho mínimo pra GA (proposta Falconi)

| Dia | O que                                                              | Quem      |
| --- | ------------------------------------------------------------------ | --------- |
| 1   | 3 fixes técnicos zip + criar org/repo GitHub + push core           | Falconi   |
| 2   | Domínio + LP simples no Vercel + checkout Stripe                   | Founder + Alfredo |
| 3   | Webhook pós-compra → email com link zip + LICENSE                  | Falconi   |
| 4   | Gravar 2 vídeos (BotFather + unboxing)                             | Founder + Mauricio |
| 5   | Política reembolso + FAQ + Discord                                 | Founder + Simon |
| 6   | Smoke real ponta-a-ponta em VPS limpa Hetzner (€4 descartável)     | Falconi   |
| 7   | Soft launch 5 leads warm. Coletar feedback. Ajustar.               | Founder   |

GA público realista: **D+8 ou D+10** com colchão.
