# Pulsar OS — Onboarding: First-Mission Router

Tabela de roteamento da 1a missao com base na resposta P12 (`dor_atual`). Pra cada dor, 3 mensagens disparadas em sequencia no Telegram (~10s entre elas):

1. **Proposta** — qual missao, qual VP responsavel, prazo
2. **Porque** — por que essa missao resolve a dor declarada
3. **Confirmacao** — convite explicito ("topa comecar amanha 8h?")

---

## Tabela mestre

| Codigo dor (P12) | Missao | VP / Heads | Prazo | Project Kanban |
|---|---|---|---|---|
| `vende-pouco` (1) | Mapeamento funil + cold IG/email piloto (50 leads) | Caio (Hunter + Closer) | 7d | "Vendas — funil + cold piloto" |
| `soterrado` (2) | Auditoria processos (top 10 tarefas/sem) + 3 automacoes prioritarias | Falconi (Metodologia + Automacao) | 14d | "Ops — auditoria + 3 automacoes" |
| `conteudo-morto` (3) | Pipeline editorial: 3 carrosseis/sem por 4 semanas, radar Leo Dias diario | Alfredo (Mauricio + Betina + Leo Dias) | 7d (1a semana) + 28d total | "Marketing — esteira editorial v1" |
| `produto-nicho` (4) | Discovery produto + naming + esteira proposta | Flavia (Naming + Esteira + Tendencias) | 21d | "Produto — discovery + esteira v1" |
| `time-desalinhado` (5) | Mapeamento cultural + ritual semanal + onboarding doc | Simon (Cultura + Curadoria) | 14d | "People — cultura + ritual" |
| `nao-sei-lucro` (6) | DRE retroativa 3 meses + projecao 3 meses + alerta margem | Dalio (DRE + Margem) | 7d | "Financeiro — DRE + projecao" |
| `outra` (7) ou skip | Donna provoca em 24h re-perguntando ou pedindo esclarecimento | Donna | — | — |

---

## Rotas (3 mensagens cada)

### Rota 1 — `vende-pouco`

**M1 (proposta) — ~340 chars**
```
Primeira missao: maquina de venda destravada em 7 dias.

Quem roda: Caio (VP Vendas) com Hunter (prospeccao) e Closer (fechamento).

Entrega:
- mapeamento do funil atual (onde lead some)
- 50 leads quentes pra cold IG/email
- script de abordagem ajustado pro teu ICP
- 3 fechamentos rodados pra calibrar
```

**M2 (porque) — ~310 chars**
```
Por que essa.

Tua dor e pipeline vazio. Antes de gastar com ads ou esperar marca crescer, abre canal de prospeccao ativa — voce escolhe quem entra. Caio fecha porque sabe ouvir, nao porque sabe tecnica fria.

Em 7 dias voce tem maquina basica andando, nao promessa.
```

**M3 (confirmacao) — ~140 chars**
```
Topa comecar amanha 8h? Caio te chama no Telegram com 5 perguntas pra calibrar antes de prospectar. Manda "vai" e eu inicio.
```

### Rota 2 — `soterrado`

**M1 (proposta) — ~340 chars**
```
Primeira missao: te tirar do operacional em 14 dias.

Quem roda: Falconi (VP Ops) com Metodologia (PDCA) e Automacao (Betinho).

Entrega:
- top 10 tarefas que comem teu tempo (auditadas)
- 3 automacoes priorizadas (ROI vs esforco)
- SOP escrito das 3 ja com responsavel
- voce sai do gargalo em 2 semanas
```

**M2 (porque) — ~290 chars**
```
Por que essa.

Founder soterrado e gargalo da empresa inteira. Falconi nao acha solucao genial — acha o que se repete e bota num sistema. Pessoa boa em sistema ruim entrega ruim. A gente vira o jogo arrumando o sistema, nao te pedindo pra correr mais.
```

**M3 (confirmacao) — ~130 chars**
```
Topa comecar amanha 8h? Falconi te chama com 4 perguntas pra mapear teu dia. Manda "vai" e eu inicio.
```

### Rota 3 — `conteudo-morto`

**M1 (proposta) — ~360 chars**
```
Primeira missao: Instagram vivo em 7 dias, esteira firme em 28.

Quem roda: Alfredo (VP Marketing) com Mauricio (design), Betina (copy) e Leo Dias (radar).

Entrega:
- semana 1: 3 carrosseis publicaveis + radar diario de pauta
- 4 semanas: 12 carrosseis + 4 reels + relatorio engajamento
- voz da marca calibrada na 2a semana
```

**M2 (porque) — ~290 chars**
```
Por que essa.

IG morto nao e falta de criatividade — e falta de processo. Leo Dias varre o que ta pegando, Betina escreve copy que converte (nao decora), Mauricio embala com a brand v1 Half-Light. Voce aprova ou manda voltar. Em 4 semanas teu IG vira ativo, nao tarefa.
```

**M3 (confirmacao) — ~130 chars**
```
Topa comecar amanha 8h? Alfredo te chama com 3 perguntas pra calibrar voz. Manda "vai" e eu inicio.
```

### Rota 4 — `produto-nicho`

**M1 — ~330 chars**
```
Primeira missao: produto novo com naming firme em 21 dias.

Quem roda: Flavia (VP Produtos) com Naming (Ladeira), Esteira (Cortella) e Tendencias (Talles).

Entrega:
- discovery: 5 entrevistas com ICP atual
- 3 nomes propostos (com tese)
- esteira inicial 3 niveis (entrada, core, premium)
- pricing piloto
```

**M2 — ~280 chars**
```
Por que essa.

Produto sem nome firme e produto sem chao. Flavia nao chuta naming bonito — testa contra o ouvido do cliente. Em 21 dias voce tem nome com tese, esteira logica e preco que se sustenta. Nicho indefinido vira posicao definida.
```

**M3 — ~130 chars**
```
Topa comecar amanha 8h? Flavia te chama com 3 perguntas pra abrir discovery. Manda "vai" e eu inicio.
```

### Rota 5 — `time-desalinhado`

**M1 — ~330 chars**
```
Primeira missao: time alinhado em 14 dias.

Quem roda: Simon (VP People) com Cultura (Bernardinho) e Curadoria (Cortella).

Entrega:
- mapeamento cultural (3 entrevistas curtas com o time)
- 1 ritual semanal definido (formato + horario + dono)
- onboarding doc para proximo entrante
- carta de cultura v1
```

**M2 — ~290 chars**
```
Por que essa.

Time desalinhado nao e falta de talento — e falta de ritual. Simon comeca pelo Porque, Bernardinho instala disciplina, Cortella cura o saber pra nao virar ruido. Em 2 semanas voce tem ritual rodando e doc pra novo entrante. Cultura vira sistema.
```

**M3 — ~130 chars**
```
Topa comecar amanha 8h? Simon te chama com 4 perguntas pra abrir o mapeamento. Manda "vai" e eu inicio.
```

### Rota 6 — `nao-sei-lucro`

**M1 — ~310 chars**
```
Primeira missao: clareza financeira em 7 dias.

Quem roda: Dalio (VP Financeiro) com DRE (Beto) e Margem (Lemann).

Entrega:
- DRE retroativa 3 meses (real, nao chutada)
- projecao 3 meses a frente (cenario base + pessimista)
- alerta de margem por produto
- radar de furos no caixa
```

**M2 — ~280 chars**
```
Por que essa.

Founder que nao sabe se ta lucrando vive na ansiedade. Dalio fica com o numero, nao com o ego. Em 7 dias voce abre teu Excel mental — saca o que da margem, o que sangra e quanto sobra mes que vem. Decisoes ficam baratas quando o dado e claro.
```

**M3 — ~130 chars**
```
Topa comecar amanha 8h? Dalio te chama com 5 perguntas pra puxar os numeros. Manda "vai" e eu inicio.
```

### Rota 7 — `outra` ou skip

Pulse responde uma mensagem so:

```
Anotei. Donna te chama em 24h pra entender melhor a dor antes de eu rotear missao. Enquanto isso, qualquer pergunta operacional, manda — time ja ta acordado.
```

Donna agenda follow-up no DB (`bau_tasks` agentSlug=donna, type=cobranca, due=+24h).

---

## Combinacao de dores (caso o Founder responda 2 numeros, ex: "1 e 3")

Se P12 retorna multipla escolha (ex: `vende-pouco` + `conteudo-morto` na Padaria):
- Pulse roda Rota 1 (Caio cold IG) E Rota 3 (Alfredo carrosseis) em paralelo.
- Mensagens combinadas: 1 proposta unificada (~500 chars), 1 porque unificado, 1 confirmacao.
- Prazo: 7d nas 2 frentes.
- Project Kanban: 2 cards separados, mesma semana.

---

## Regra de seguranca

Se Founder nao confirmou ("vai") em 24h: Donna provoca curto. Em 48h sem confirmar: missao fica `paused` no Kanban. Pulse nunca executa missao sem confirmacao explicita.
