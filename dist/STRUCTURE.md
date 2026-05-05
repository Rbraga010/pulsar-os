# Pulsar OS v1.0 — Estrutura do zip único (DIY R$297)

Modelo: **um zip, sem variantes**. Order bump R$1.297 é checkout-side (sessão 1h pós-compra),
não muda o conteúdo do zip. Fonte da verdade pro `build.sh`.

---

## Árvore canônica

```
pulsar-os-v1.0.0/
├── README.md                          # passo a passo Founder (1 página)
├── BOOTSTRAP-PROMPT.md                # cópia exata de core/bootstrap/PROMPT.md
├── VERSION                            # "v1.0.0\n"
├── LICENSE.md                         # licença comercial 1 empresa por compra
│
├── core/                              # NÃO MEXER — atualiza via `git pull`
│   ├── CLAUDE.md.template             # template com {{tenant.X}} (8 slots)
│   ├── agents-config.default.json     # 8 SOULs oficiais; heads referenciados via skills_extra
│   ├── agents-config.schema.json      # JSON Schema validador
│   │
│   ├── agents-template/               # 8 SOULs oficiais (heads NÃO são SOULs separados)
│   │   ├── pulseh.md
│   │   ├── donna.md
│   │   ├── alfredo.md
│   │   ├── flavia.md
│   │   ├── falconi.md
│   │   ├── simon.md
│   │   ├── dalio.md
│   │   └── caio.md                    # comercial/CRM (subset Alfredo)
│   │
│   ├── skills-template/               # ARQUITETURA: heads vivem aqui como skills do VP
│   │                                  # (Betina/Mauricio/Leo Dias = skills de Alfredo;
│   │                                  # Hunter/Closer = caio-*; Falconi heads = falconi-*; etc).
│   │                                  # Acionados via warroom_get_agent(VP).skills_extra (ver agents-config).
│   ├── onboarding/                    # 6 specs do ritual primeiro contato
│   ├── bootstrap/                     # PROMPT, retomada, intro, dry-run, recovery
│   └── brand/                         # Brand v1.0 Half-Light (inviolável)
│       ├── pulsar-design-guide.md
│       ├── pulsar-tokens.json
│       ├── pulsar-instructions.txt
│       └── assets/                    # 9 SVGs vórtice
│
├── tenant/                            # SEU TERRITÓRIO — git pull não toca
│   ├── .gitkeep
│   └── README.md                      # explica o que Pulse escreve aqui
│
└── installer/                         # one-shot infra
    ├── install.sh                     # entry-point 12-15min
    ├── lib/                           # 10 libs (preflight, docker, postgres, ...)
    ├── docker-compose.yml             # stack postgres + redis + mcp + n8n
    ├── postgres/                      # schema.sql + seed.sql idempotente
    ├── vercel/                        # setup.sh
    ├── mcp/                           # configure.sh
    ├── bots/                          # wizard Telegram (4b)
    ├── smoke/                         # first-message + validate
    └── README.md
```

---

## Mapeamento origem → destino (referência do build.sh)

| Origem                                                            | Destino no zip                              |
| ----------------------------------------------------------------- | ------------------------------------------- |
| `/root/pulsarh-workspace/pulsar-os/CLAUDE.md.template`            | `core/CLAUDE.md.template`                   |
| `/root/pulsarh-workspace/pulsar-os/agents-config.default.json`    | `core/agents-config.default.json`           |
| `/root/pulsarh-workspace/pulsar-os/agents-config.schema.json`     | `core/agents-config.schema.json`            |
| `/root/pulsarh-workspace/pulsar-os/agents-template/`              | `core/agents-template/`                     |
| `/root/pulsarh-workspace/pulsar-os/skills-template/`              | `core/skills-template/`                     |
| `/root/pulsarh-workspace/pulsar-os/onboarding/`                   | `core/onboarding/`                          |
| `/root/pulsarh-workspace/pulsar-os/bootstrap/`                    | `core/bootstrap/`                           |
| `/root/pulsarh-workspace/brand/v1.0-half-light/`                  | `core/brand/`                               |
| `/root/pulsarh-workspace/pulsar-os/installer/`                    | `installer/` (excluindo AUDIT/VALIDATION)   |
| `dist/templates/README.md`                                        | `README.md`                                 |
| `dist/templates/LICENSE.md`                                       | `LICENSE.md`                                |
| `dist/templates/BOOTSTRAP-PROMPT.md`                              | `BOOTSTRAP-PROMPT.md`                       |
| `dist/templates/VERSION`                                          | `VERSION`                                   |
| `dist/templates/tenant-readme.md`                                 | `tenant/README.md`                          |

---

## Exclusões obrigatórias (NÃO entram no zip)

- `installer/AUDIT-existing-script.md` — doc interna
- `installer/VALIDATION.md` — doc interna
- Qualquer `.env` real (só `.env.example` com placeholders)
- `pulsar-os/landing/` (fora de escopo do zip)
- `pulsar-os/CLAUDE.md.exemplo-padaria.md` — artefato de teste
- `pulsar-os/agents-config.padaria.json` — artefato de teste
- `pulsar-os/inventario-core-vs-tenant-v1.md` — doc interna
- `pulsar-os/dist/` (auto-exclusão)
- Qualquer menção a Command, Clarissa-as-product, Imersão H.AI, repos PulsarH-específicos
- Tokens, chaves, credenciais reais

---

## Tamanho-alvo (estimativa pré-build)

- ~5-15 MB zipado (~20-40 MB descompactado, dominado por brand/assets/ SVGs)
- Bate confortavelmente em download link Stripe / e-mail
