# Pulsar OS v1.0 — Inventário Core vs Tenant (v1)

**Iniciativa 1 do projeto Pulsar OS v1.0 — Repo Vendável**
Owner: Falconi (VP Ops)
Data: 04/05/2026
Deadline iniciativa: 12/05/2026
Status: 4/4 tasks concluídas

---

## Convenção

- **core** — código, dados, brand ou lógica que pertence ao Pulsar OS (atualiza via `git pull`, é igual em todo cliente).
- **tenant** — específico do Instituto PulsarH.AI ou de qualquer empresa cliente (vive na pasta `/tenant`, sobrevive a updates do core).
- **híbrido** — código core que hoje carrega referência dura PulsarH (precisa generalização: extrair literais pra `tenant.config.json`, deixar lógica em core).

Drive Rodrigo (04/05/26 22h BRT): "sem fila de dev pro meu lado". Tudo abaixo é decisão técnica documental do Falconi — Pulse aprova/cobra próximo passo (corte/generalização).

---

## 1a — Inventário de arquivos (war-room): core vs tenant

Auditados 168 arquivos em `src/`, `prisma/`, `cerebro/`, `infra/`, raiz. 5 áreas-chave encontradas com refs duras (filtro `pulsarh|gestaopulsarh|pulsar-h.vercel|rodrigo braga|rbraga01|72.60.6.61|institutopulsarh`).

### Pastas de alto nível

| Caminho | Classificação | Justificativa | Ação |
|---|---|---|---|
| `prisma/schema.prisma` (1322 linhas, 53 models) | **core** | Schema é a coluna do produto (initiatives, projects, agents, pipeline_runs, contents, leads, prospects, automations…). Nada PulsarH-específico no DDL. | Manter em `/core/prisma/`. |
| `prisma/seed.ts` | **híbrido** | Cita "Mentor Licenciado PulsarH.ai" (linha 166), "Rodrigo Braga" (linha 220), URLs `pulsarh-landpages.vercel.app/m1.html` (linhas 197-198). | Mover seed PulsarH pra `/tenant/seed.ts`. Em `/core/prisma/seed.ts` deixar só estrutura mínima (1 user admin, 1 projeto exemplo, agentes vazios). |
| `src/app/api/` (38 subdirs) | **mix** | Ver detalhe abaixo. | Split por subpasta. |
| `src/app/(dashboard)/` (13 páginas) | **mix** | Ver detalhe abaixo. | Split por página. |
| `src/components/` | **majoritariamente core** | UI primitives, layout, projetos/, crm/, mentoria/. Sidebar logo é tenant. | Generalizar logo path; resto core. |
| `src/lib/` | **majoritariamente core** | architecture/, agents/registry, commands/, governance/, orchestration/, telemetry/. 2 hardcodes de chat_id Rodrigo. | Generalizar chat_id via env. |
| `src/lib/messaging/` | **híbrido** | `notifications.ts` exporta `notifyRodrigo()`, lê `RODRIGO_TELEGRAM_CHAT_ID`. `telegram.ts` cita bots @Pulseh_bot/@Donnah1_bot e chat_id 8734094117 em comentário. | Renomear `notifyRodrigo`→`notifyFounder`, env→`FOUNDER_TELEGRAM_CHAT_ID`. Comentários genéricos. |
| `cerebro/` (skills .md espelho, MAPA, USER, agents/) | **tenant** (todo) | Espelhos de skill_references DB + dados PulsarH (USER.md = bio Rodrigo, MAPA = stack PulsarH). Skill_references DB é a fonte da verdade core; os .md são histórico tenant. | Mover `cerebro/` inteiro pra `/tenant/cerebro/`. Em /core ficar só `cerebro/README.md` explicando o conceito. |
| `infra/` | **híbrido** | scripts/ tem `daily-report.sh` mencionando Rodrigo. Maioria genérico (docker-compose, traefik, certs). | Generalizar 1 script; resto core. |
| `setup-pulsar-os.sh` | **core** | Wizard de instalação já feito (em desenvolvimento). | Manter raiz, é o entrypoint do produto. |
| `public/assets/logo-pulsarh.png` | **tenant** | Logo PulsarH. | Mover pra `/tenant/public/assets/logo.png`. Sidebar lê path da config. |
| `public/brand-assets/`, `public/carrossel-output/` | **tenant** | Foto Rodrigo, output de carrossel PulsarH. | Mover pra `/tenant/public/`. |

### APIs (`src/app/api/`) — split

| Pasta | Classificação | Justificativa | Ação |
|---|---|---|---|
| `auth/`, `health/`, `config/`, `users/`, `team/`, `agents/`, `automations/`, `alerts/`, `projects/`, `initiatives/`, `inspiration/`, `playbooks/`, `kpi/`, `learning/`, `subscriptions/`, `workspace-config/`, `materials/` | **core** | Endpoints genéricos do War Room. Nada PulsarH-específico. | Em `/core/src/app/api/`. |
| `content/`, `crm/`, `prospects/`, `calendar/`, `meta/`, `bulk-campaigns/`, `cart-abandonments/`, `conversations/`, `webhooks/`, `dani/`, `cerebro/`, `radar/` | **híbrido** | Lógica é genérica mas alguns paths chamam `notifyRodrigo`, fazem fetch a domínios PulsarH ou citam personas. | Em `/core/`, generalizar literais. |
| `mentorias/` (incluindo `bootstrap`, `[id]`, `slug`) | **tenant** | Toda lógica de mentoria PulsarH (Clarissa pipeline, NAP-Tintas etc). Produto Mentor Licenciado é PulsarH-only. | Mover pra `/tenant/src/app/api/mentorias/`. |
| `m/[slug]/` | **tenant** | Páginas de mentorado, termos de aceite. | Mover pra `/tenant/`. |
| `flavio/`, `command/`, `resultados/`, `dani/sales/` | **tenant** | Endpoints muito acoplados a operação PulsarH (Flávio Head Hunter Instagram, Command portal, resultados `pulsar-h`). | Mover pra `/tenant/` ou eliminar do produto. |
| `performance/`, `sales-performance/`, `financeiro/` | **híbrido** | Lógica genérica de DRE/perfomance, mas atualmente lê dados PulsarH (Hotmart, Meta Ads). | Generalizar adapters. |

### Páginas dashboard (`src/app/(dashboard)/`) — split

| Página | Classificação | Ação |
|---|---|---|
| `projetos/` | **core** | Coração da execução. Mantém em /core. |
| `cerebro/`, `cerebro/saude/` | **core** (UI) com **tenant** (data) | UI fica em /core, dados (skills, agentes) tenant. |
| `crm/` (inbox, atendimento, pipeline, prospeccao) | **core** | Genérico. |
| `dashboard/` | **core** | KPI overview. |
| `financeiro/`, `financeiro/assinaturas/` | **core** | Genérico. |
| `performance/` | **core** | Genérico. |
| `conteudo/` (designer, gestor, calendario, curadoria, analytics) | **core** | Genérico — pipeline editorial. |
| `inteligencia/` | **híbrido** | Página tem refs PulsarH específicas (resgatar contexto). Lógica core, copy tenant. |
| `prospeccao/` | **core** | Genérico (Hermes pipeline). |
| `configuracoes/` | **core** | Settings gerais. |
| `tutorial/`, `tutorial/[screen]/` | **híbrido** | Tutorial usa exemplos PulsarH. Reescrever copy genérica. |
| `mentorados/`, `mentorados/[id]/` | **tenant** | Produto Mentor Licenciado. |

### Refs duras encontradas (resumo executivo)

- **40 arquivos** em `src/` mencionam `Rodrigo`/`PulsarH` direta ou indiretamente.
- **5 arquivos** em `src/lib/messaging/` ou similares têm chat_id `8734094117` ou env `RODRIGO_TELEGRAM_CHAT_ID` hardcoded.
- **1 arquivo** (`src/lib/architecture/layers.ts`) cita 6 personas (Pulseh, Donna, Alfredo, Simon, Falconi, Dalio) hardcoded em string — OK pra core (são as personas do produto), só renomear se for white-label (Pulse já decidiu: NÃO white-label).
- **1 IP hardcoded** (`72.60.6.61`) em `COORDINATION.md` (raiz) — irrelevante (doc).
- **`cerebro/empresa/USER.md`** tem bio Rodrigo + stack PulsarH — tenant puro, fora do core.

---

## 1b — Skills no DB com refs duras

Total: **56 skills** em `skill_references`. **46 (82%)** contêm pelo menos uma das strings: `PulsarH`, `Rodrigo`, `Instituto`, `pulsarh.ai`, `gestaopulsarh`. **10 estão limpas** (já generalizáveis).

### Skills "clean" (10) — entram core sem mexer

| Slug | Título | Notas |
|---|---|---|
| `alfredo-leo-dias-analise` | Léo Dias — Análise (Filtro+Vocabulário+Competitiva) | Framework editorial puro. |
| `caio-dani-prospec-ativa-ig` | Dani — Prospecção Ativa Cold IG | Playbook outbound. |
| `dalio-barsi` | Barsi — ROI por Campanha/Produto | Fórmula ROI genérica. |
| `dalio-beto` | Beto — KPIs & Dashboards | Catálogo KPI. |
| `dalio-flavio` | Flávio — Pricing & Ancoragem | Métodos de pricing. |
| `dalio-lemann` | Lemann — Projeções & Cenários | Modelagem cenários. |
| `dani-pipeline-acolhimento` | Dani — Pipeline+Acolhimento (3 Fases) | Tactical empathy. |
| `dani-spin-classification` | Dani — Semáforo+Tactical Empathy | Detecção de tom. |
| `donna-ritual-memoria` | Donna — Ritual Consulta+Registro | Ritual operacional. |
| `falconi-rebecca` | Rebecca — Guardiã da Memória | Auditoria semanal genérica. |

### Skills "híbridas" — generalizar (princípio + slot vazio)

Estratégia geral: **separar princípio (core) de exemplos PulsarH (tenant)**. Princípio entra `/core/skills/{slug}.md`. Exemplos viram `/tenant/skill-examples/{slug}.md` que o Pulse anexa em runtime via `{{tenant.skill_examples.SLUG}}`.

#### Top 20 skills críticas pra generalizar (priorizadas por impacto)

| Slug | Refs PulsarH duras | Sugestão de generalização |
|---|---|---|
| `alfredo-branding-pulsar-geral` | Manifesto inteiro PulsarH (36k chars), ICP "empresário brasileiro + próximo profissional", produtos Command/Imersão | **Gut e refazer.** Em /core: `alfredo-branding-template` v1 (estrutura: manifesto, ICPs, vozes, vocabulário) com slots `{{tenant.brand.manifesto}}`, `{{tenant.icp.primary}}`, `{{tenant.icp.secondary}}`. PulsarH vira tenant fixture. |
| `pulseh-branding-pulsar-geral` | Idem 36k chars | Mesmo tratamento. Slot único compartilhado com Alfredo. |
| `donna-branding-pulsar-geral` | Idem 36k chars | Mesmo tratamento. |
| `alfredo-betina-frameworks` | Cita "Jonathan/Avalan" (caso real PulsarH); 11k chars | Princípio AIDA/PAS/Bold Claim em core. Casos viram exemplos tenant. |
| `alfredo-leo-dias-radar` | Fontes específicas (Forbes BR, Exame, Valor, Brazil Journal, perfis IG concorrentes diretos PulsarH) | Princípio (radar diário, 3 fontes news/competitor/autoral, 5 blocos de entrega) em core. **Lista de fontes PulsarH** vira `/tenant/leo-radar-sources.json` que o cliente preenche no onboarding. |
| `alfredo-mauricio-design` | Refs Brand v1 Half-Light + foto Rodrigo CTA + assets `/brand-assets/` | Princípio direção de arte em core. **Brand kit** (cores, tipografia, foto founder) vira `/tenant/brand/`. Brand v1 Half-Light fica como **template base** em core (cliente pode trocar). |
| `alfredo-pedro` | Cita ad accounts PulsarH específicos, campanhas histórico | Princípio Meta Ads/CBO/aquisição em core. Ad accounts via env. Histórico tenant. |
| `alfredo-channel-*` (7 skills) | Citam vocabulário PulsarH, hashtags, tom de voz "instituto" | Princípio por canal (IG/LinkedIn/Reels/Email/Ads/Landing/Messages) em core. Vocabulário/hashtags em tenant. |
| `alfredo-visual-*` (5 skills) | Idem brand kit | Mesmo tratamento Mauricio-design. |
| `caio-clarissa` / `simon-clarissa` (idênticas, 26k chars) | Pipeline 10-etapas onboarding mentoria PulsarH; cita Mentor Licenciado, NAP-Tintas etc. | **Tenant puro**. Mentoria é produto PulsarH específico. Mover ambas pra `/tenant/skills/`. |
| `caio-dani-receptiva-ig`, `caio-dani-wa` | Citam produtos PulsarH (Imersão/Formação/Mentoria) e preços | Princípio (qualificação SPIN, fechamento) em core. Catálogo produtos tenant. |
| `caio-flavio` | Head Hunter Instagram com filtros ICP PulsarH (varejo) | Princípio outbound IG genérico em core. Filtros ICP em `tenant.config.json`. |
| `caio-objections`, `caio-spin` | Bibliotecas com objeções específicas PulsarH ("não sou empresário") | Framework SPIN/objeções em core. **Biblioteca específica** em tenant. |
| `dani-outbound-frases` | Frases proibidas/poderosas com vocabulário PulsarH | Princípio em core. Lista frases tenant. |
| `falconi-betinho`, `falconi-betinho-higiene` | Refs ao DB PulsarH, Vercel team `pulsar-h`, scripts específicos | **Núcleo core** (são skills do War Room dev). Generalizar paths/teamId via env. |
| `falconi-metodologia-pulsar-h` | **Já tem `{{founder_first_name}}`** (parcialmente generalizada) | Continuar trabalho. Substituir resto: `{{founder_method_name}}` (PULSAR+H), `{{tenant.method.steps}}`. |
| `falconi-neto`, `falconi-neto-release` | Setup Dani Cloud API + release Pulsar OS | **Núcleo core do produto** (instalador). Manter, generalizar tokens via env. |
| `falconi-pacheco` | Pipeline conversacional WhatsApp | Princípio core. Triggers tenant. |
| `pulseh-orquestracao` | 4 passos drive→eco→delega→cobra; tabela executores PulsarH | Princípio em core. **Tabela executores** (alfredo→betina, simon→clarissa…) vira `/tenant/agents.json`. |
| `pulseh-projetos` | Governança via /projetos do War Room | Princípio em core (essência do produto). |
| `flavia-clovis`, `flavia-ladeira`, `flavia-talles` | Naming PulsarH, esteira produtos PulsarH (Imersão/Command/Formação) | Princípio em core. Catálogo produtos tenant. |
| `simon-geraldo`, `simon-jade`, `simon-make` | Citam IA.gentes PulsarH específicos, Método dos Andares | Princípio em core. Lista agentes tenant. |
| `brand-v1-half-light` (5 cópias por agent) | Sistema visual fixo do produto | **Mantém core duro** (Pulse decidiu: brand fixa, sem white-label). Sai como assinatura Pulsar OS. |

### Resumo da migração de skills

- **10 skills** já clean → core direto.
- **30 skills** generalizar (princípio→core, exemplos→tenant) com slots `{{tenant.*}}`.
- **6 skills** tenant-puro (mentoria, branding-pulsar-geral 3×, dois channel/visual com vocab PulsarH duro) → mover inteiro pra `/tenant/skills/`.
- **5 skills** brand-v1-half-light → core duro (assinatura do produto).
- **5 skills** tutorial PulsarH específicas (cerebro/empresa, USER) → /tenant.

---

## 1c — Estrutura de pastas `/core` e `/tenant` proposta

```
pulsar-os/                          # repo Github vendido (zipado)
│
├── README.md                        # quickstart cliente
├── INSTALL.md                       # guia setup-pulsar-os.sh + Claude Code 1-prompt
├── LICENSE                          # licença Pulsar OS (commercial)
├── setup-pulsar-os.sh               # wizard instalação VPS (já existe — generalizar)
├── tenant.config.example.json       # template do config (cliente copia → tenant.config.json)
├── package.json                     # deps Next.js, Prisma, Tailwind, MCP server
├── docker-compose.yml               # Postgres + Traefik + (opcional) Vercel CLI
│
├── core/                            # ATUALIZA via git pull — INTOCADO pelo cliente
│   ├── src/                         # War Room Next.js (frontend + API)
│   │   ├── app/                     # rotas core (projetos, dashboard, crm, conteudo, performance, financeiro, configuracoes, prospeccao, cerebro UI)
│   │   ├── components/              # UI primitivos + layouts + design-system
│   │   ├── lib/                     # architecture/, agents/registry, commands/, governance/, orchestration/, telemetry/, services/, messaging/ (genérico)
│   │   └── design-system/           # tokens, primitives Brand v1 Half-Light
│   ├── prisma/                      # schema (53 models) + migrations + seed mínimo
│   ├── mcp-server/                  # MCP War Room (mover de /root/mcp-warroom/)
│   ├── skills/                      # princípio das skills (core), templates com {{slots}}
│   │   ├── pulseh-orquestracao.md
│   │   ├── pulseh-projetos.md
│   │   ├── alfredo-betina-frameworks.md
│   │   ├── alfredo-mauricio-design.md
│   │   ├── alfredo-leo-radar.md
│   │   ├── falconi-metodologia.md
│   │   ├── falconi-betinho.md
│   │   ├── falconi-betinho-higiene.md
│   │   ├── caio-spin.md
│   │   ├── caio-objections.md
│   │   ├── dalio-*.md
│   │   ├── donna-ritual-memoria.md
│   │   └── brand-v1-half-light.md
│   ├── brand/                       # Brand v1 Half-Light fixo (assinatura Pulsar OS)
│   │   ├── tokens.json
│   │   ├── design-guide.md
│   │   ├── instructions.txt
│   │   └── assets/                  # vórtice 9 SVGs
│   ├── infra/                       # docker compose, traefik, certs, scripts genéricos
│   ├── scripts/                     # backup-db.sh, daily-report.sh (generalizado), health-check.sh
│   └── personas/                    # 6 souls Markdown (Pulseh, Donna, Alfredo, Simon, Falconi, Dalio) — assinatura do produto
│
└── tenant/                          # CUSTOM por cliente — Pulse popula no onboarding via Telegram
    ├── tenant.config.json           # config principal (ver 1d)
    ├── brand/                       # cores/logo/foto founder do cliente (sobrescreve core/brand se quiser, opcional)
    ├── public/                      # assets do cliente (logo, foto founder pra CTA, fonts custom)
    ├── skill-examples/              # exemplos específicos do cliente injetados em runtime
    │   ├── betina-cases.md          # casos reais (cliente preenche depois das primeiras campanhas)
    │   ├── leo-radar-sources.json   # fontes news/competitor do nicho do cliente
    │   ├── caio-objections.md       # objeções específicas do cliente
    │   └── product-catalog.md       # produtos/preços do cliente
    ├── agents.json                  # roster: VPs ativos + heads (cliente liga/desliga)
    ├── icp.json                     # 1-2 ICPs do cliente (preenchido na entrevista Pulse)
    ├── manifesto.md                 # manifesto do cliente (Pulse co-cria)
    ├── seed.ts                      # seed inicial (1 user founder, projetos exemplo do cliente)
    ├── data/                        # backups, exports históricos do cliente
    ├── claude.md                    # CLAUDE.md final, Pulse escreve depois da entrevista
    └── mentorados/                  # se cliente roda mentoria, dados aqui (opcional)
```

### 1 frase por pasta-chave

- `core/src/` — código Next.js do War Room que todo cliente recebe igual.
- `core/prisma/` — schema do DB (53 models) + migrations + seed mínimo (admin + projeto vazio).
- `core/mcp-server/` — servidor MCP que conecta Claude Code ao War Room DB.
- `core/skills/` — princípios reusáveis (frameworks de copy, SPIN, ritual memória, brand v1) — fonte da verdade na tabela `skill_references`, espelhada aqui em .md pra ler em git.
- `core/brand/` — Brand v1 Half-Light, assinatura visual do Pulsar OS (fonte, paleta, vórtice — INVIOLÁVEL).
- `core/personas/` — 6 souls (Pulseh, Donna, Alfredo, Simon, Falconi, Dalio) com identidade preservada (decisão Rodrigo: personas ficam).
- `core/infra/` — docker-compose, traefik, scripts de saúde — instalação automática.
- `tenant/tenant.config.json` — única fonte da verdade do cliente (ver 1d).
- `tenant/skill-examples/` — exemplos específicos do nicho/cliente injetados via `{{tenant.skill_examples.X}}` em runtime.
- `tenant/brand/` — overrides opcionais (logo, foto founder pra CTA, cores acessórias).
- `tenant/agents.json` — quais VPs e heads o cliente liga (pode desligar Dalio se não quer financeiro detalhado, etc).
- `tenant/icp.json` + `tenant/manifesto.md` — Pulse preenche entrevistando o cliente no Telegram após instalação.
- `tenant/claude.md` — instruções operacionais finais, geradas pelo Pulse depois da entrevista.

### Princípio de update

`git pull` em `/core/` nunca toca `/tenant/`. Updates do produto (bug fix, feature nova) chegam via `/core/`. Cliente roda `pnpm core:update` que faz pull + migrate + restart, sem perder customização.

---

## 1d — Schema `tenant.config.json` v1

```jsonc
{
  "$schema": "https://pulsar-os.com/schemas/tenant.config.v1.json",
  "version": "1.0",

  "tenant": {
    "id": "instituto-pulsarh",                     // slug, sem acento, sem espaço — cliente preenche (1×)
    "name": "Instituto PulsarH.AI",                // display name — cliente preenche
    "domain": "pulsarh.ai",                        // domínio principal — cliente preenche
    "warRoomUrl": "https://war-room.pulsarh.ai",   // URL onde War Room vai rodar — cliente preenche (Vercel ou self-host)
    "createdAt": "2026-05-04",                     // auto pelo setup
    "locale": "pt-BR",                             // padrão pt-BR; futuro en-US
    "timezone": "America/Sao_Paulo"                // cliente preenche
  },

  "founder": {
    "firstName": "Rodrigo",                        // cliente preenche (1×)
    "fullName": "Rodrigo Braga",                   // cliente preenche
    "email": "rbraga01.rb@gmail.com",              // cliente preenche
    "telegramChatId": "8734094117",                // PULSE DESCOBRE no onboarding (cliente fala com bot, Pulse captura)
    "bio": "[a entrevistar]",                      // PULSE PREENCHE entrevistando — slot vazio até lá
    "tone": "[a entrevistar]"                      // como o founder gosta de ser tratado (chefe? primeiro nome? formal?)
  },

  "telegram": {
    "ceoBot": {
      "username": "@Pulseclaude_bot",              // cliente cria via BotFather, cola token
      "token": "ENV:TELEGRAM_PULSEH_BOT_TOKEN"     // referência a env (não vai em git)
    },
    "secretaryBot": {
      "username": "@Donnah1_bot",
      "token": "ENV:TELEGRAM_DONNA_BOT_TOKEN"
    }
  },

  "infra": {
    "vps": {
      "ip": "ENV:VPS_IP",                          // cliente preenche no setup wizard
      "user": "root"
    },
    "claudeMax": {
      "subscription": "max",                       // confirmação que cliente tem assinatura Max
      "configPath": "/root/.claude"
    },
    "postgres": {
      "host": "172.19.0.2",                        // padrão docker-internal — auto setup
      "port": 5432,
      "user": "pulsarh",
      "password": "ENV:POSTGRES_PASSWORD",         // gerado no setup
      "database": "war_room"
    },
    "vercel": {
      "enabled": true,
      "teamId": "ENV:VERCEL_TEAM_ID",              // cliente cola no setup
      "projectId": "ENV:VERCEL_PROJECT_ID",
      "commitAuthorEmail": "rbraga01.rb@gmail.com" // pega do founder.email
    }
  },

  "icp": {
    "primary": {
      "name": "[a entrevistar]",                   // PULSE PREENCHE — ex: "Empresário Brasileiro"
      "ageRange": "[a entrevistar]",
      "revenueRange": "[a entrevistar]",
      "painPoints": [],
      "channels": []
    },
    "secondary": {
      "name": "[a entrevistar]",
      "ageRange": "[a entrevistar]",
      "painPoints": []
    }
  },

  "brand": {
    "useDefault": true,                            // true = Brand v1 Half-Light (assinatura Pulsar OS)
    "overrides": {                                  // só preenche se useDefault=false (futuro v2)
      "logo": "/tenant/public/logo.png",
      "founderPhoto": "/tenant/public/founder-cta.jpg",
      "primaryColor": null,
      "accentColor": null
    },
    "vocabulary": {                                // termos do cliente — PULSE PREENCHE entrevistando
      "method": "[a entrevistar]",                 // ex: "PULSAR+H"
      "audience": "[a entrevistar]",               // ex: "líderes híbridos"
      "company": "[a entrevistar]",                // ex: "Instituto"
      "forbiddenTerms": [],                         // termos que cliente proíbe (ex: "startup")
      "preferredTerms": []                          // termos que cliente exige (ex: "metodologia" não "framework")
    }
  },

  "agents": {
    "ceo": { "slug": "pulseh", "enabled": true },
    "secretary": { "slug": "donna", "enabled": true },
    "vps": [
      { "slug": "alfredo", "enabled": true, "heads": ["betina", "mauricio", "leo"] },
      { "slug": "simon", "enabled": false, "heads": [] },     // cliente liga depois
      { "slug": "falconi", "enabled": true, "heads": ["betinho", "neto", "rebecca"] },
      { "slug": "dalio", "enabled": false, "heads": [] },
      { "slug": "flavia", "enabled": false, "heads": [] },
      { "slug": "caio", "enabled": false, "heads": [] }
    ]
  },

  "products": {                                    // PULSE PREENCHE entrevistando (catálogo do cliente)
    "catalog": [],
    "priceRange": "[a entrevistar]",
    "deliveryFormat": "[a entrevistar]"
  },

  "integrations": {
    "metaAds": { "enabled": false, "accessToken": "ENV:META_ACCESS_TOKEN", "adAccountIds": [] },
    "hotmart": { "enabled": false, "webhookSecret": "ENV:HOTMART_WEBHOOK_SECRET" },
    "googleCalendar": { "enabled": false, "credentialsPath": "ENV:GOOGLE_CREDS" },
    "whatsappCloud": { "enabled": false, "phoneNumberId": "ENV:WA_PHONE_ID" },
    "imagen4": { "enabled": false, "apiKey": "ENV:GOOGLE_IMAGEN_KEY" }
  },

  "onboarding": {
    "stage": "pending_interview",                  // pending_interview → interviewing → ready
    "interviewedAt": null,                         // ISO timestamp quando Pulse termina entrevista
    "claudeMdGeneratedAt": null,                   // ISO timestamp quando Pulse escreve /tenant/claude.md
    "lockedFields": ["tenant.id", "founder.firstName"]  // campos que não podem mudar depois
  }
}
```

### O que o cliente preenche vs Pulse descobre

| Campo | Quem preenche | Quando |
|---|---|---|
| `tenant.id`, `tenant.name`, `tenant.domain` | Cliente | Setup wizard (primeira execução `setup-pulsar-os.sh`) |
| `founder.firstName`, `founder.fullName`, `founder.email` | Cliente | Setup wizard |
| `telegram.*.token` | Cliente | Setup wizard (cola tokens BotFather) |
| `infra.vps.ip`, `infra.vercel.teamId/projectId` | Cliente | Setup wizard |
| `infra.postgres.password` | Auto | Setup wizard gera senha aleatória |
| `tenant.timezone`, `tenant.locale` | Cliente | Setup wizard (padrão pt-BR/America/Sao_Paulo) |
| `founder.telegramChatId` | Pulse descobre | Primeiro `/start` do founder no bot Pulseh |
| `founder.bio`, `founder.tone` | Pulse descobre | Entrevista no Telegram (pergunta 1-3 do onboarding) |
| `icp.primary`, `icp.secondary` | Pulse descobre | Entrevista (perguntas 4-7) |
| `brand.vocabulary.*` | Pulse descobre | Entrevista (perguntas 8-10) |
| `products.catalog` | Pulse descobre | Entrevista (perguntas 11-13) |
| `agents.vps[].enabled` | Pulse descobre | Entrevista (pergunta 14: quais áreas o cliente quer suporte) |
| `integrations.*` | Cliente sob demanda | Quando ativa integração (paste de tokens) |
| `tenant/claude.md` | Pulse gera | Após `onboarding.stage = ready` |

### Fluxo de instalação (1 prompt no Claude Code)

1. Cliente compra Pulsar OS, recebe zip do Github.
2. Sobe na VPS, abre Claude Code, manda 1 prompt: "instala o Pulsar OS aqui usando este zip".
3. Claude Code roda `setup-pulsar-os.sh` (existe, vou auditar e ajustar em iniciativa futura).
4. Wizard pergunta os 9 campos client-fill, gera `tenant.config.json` mínimo, sobe Postgres+Vercel+MCP, faz migrate+seed.
5. Cliente cria 2 bots no BotFather, cola tokens, restart.
6. Cliente manda `/start` no @Pulseh_bot do bot dele → Pulse capta `chat_id`, salva `founder.telegramChatId`, muda `onboarding.stage` pra `interviewing`.
7. Pulse roda 14 perguntas em script (entrevista guiada). Cada resposta vira campo no `tenant.config.json`.
8. Pulse encerra entrevista, escreve `/tenant/claude.md` com base no que aprendeu, muda `stage` pra `ready`.
9. Pulsar OS está vivo na empresa do cliente.

---

## Fim do inventário v1

**Próximo passo (Pulse cobra):** abrir iniciativa 2 do projeto Pulsar OS — generalização das 30 skills híbridas (extração princípio→core, exemplos→tenant). Estimativa: ~5 dias de trabalho dedicado pra Falconi+Betinho.
