# Pulsar OS — Onboarding: Team Presentation

> Mensagens disparadas conforme cada VP nasce na sequência de instalação. Não é mais uma "apresentação final" — cada VP tem seu momento.

Diferente da v1 anterior (apresentação única no fim), agora **cada agente é apresentado no momento que nasce**. Mais editorial, mais teatral, mais memorável pro cliente.

A apresentação usa as identidades do `tenant/agents-config.json` final.

---

## Disparos por etapa

### Etapa 1 (final) — Simon nasceu

Disparado depois de Pulse coletar nome empresa, founder, setor, tom, vocabulário.

```
Simon nasceu.

Identidade: {{simon.inspiration_name}} no papel de VP People.

Ele é a CARA da {{tenant.empresa.nome}} agora. Voz, vocabulário, princípios — tudo que vier do time vai ter o DNA dele.

Os próximos 7 VPs vão ler Simon ao acordar. Vão herdar tom. Sua empresa fala uma língua só.

Próximo: Falconi + War Room. Vou subir a infra.
```

~340 chars.

---

### Etapa 2 (final) — Falconi nasceu + War Room no ar

Depois de provisionar Postgres, Vercel, MCP.

```
Falconi nasceu.

Identidade: {{falconi.inspiration_name}} no papel de VP Operações.

Ele guardou a casa: 15 tabelas Postgres, 30 agentes seedados, War Room rodando em https://warroom.{{tenant.empresa.dominio}}.

Abre lá. Confere que vê o time todo na lista.

Quando voltar, vamos pra Etapa 3 — Projeto ZERO. Antes de mais ninguém nascer, você define pra onde a empresa tá indo.
```

~370 chars.

---

### Etapa 3 (final) — Projeto ZERO criado

Depois de coletar faturamento, meta 90d, bloqueios.

```
Projeto ZERO no ar: "Levantar {{tenant.empresa.nome}} — 90 dias".

Meta: {{meta_90d}}.
Bloqueios mapeados: {{bloqueios_lista}}.

Cada VP que nasce daqui pra frente vai ler esse projeto. Vão calibrar suas skills à sua realidade — não vão ser VPs genéricos.

Próximo: Flávia. Catálogo da casa.
```

~310 chars.

---

### Etapa 4 (final) — Flávia nasceu

Depois de catalogar produtos.

```
Flávia nasceu.

Identidade: {{flavia.inspiration_name}} no papel de VP Produtos.

Ela já tem teu catálogo memorizado: {{produto_principal}} no carro-chefe, {{n_produtos}} na esteira. Margem média mapeada.

Quando algum cliente perguntar sobre teus produtos, é Flávia que responde — sem alucinação.

Próximo: Alfredo. Marca, copy, design, radar.
```

~330 chars.

---

### Etapa 5 (final) — Alfredo nasceu

Depois de coletar ICP, brand kit, concorrentes.

```
Alfredo nasceu, com time embaixo dele:

Alfredo ({{alfredo.inspiration_name}}) — VP Marketing
- Betina ({{betina.inspiration_name}}) — copy
- Maurício ({{mauricio.inspiration_name}}) — design
- Léo Dias ({{leo_dias.inspiration_name}}) — radar diário

Brand kit aplicado: cores, fontes, tom da marca. ICP calibrado: {{icp_primary_curto}}.

Radar diário começa amanhã 6h. Vai te mandar 3 sinais sobre {{concorrentes}} todo dia.

Próximo: Caio. Comercial.
```

~440 chars.

---

### Etapa 6 (final) — Caio nasceu

Depois de configurar canais, ticket, ciclo, objeções.

```
Caio nasceu, com time:

Caio ({{caio.inspiration_name}}) — VP Comercial
- Hunter Flávio — prospecção ICP em {{canais}}
- Closer Dani — qualificação SPIN + fechamento
- CS Clarissa — onboarding pós-venda

Playbook calibrado pro teu ticket {{ticket_medio}} e ciclo {{ciclo_medio}} dias.

Daemons de prospecção configurados — você liga quando quiser. Sem disparo automático no primeiro dia.

Próximo: Dalio. Números.
```

~420 chars.

---

### Etapa 7 (final) — Dalio nasceu

Depois de configurar DRE, KPIs, alertas.

```
Dalio nasceu.

Identidade: {{dalio.inspiration_name}} no papel de VP Financeiro.

Dalio já tá conectado ao Projeto ZERO — vai medir progresso da meta {{meta_90d}} todo dia.

Alertas configurados: margem cai abaixo de {{margem_minima}}, ele te chama. DRE roda {{frequencia_dre}}.

Próximo: Donna. Por último, e por boa razão.
```

~330 chars.

---

### Etapa 8 (final) — Donna nasceu (apresentação completa do time)

Depois de configurar Donna.

```
Donna nasceu — fecha o time.

Identidade: {{donna.inspiration_name}} no papel de Chefe de Gabinete.

Donna nasce por último porque chefe de gabinete só faz sentido com time pronto. Ela vê o time inteiro, agora. Cada cobrança, cada alerta, cada escalação passa por ela primeiro.

Você fala comigo (Pulse) no Telegram. Eu delego pros 6 VPs. Donna cobra. Você só decide.

Time fechado:

- Pulse ({{pulseh.inspiration_name}}) — orquestrador
- Donna ({{donna.inspiration_name}}) — chefe de gabinete
- Simon ({{simon.inspiration_name}}) — VP People (DNA da casa)
- Falconi ({{falconi.inspiration_name}}) — VP Ops
- Flávia ({{flavia.inspiration_name}}) — VP Produtos
- Alfredo ({{alfredo.inspiration_name}}) — VP Marketing
- Caio ({{caio.inspiration_name}}) — VP Comercial
- Dalio ({{dalio.inspiration_name}}) — VP Financeiro

Mais ~25 heads embaixo dos VPs.

Metodologia da casa: PULSAR+H — Planejar, Usar, Lapidar, Sustentar, Alavancar, Replicar, mais Humanização.

Próximo e último: primeira tarefa real. Vou executar algo, você vai ver o time vivo.
```

~960 chars (split em 2 mensagens se ultrapassar 1100).

---

### Etapa 9 (final) — Primeira tarefa real

Pulse executa a primeira missão real e manda confirmação.

```
{{empresa.nome}} tá no ar.

Primeira missão executada: {{descricao_missao}}.

Resultado: {{resultado_imediato}}.

A operação tá viva. Quando você quiser ver tudo: https://warroom.{{tenant.empresa.dominio}}/projetos.

Pra falar comigo: aqui mesmo. Pra reuniões, projetos, decisões — manda. Eu organizo, delego, cobro.

Sua semana começou. Vai ser diferente.
```

~340 chars.

---

## Notas de execução

- **Sem emojis no corpo** (reactions sim — `eyes`, `tools`, `check`, `fire`)
- **Sem markdown bruto** (sem `**bold**`, sem `*italic*`)
- Cada apresentação é **disparada no fim da etapa correspondente**, não em batch
- Se ultrapassar 1100 chars: dividir em 2 mensagens com 5s de espera
- Reaction `fire` na última mensagem do Founder antes de cada apresentação grande (Donna E8, Tarefa Real E9)

---

## Por que mudou da v1 anterior

**v1 anterior:** apresentação única de ~870 chars no fim, depois das 12 perguntas. Cliente lia mas não sentia que cada VP "nasceu".

**v1.0 nova:** cada VP é apresentado no momento que nasce. Cliente vivencia 8 nascimentos em sequência, com explicação da ordem. **A jornada vira história, não checklist.**

Isso é o que faz R$297 valer R$297 — não é o código, é a **experiência de despertar uma operação inteira**.
