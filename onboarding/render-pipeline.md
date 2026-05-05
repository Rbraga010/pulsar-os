# Pulsar OS — Onboarding: Render Pipeline (especificacao)

Especificacao tecnica do que acontece quando o Pulse termina a entrevista. Falconi implementa como state machine na Iniciativa 4 (instalador one-shot). Aqui e contrato — nao codigo rodando.

---

## 1. Coleta progressiva

A cada resposta do Founder no Telegram:

```
tenant/onboarding-answers.json
```

Estrutura:

```jsonc
{
  "tenant_slug": "padaria-do-ze",            // derivado de P1
  "started_at": "2026-05-05T10:12:00-03:00",
  "answers": {
    "empresa.nome": "Padaria do Ze",
    "empresa.dominio": "padariadoze.com.br",
    "empresa.tagline": "O pao de queijo que abraca",
    "founder.nome": "Jose Silva",
    "founder.bio": "[a entrevistar]",
    "equipe.headcount_humano": 4,
    "icp.primary": "Familias do bairro 30-60 anos, raio 2km",
    "icp.secondary": "Empresas vizinhas pedindo cafe da manha corporativo",
    "produtos.principal": "Pao de queijo artesanal mineiro",
    "produtos.lista": "Pao de queijo, paes artesanais, bolos caseiros, cafe especial, kit corporativo",
    "brand.voz": "caloroso, mineiro, familiar",
    "foco_intel": "padarias artesanais, marketing de bairro, tendencias de consumo de pao mineiro",
    "dor_atual": "vendo-pouco-ig-morto"      // chave do first-mission-router
  },
  "agents_overrides": [
    { "slug": "pulseh", "inspiration_name": "Steve Jobs", "inspiration_bio_short": "..." }
  ],
  "skipped_slots": ["founder.bio"],
  "review_needed": []
}
```

Pulse persiste a cada resposta — se Founder cair offline, retoma do mesmo ponto via `pipeline_runs` (state machine ja existente).

---

## 2. Trigger do render

Render dispara quando:
- Ultima pergunta da arvore respondida (P13 com "default" OU ultimo P13b)
- OU Founder digita `/skip-all` em qualquer ponto
- OU 12 perguntas obrigatorias (P1-P12) preenchidas e P13 respondida

NAO dispara se:
- P1, P4, P9 ou P12 forem `[a entrevistar]` (slots criticos sem default seguro)
- Nesses casos: Pulse re-pergunta a critica e segura render.

---

## 3. Acoes em sequencia (atomicas)

### 3.1 Render CLAUDE.md

```
input:  pulsar-os/CLAUDE.md.template
        tenant/onboarding-answers.json
        tenant/agents-config.json (resultado do passo 3.2)
output: tenant/CLAUDE.md
```

Regras:
- Substituicao literal `{{tenant.X}}` -> answers.X.
- Slots em `skipped_slots` -> string `[a entrevistar]`.
- Slots derivados (urls, bots, git_email, infra) -> placeholder `[install-step]` se ainda nao instalado.
- Blocos FIXOS (Brand v1.0, hierarquia, deploy, git anti-destrutivo, PULSAR+H glossary) NAO sao tocados.
- Header HTML comment do template e preservado (auditoria).

### 3.2 Render agents-config.json

```
input:  pulsar-os/agents-config.default.json
        tenant/onboarding-answers.json (campo agents_overrides)
output: tenant/agents-config.json
```

Algoritmo:
1. Carrega default canonico.
2. Para cada item em `agents_overrides`:
   - Localiza objeto com `slug` igual no array `agents`.
   - Substitui `identity.inspiration_name`, `identity.inspiration_bio_short` pelos valores fornecidos.
   - Preserva `slug`, `active`, `skills_extra`, demais campos.
3. Substitui top-level: `tenant_slug`, `tenant_name`, `founder_first_name`, `company_name` pelos valores do onboarding.
4. Valida o JSON resultante contra `agents-config.schema.json`. Se falhar, ABORTA render e escala pro Falconi.

### 3.3 Backlog interno de slots vazios

Pra cada slot em `skipped_slots`, cria entrada em `tenant/onboarding-followup.md`:

```
- [ ] {{tenant.founder.bio}} — Founder pulou em P5. Donna cobra em 24h.
- [ ] {{tenant.brand.vocabulario}} — derivado nao confirmado. Pulse propoe 5 termos no /cerebro.
```

---

## 4. Pos-render

### 4.1 Commit local (NAO push)

```bash
cd tenant/
git add CLAUDE.md agents-config.json onboarding-answers.json onboarding-followup.md
git commit -m "feat(tenant): onboarding inicial — {{tenant.empresa.nome}}"
```

Email do commit: usa `founder.git_email` derivado. Se ainda placeholder, usa `founder@{tenant_slug}.local` temporario.

NAO faz push. Push so na primeira deploy (Iniciativa 4 — instalador conecta GitHub).

### 4.2 Memoria milestone

```
warroom_log_agent_memory({
  agentSlug: "pulseh",
  type: "milestone",
  title: "Onboarding tenant {{tenant.empresa.nome}} concluido",
  content: "12 perguntas respondidas em XX min. Slots vazios: [...]. Overrides: [...]. Dor: {{dor_atual}}. 1a missao roteada pra: {{vp_alvo}}.",
  metadata: { "tenant_slug": "...", "skipped_count": 1, "overrides_count": 0 }
})
```

### 4.3 Validacao automatica do Pulse

Antes de apresentar pro Founder, Pulse roda checklist:

1. CLAUDE.md tem todos blocos FIXOS intactos? (grep por anchors: "Brand v1.0", "PULSAR+H", "PROTOCOLO DE DEPLOY", "Git — Anti-destrutivo")
2. Slots criticos preenchidos? (empresa.nome, founder.nome, produtos.principal, dor_atual)
3. agents-config.json valida no schema?
4. Numero de agents = 30 (8 oficiais + 22 heads)?
5. Tenant_slug bate em CLAUDE.md e agents-config.json?

Falha em qualquer item: ABORTA, escala pro Falconi via memoria type=lesson, avisa Founder "deu ruim no render, time tecnico ja foi acionado".

### 4.4 Apresentacao do time

Dispara `team-presentation.md` no Telegram.

### 4.5 Roteamento da 1a missao

Le `dor_atual`, busca em `first-mission-router.md`, dispara as 3 mensagens da rota correspondente.

---

## 5. Pos-onboarding (T+24h)

Donna roda audit:
- Le `tenant/onboarding-followup.md`.
- Pra cada item nao resolvido: cobra Founder no Telegram com mensagem curta.
- Se 7 dias sem resposta: arquiva como `[review-permanent-pending]`.

---

## 6. Falhas previstas e fallback

| Falha | Fallback |
|---|---|
| Founder some no meio | State machine retoma da P-X na proxima mensagem. Se passar 24h, Donna provoca. |
| Resposta invalida 3x | Aceita free-text com flag `[review-needed]`. Donna revisita. |
| Render schema fail | Aborta. Falconi escalado. Founder recebe "deu ruim, ja resolvendo". |
| Bio inventada acidentalmente | NAO POSSIVEL — slot vazio = `[a entrevistar]`. Hard-rule. |
| Override fora do enum | Schema rejeita. Pulse repergunta P13. |

---

## 7. Resumo do contrato

- Input: 12 respostas + ate 3 overrides
- Output: 4 arquivos em `tenant/` (CLAUDE.md, agents-config.json, onboarding-answers.json, onboarding-followup.md) + commit local + 1 memoria milestone
- Tempo alvo: render < 5s, total ritual 8-15 min
- Idempotencia: re-rodar onboarding sobrescreve answers.json mas preserva CLAUDE.md anterior em `tenant/CLAUDE.md.bak.{timestamp}`
