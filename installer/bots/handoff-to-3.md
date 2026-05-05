# Handoff 4b → 3 — smoke conecta no onboarding ritual

Documento de contrato entre a Iniciativa 4b (instalador bots) e a Iniciativa 3 (onboarding ritual). Falconi/Pacheco usam isso pra implementar a state machine que faz Pulse conduzir o Founder do `/start` ate a primeira missao operacional.

## Mapa do fluxo (ponta a ponta)

```
[4a install.sh] termina
   ↓
[4b wizard.sh] cria bots → valida tokens → escreve tenant/.env.local
   ↓
[4b first-message.sh] captura founder_chat_id → escreve agents-config.json
   ↓                       → renderiza welcome-script.md msg 1 → Telegram
   ↓
[3 onboarding ritual] Pulse continua via state machine pipeline_runs
   ↓
   ├── welcome-script.md msgs 2 + 3 (contrato + bracar)
   ├── interview-tree.md P1...P12 (+ ramo overrides identidade opcional)
   ├── render-pipeline.md (gera CLAUDE.md + agents-config.json final)
   ├── team-presentation.md (apresenta 8 SOULs + 19 heads)
   └── first-mission-router.md (roteia 1a missao baseada na dor declarada em P10/P11)
```

## Artefatos exatos referenciados (paths absolutos no repo)

Todos sob `/root/pulsarh-workspace/pulsar-os/onboarding/` (Iniciativa 3, ja entregue):

| Artefato | Funcao | Quando 4b chama |
|---|---|---|
| `welcome-script.md` | 3 msgs iniciais (boas-vindas, contrato, brace) | `first-message.sh` extrai e envia msg 1 |
| `interview-tree.md` | 12 perguntas + ramo opcional | Pulse usa apos resposta a msg 1 (P1: nome empresa) |
| `render-pipeline.md` | Especifica state machine de render pos-entrevista | Falconi implementa apos P12 |
| `team-presentation.md` | Apresenta time pos-render | Pulse executa apos render OK |
| `first-mission-router.md` | Roteia 1a missao operacional | Final do ritual |
| `exemplo-padaria-conversation.md` | Walkthrough referencia (Padaria do Ze) | QA / regression |

## Contrato de dados — `tenant/onboarding-answers.json`

A 4b cria o esqueleto. A Iniciativa 3 popula a cada resposta. Estrutura inicial que `first-message.sh` deixa:

```json
{
  "tenant_slug": "<derivado-de-P1>",
  "started_at": "<ISO8601 quando msg 1 foi enviada>",
  "founder_chat_id": "<capturado em smoke>",
  "answers": {},
  "current_step": "P1",
  "state": "awaiting_user"
}
```

Dot-notation por slot (vai sendo populada): `answers["tenant.empresa.nome"]`, `answers["tenant.icp.descricao_curta"]`, etc. Map completo dos 18 slots em `interview-tree.md`.

## Contrato de estado — `pipeline_runs`

A 4b NAO cria pipeline_runs ainda (smoke e fire-and-forget). A Iniciativa 3 cria:

```ts
warroom_pipeline_start({
  slug: 'onboarding-tenant-{tenant_slug}',
  name: 'Onboarding tenant {empresa.nome}',
  type: 'onboarding',
  agentSlug: 'pulseh',
  totalSteps: 12,
  payload: { founder_chat_id, started_at }
})
```

Cada resposta valida → `warroom_pipeline_advance({slug, currentStep: 'P{n+1}'})`.

Pausa pra aprovacao em P3 (override identidade) e P8 (skills personalizadas) — `state: 'awaiting_user'`, `awaitingMsg: '...'`.

## Contrato de retomada

Comando `pulsar-os onboarding-resume` (a implementar na Iniciativa 3):

```bash
1. warroom_pipeline_list({state: 'awaiting_user', agentSlug: 'pulseh'})
2. Se retornou pipeline matching tenant_slug atual: carrega current_step
3. Pulse manda "Voltei. Estavamos em {P_n}: {pergunta}"
4. Aguarda resposta → advance
```

## Slots ja preenchidos pela 4b (Founder NAO precisa responder na entrevista)

| Slot | Origem |
|---|---|
| `tenant.contacts.founder_chat_id` | smoke first-message.sh |
| `tenant.bots.pulseh.token` | wizard.sh (em .env.local) |
| `tenant.bots.pulseh.username` | wizard.sh (validate_token) |
| `tenant.bots.donna.token` | wizard.sh |
| `tenant.bots.donna.username` | wizard.sh |

Os 7 slots cobertos pelo installer (incluindo os 5 acima + `vps_ip`, `db_host`, `db_url`, `repo_path`, `vercel_team` da 4a) batem com `interview-tree.md` declara como "preenchidos pelo installer".

## Sinais de vida (telemetria)

A Iniciativa 3 deve emitir `warroom_log_agent_memory(slug='pulseh', type='milestone')` em:
- `onboarding-started` (apos msg 1)
- `interview-completed` (apos P12)
- `render-completed` (apos CLAUDE.md gerado)
- `first-mission-routed` (final do ritual)

A 4b ja emite `tenant-bots-active` quando wizard fecha. Falconi/Pacheco encadeiam.

## O que NAO esta resolvido aqui (backlog)

- Reentrada se Founder trocar de bot (revogou tokens, criou novos): exige re-rodar `wizard.sh` E reset de `pipeline_runs` do tenant.
- Multi-tenant na mesma VPS: hoje `tenant/` e singular. Multi-tenant exige namespacing (`tenants/{slug}/`).
- Erro Pulse mid-entrevista: state machine deve registrar erro em `pipeline_runs.payload.errors[]` e expor em validate.sh.

Esses tres ficam pra v1.1.
