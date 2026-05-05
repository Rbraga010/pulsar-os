# Pulsar OS — State Recovery (especificacao)

Como o Pulse retoma o onboarding apos qualquer interrupcao. Premissa: Pulse e a state machine viva — nao tem maquina de estado em codigo. Estado vive em arquivos do tenant.

---

## 1. Arquivos persistentes

### 1.1 `/tenant/onboarding-answers.json` (essencial)

Estado canonico do onboarding. Estrutura completa em `render-pipeline.md` secao 1. Pulse escreve apos CADA resposta validada do Founder.

Sem ele, nao ha como retomar — Pulse precisa recomecar do P1.

### 1.2 `/tenant/.last-question-id` (ponto de retomada explicito)

Arquivo de 1 linha com o codigo da PROXIMA pergunta a disparar. Valores: `P1`, `P2`, ..., `P12`, `P13`, `P13b-pulseh`, `P13b-donna`, ..., `RENDER`, `TEAM-PRES`, `FIRST-MISSION`, `AWAITING-VAI`, `DONE`.

Pulse escreve apos enviar a pergunta e receber/persistir a resposta. Esse arquivo e o ponteiro — `onboarding-answers.json` e o conteudo.

### 1.3 `/tenant/backlog-onboarding.md` (slots vazios)

Markdown plano com lista de slots que o Founder pulou (`/skip`). Donna le em T+24h pra cobrar. Linha-padrao:

```
- [ ] founder.bio — Founder pulou em P3 em 2026-05-05T10:18. Donna cobra T+24h.
```

### 1.4 `/tenant/onboarding-answers.json.bak.{timestamp}` (backup)

A cada Write em `onboarding-answers.json`, Pulse copia o anterior pra `.bak.{ISO8601}`. Mantem ultimos 5 (FIFO). Garantia contra corrupcao.

---

## 2. Fluxo de boot (ordem obrigatoria)

Quando o Founder cola `PROMPT.md` ou `PROMPT-modo-retomada.md`:

```
1. Read /tenant/onboarding-answers.json
   ├─ existe + valido? -> modo retomada (ver 3)
   ├─ existe + invalido? -> modo recovery (ver 4)
   └─ nao existe? -> modo novo (ver 5)
```

---

## 3. Modo retomada (arquivo existe e valido)

```
2. Read /tenant/.last-question-id
   ├─ existe? proximo step = valor lido
   └─ nao existe? deriva: count(answers preenchidas) + 1
3. Se .last-question-id == DONE:
   - Onboarding ja terminado. mcp_telegram_reply: "Onboarding ja completo. Quer revisar algo ou seguimos pra missao?". NAO refaca render.
4. Se .last-question-id em [RENDER, TEAM-PRES, FIRST-MISSION, AWAITING-VAI]:
   - Pulou interrupcao numa fase pos-entrevista. Retoma a fase exata sem refazer perguntas.
5. Se .last-question-id em [P1..P13b-*]:
   - mcp_telegram_reply: "Bom dia. Paramos em {.last-question-id}. Continuamos agora ou prefere mais tarde?"
   - Aguarda resposta humana antes de disparar a pergunta.
6. Avanca normalmente.
```

---

## 4. Modo recovery (arquivo corrompido)

JSON invalido em `onboarding-answers.json`:

```
1. Read /tenant/onboarding-answers.json.bak.* (mais recente)
2. Se backup valido:
   - mcp_telegram_reply: "Encontrei o arquivo de respostas corrompido mas tenho backup de {ts}. Posso restaurar e continuar de {.last-question-id derivada}, ou recomecar do zero. Manda 'restaura' ou 'recomeca'."
   - Aguarda escolha humana.
3. Se nenhum backup valido:
   - mcp_telegram_reply: "Arquivo de respostas corrompido, sem backup. Vou ter que recomecar. Tudo bem?"
   - Se 'sim': delete answers.json + .last-question-id, recomeca P1.
   - Se 'nao': pause. Escala via warroom_log_agent_memory(type=alert) pra Falconi olhar a VPS.
```

NUNCA delete arquivos sem confirmacao explicita do Founder.

---

## 5. Modo novo (arquivo nao existe)

Sessao limpa. Comportamento padrao do `PROMPT.md`. Pulse cria `onboarding-answers.json` ao gravar a primeira resposta (P1).

---

## 6. Caso especial: Founder apaga `onboarding-answers.json` manualmente

Cenario raro mas possivel — Founder mexeu na pasta. Quando proxima execucao:

- Pulse roda boot (passo 1) e nao acha o arquivo
- Mas `.last-question-id` ainda existe (=> contradicao)
- Pulse detecta inconsistencia e pergunta: "Encontrei `.last-question-id` em P{n} mas o arquivo de respostas sumiu. Voce apagou de proposito? Posso recomecar do zero ou tentar reconstruir do que voce lembra."
- Aguarda escolha humana.

---

## 7. Idempotencia do render

Se Founder rodar onboarding completo de novo (sessao 2 do mesmo tenant), Pulse:

- Detecta `tenant/CLAUDE.md` ja existente
- Renomeia pra `tenant/CLAUDE.md.bak.{ISO8601}`
- Renomeia `tenant/agents-config.json` -> `.bak.{ts}`
- Renomeia `tenant/onboarding-answers.json` -> `.bak.{ts}`
- Pergunta: "Voce ja tem cerebro montado de {data anterior}. Vai sobrescrever — backup feito. Confirma?"
- Aguarda 'vai' ou 'cancela'.

NUNCA sobrescreve sem backup + confirmacao.

---

## 8. Recuperacao apos crash do Claude Code mid-render

Render (passo 7 do PROMPT.md) e sequencial: Read template -> Write CLAUDE.md -> Read default config -> Write agents-config.json -> validacao -> mcp_log_memory -> team-presentation -> first-mission.

Se Claude Code matou no meio (ex: depois de Write CLAUDE.md mas antes de Write agents-config):

- Boot detecta `.last-question-id == RENDER` mas `tenant/CLAUDE.md` ja existe e `tenant/agents-config.json` nao
- Pulse re-roda render do zero (e idempotente: leitura do template + answers gera mesmo output deterministico)
- Continua daquele ponto

Validacao checklist (render-pipeline.md secao 4.3) detecta inconsistencias antes de team-presentation. Se falhar, escala Falconi.

---

## 9. Tabela-resumo

| Estado encontrado | Acao Pulse |
|---|---|
| Sem answers.json | Modo novo, comeca P1 |
| answers.json ok + last-question-id ok | Retoma daquela pergunta |
| answers.json ok + sem last-question-id | Deriva proxima de count(answers) + 1 |
| answers.json corrompido + backup ok | Pergunta 'restaura/recomeca' |
| answers.json corrompido + sem backup | Escala Falconi, pergunta Founder |
| answers.json apagado + last-question-id presente | Pergunta Founder se foi proposital |
| last-question-id == DONE | Onboarding ja completo, nao refaz |
| last-question-id == RENDER mid-crash | Re-roda render (idempotente) |
| Reonboarding completo | Backup tudo + confirma sobrescrita |

---

## 10. Anti-patterns

- ❌ Pulse NUNCA executa `git reset`, `rm -rf`, `git checkout` em `/tenant/` durante recovery.
- ❌ Pulse NUNCA assume escolha do Founder em recovery — sempre aguarda confirmacao explicita.
- ❌ Pulse NUNCA tenta "consertar" JSON corrompido editando manualmente. Restaura do backup ou recomeca.
- ❌ Pulse NUNCA escreve em `/core/` durante recovery (so leitura). `/tenant/` e a unica zona de escrita.
