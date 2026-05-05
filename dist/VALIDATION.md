# Pulsar OS v1.0 — Validação seca (Iniciativa 6.1)

Modelo: zip único DIY R$297. Sem variantes Bump/White-glove (order bump é checkout-side).

---

## 1. Sintaxe

```
$ bash -n /root/pulsarh-workspace/pulsar-os/dist/build.sh
(sem erro)
$ echo $?
0
```

**OK.**

---

## 2. Preflight (origens existem)

| Origem | Status |
| ------ | :----: |
| `/root/pulsarh-workspace/pulsar-os/CLAUDE.md.template`         | OK |
| `/root/pulsarh-workspace/pulsar-os/agents-config.default.json` | OK |
| `/root/pulsarh-workspace/pulsar-os/agents-config.schema.json`  | OK |
| `/root/pulsarh-workspace/pulsar-os/agents-template/`           | OK (8 arquivos) |
| `/root/pulsarh-workspace/pulsar-os/skills-template/`           | OK (24 arquivos) |
| `/root/pulsarh-workspace/pulsar-os/onboarding/`                | OK (6 arquivos) |
| `/root/pulsarh-workspace/pulsar-os/bootstrap/`                 | OK (5 arquivos) |
| `/root/pulsarh-workspace/brand/v1.0-half-light/`               | OK (14 arquivos) |
| `/root/pulsarh-workspace/pulsar-os/installer/`                 | OK (24 arquivos sem internas) |
| `dist/templates/README.md`                                     | OK |
| `dist/templates/LICENSE.md`                                    | OK |
| `dist/templates/BOOTSTRAP-PROMPT.md`                           | OK (cópia do bootstrap/PROMPT.md) |
| `dist/templates/VERSION`                                       | OK |
| `dist/templates/tenant-readme.md`                              | OK |

---

## 3. Dry-run conceitual — o que `build.sh` copiaria

Stage: `dist/build/pulsar-os-v1.0.0/`

```
pulsar-os-v1.0.0/
├── README.md                    (de templates/README.md)
├── LICENSE.md                   (de templates/LICENSE.md)
├── BOOTSTRAP-PROMPT.md          (de templates/BOOTSTRAP-PROMPT.md)
├── VERSION                      (de templates/VERSION)
├── core/
│   ├── CLAUDE.md.template
│   ├── agents-config.default.json
│   ├── agents-config.schema.json
│   ├── agents-template/         (8 SOULs)
│   ├── skills-template/         (24 skills)
│   ├── onboarding/              (6 specs)
│   ├── bootstrap/               (5 prompts)
│   └── brand/                   (14 ativos brand v1.0)
├── tenant/
│   ├── .gitkeep
│   └── README.md                (de templates/tenant-readme.md)
└── installer/
    ├── install.sh + lib/
    ├── docker-compose.yml
    ├── postgres/, vercel/, mcp/, bots/, smoke/
    └── README.md
    (excluídos via rsync: AUDIT-existing-script.md, VALIDATION.md, *.log, .env)
```

**Total arquivos no zip:** ~85 (8+24+6+5+14+24 = 81 + 4 raiz + tenant/README + .gitkeep)

---

## 4. Tamanho estimado

| Componente               | Bruto |
| ------------------------ | ----: |
| CLAUDE.md.template       |  16K  |
| agents-config.*.json     |  16K  |
| agents-template/         |  40K  |
| skills-template/         | 148K  |
| onboarding/              |  52K  |
| bootstrap/               |  40K  |
| brand/v1.0-half-light/   | 244K  |
| installer/ (filtrado)    | 180K  |
| **Total descompactado**  | **~750 KB** |

**Zipado:** estimativa **~250-400 KB** (bem abaixo da projeção inicial 5-15 MB — Brand v1.0 SVGs são leves; nenhum binário pesado). Cabe em e-mail ou link Stripe sem fricção.

SHA256 será gravado em `pulsar-os-v1.0.0.sha256` ao lado do zip.

---

## 5. Grep de leak — nenhum dado PulsarH-específico nos templates

Rodado em `dist/templates/`:

```
grep -rEn "gestaopulsarh|sala-de-guerra-pulsar|Rodrigo Braga|rbraga01|72\.60\.6\.61|172\.19\.0\.2|pulsarh_secure_pass" dist/templates/
→ nenhum match
```

**OK.** Templates limpos. (Conteúdo `/core/*` herdado dos diretórios fonte segue regras do inventário core-vs-tenant — fora deste escopo.)

---

## 6. Próximo passo

Para gerar o zip de fato (não rodado nesta validação):

```
bash dist/build.sh --version v1.0.0 --output dist/
```

Saídas:
- `dist/pulsar-os-v1.0.0.zip`
- `dist/pulsar-os-v1.0.0.sha256`

Idempotente (rodar 2x produz mesmo resultado, sobrescreve).

---

## v2 — Re-validacao apos Iniciativa 8.1 (2026-05-05)

Apos fixes 8.1 (3 bloqueadores + 3 gaps — ver `smoke-e2e/8.1-fixes-applied.md`):

```
zip:    /root/pulsarh-workspace/pulsar-os/dist/pulsar-os-v1.0.0.zip
size:   340K
sha256: dab9334b74d5d360f44bf0a454c5d75fa8c634c8e3de1e3d69538d79e0d5fc3e
```

### Greps de seguranca em `/tmp/pulsar-os-sandbox-v2/`

| Check | Match |
| --- | --- |
| `pulsarh:pulsarh_secure\|172.19.0.2\|pulsarh_war_room` | 0 |
| `Rodrigo Braga\|rbraga01` | 0 |
| `github.com/pulsarh/\|pulsarh/pulsar-os` | 0 |
| `handoff-*.md` | 0 |

ZERO leaks confirmados. Zip pronto pra entrega Founder.

