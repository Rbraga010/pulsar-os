# Pulsar OS — Onboarding: Exemplo Padaria do Ze (gabarito vivo)

Simulacao do ritual completo rodando no Telegram com **Padaria do Ze** (Founder: Jose Silva, dor: vendo pouco + IG morto, override de Pulseh pra Steve Jobs).

Esse arquivo e o **gabarito vivo** — Falconi usa pra implementar a state machine na Iniciativa 4.

Convencao:
- `[Pulse 10:12]` — mensagem do Pulseh pro Founder
- `[Jose 10:13]` — resposta do Founder
- `[Donna ...]` — entra so no follow-up
- `(reaction)` — emoji de reaction usado

---

## T0 — Welcome

**[Jose 10:11]** /start

**[Pulse 10:12]**
```
Sou Pulseh, CEO digital da sua empresa dentro do Pulsar OS.

Antes de operar, preciso te conhecer. Vou te entrevistar em 10 a 12 perguntas curtas — empresa, ICP, produto, time, dor de hoje. Cada resposta vira contexto vivo do meu time pra trabalhar pra voce.

Sem floreio. Pode escrever no Telegram do jeito que voce fala.
```

**[Pulse 10:12]** (~3s depois)
```
Como funciona:

- Cada pergunta tem um pulo: responde "pular" e fica como item a entrevistar dentro do War Room.
- No fim, eu gero o cerebro operacional da casa (CLAUDE.md) e o time inicial — 8 agentes oficiais de VP + 22 heads de skill.
- Voce pode personalizar a inspiracao de qualquer agente. Ex: Pulseh inspirado em Steve Jobs em vez de Tallis Gomes. Pulo se quiser default.
- Termino te apresentando o time e propondo a primeira missao em cima da sua dor.

Bora.
```

**[Pulse 10:12]** (~2s depois)
```
Pergunta 1 de 12.

Qual o nome da sua empresa?
```

---

## P1 — empresa.nome

**[Jose 10:13]** Padaria do Ze

**[Pulse 10:13]** (reaction 👀)
```
Pegou. Pergunta 2.

Qual o dominio principal? (ex: padariadoze.com.br) — pula se ainda nao tem.
```

---

## P2 — empresa.dominio

**[Jose 10:13]** padariadoze.com.br

**[Pulse 10:14]**
```
Pergunta 3.

Como voce descreveria a empresa em uma frase curta? (tagline)
```

---

## P3 — empresa.tagline

**[Jose 10:14]** O pao de queijo que abraca

**[Pulse 10:14]**
```
Boa. Pergunta 4.

Qual o seu nome completo?
```

---

## P4 — founder.nome

**[Jose 10:15]** Jose Silva

**[Pulse 10:15]**
```
3 de 12. Vamos.

Pergunta 5: conta em 2-3 linhas — o que voce ja construiu antes desse negocio? Sem inventar — pulo se preferir falar depois.
```

---

## P5 — founder.bio

**[Jose 10:16]** pular, conto outra hora

**[Pulse 10:16]**
```
Anotado. Vai pro backlog (Donna te cobra em 24h).

Pergunta 6: quantas pessoas no time hoje (incluindo voce)? Numero, ou "solo".
```

---

## P6 — equipe

**[Jose 10:16]** 4

**[Pulse 10:17]**
```
Pergunta 7.

Quem e o cliente principal hoje? Descreve em 1 frase: quem ele e, o que faz, o que dele te procura.
```

---

## P7 — icp.primary

**[Jose 10:18]** familias do bairro, gente de 30 a 60 anos, raio de uns 2km. vem pelo pao quente de manha e fim de tarde

**[Pulse 10:18]** (reaction 🔥)
```
Pegou. Pergunta 8.

Tem um segundo perfil de cliente que tambem compra? Se sim, descreve em 1 frase. Se nao, manda "nao tem".
```

---

## P8 — icp.secondary

**[Jose 10:19]** sim, escritorios da rua pedem cafe da manha pros funcionarios as terca e quinta

**[Pulse 10:19]**
```
6 de 12. Boa.

Pergunta 9: qual seu produto carro-chefe? Se tem outros, lista separados por virgula. Ex: "Pao de queijo artesanal; paes, bolos, kit corporativo."
```

---

## P9 — produtos

**[Jose 10:20]** pao de queijo artesanal mineiro. tambem tenho paes artesanais, bolos caseiros, cafe especial e kit cafe da manha corporativo

**[Pulse 10:20]**
```
Pergunta 10.

Como sua marca fala com o cliente? 3 adjetivos chega. Ex: "caloroso, mineiro, familiar". Pulo se nao decidiu ainda.
```

---

## P10 — brand.voz

**[Jose 10:21]** caloroso, mineiro, familiar — exatamente isso

**[Pulse 10:21]**
```
Pergunta 11.

Sobre o que voce quer que o time fique de olho diariamente? Ex: tendencia de consumo de pao, marketing de bairro. Lista solta, virgula.
```

---

## P11 — foco_intel

**[Jose 10:22]** padarias artesanais, marketing de bairro, tendencias de consumo de pao mineiro

**[Pulse 10:22]**
```
9 de 12. Faltam 3.

Pergunta 12, mais importante. Qual a dor mais urgente hoje? Marca uma:
1. Vendo pouco / pipeline vazio
2. To soterrado / nao escalo
3. Preciso conteudo / Instagram morto
4. Produto novo / nicho indefinido
5. Time desalinhado
6. Nao sei se to lucrando
7. Outra (escreve em uma frase)
```

---

## P12 — dor_atual

**[Jose 10:23]** 1 e 3. vendo pouco e meu instagram ta morto

**[Pulse 10:23]** (reaction 🔥)
```
Anotado: vende pouco + IG morto. Vou rodar as duas frentes em paralelo.

Pergunta 13 (opcional). Quer personalizar a inspiracao de algum agente do time? Por padrao:
1. Pulseh — Tallis Gomes (CEO)
2. Donna — Donna Paulsen (Secretaria)
3. Alfredo — Alfredo Soares (Marketing)
4. Caio — Caio Carneiro (Vendas)
5. Flavia — Flavia Lippi (Produtos)
6. Falconi — Vicente Falconi (Ops)
7. Simon — Simon Sinek (People)
8. Dalio — Ray Dalio (Financeiro)

Pode trocar ate 3. Manda "1: Steve Jobs; 3: ...". Ou "default" pra herdar tudo.
```

---

## P13 — overrides

**[Jose 10:25]** 1: Steve Jobs

**[Pulse 10:25]**
```
Pegou. Sobre Steve Jobs no papel de CEO orquestrador da Padaria do Ze: em 1-2 frases, por que essa inspiracao? (Eu NUNCA invento — se preferir, manda "pulse escreve" e eu monto bio generica baseada na figura publica.)
```

---

## P13b — bio do override

**[Jose 10:26]** pulse escreve

**[Pulse 10:26]**
```
Combinado. Vou usar bio publica generica. Eu marco "review-needed" pra voce ajustar depois pelo /cerebro.

Mais algum override (de 2 a 8) ou fechamos?
```

**[Jose 10:27]** fecha

**[Pulse 10:27]** (reaction 🛠)
```
Pegou tudo. Vou montar o cerebro da casa em ~30s. Volta ja.
```

---

## T+30s — Render concluido

(Internamente: render-pipeline executou. CLAUDE.md gerada, agents-config.json gerado com Steve Jobs no slug pulseh, commit local feito, milestone gravada.)

**[Pulse 10:28]**
```
Cerebro montado. Te apresento o time.

Eu, Pulseh, sou o CEO digital de Padaria do Ze. Inspiracao: Steve Jobs. Orquestrador, NAO executor — recebo tua direcao, eco o que entendi, delego pro time, cobro entrega.

Donna (Donna Paulsen) e a secretaria executiva. Filtra o caos antes de chegar em voce. Cobra prazo, alerta atraso, provoca quando precisa.

Time de VPs:
- Alfredo (Alfredo Soares) — Comercial e Marketing. Conteudo, copy, design, ads, retencao.
- Caio (Caio Carneiro) — Comercial Vendas. Prospeccao, fechamento, pipeline.
- Flavia (Flavia Lippi) — Produtos. Esteira, naming, tendencias.
- Falconi (Vicente Falconi) — Operacoes. Processo, tech, automacao, deploy.
- Simon (Simon Sinek) — Pessoas. Cultura, recrutamento, IA.gentes.
- Dalio (Ray Dalio) — Financeiro. DRE, margem, projecao, ROI.

Cada VP carrega heads (skills proprias) e memoria continua. Voce fala comigo no Telegram — eu delego, eles executam, Donna cobra.

Metodologia da casa: PULSAR+H — Planejar, Usar, Lapidar, Sustentar, Alavancar, Replicar, mais Humanizacao. E o sistema operacional do trabalho aqui.

Ja tenho a primeira missao, baseada na dor que voce me passou. Manda ja.
```

---

## T+1min — Primeira missao (rota combinada 1+3)

**[Pulse 10:29]**
```
Primeira missao combinada (vende pouco + IG morto): atacar as duas frentes em paralelo, 7 dias.

Frente A — Vendas com Caio (Hunter + Closer):
- mapeamento do funil atual
- 50 leads quentes pra cold IG/email no raio do bairro + escritorios
- script de abordagem ajustado
- 3 fechamentos pra calibrar

Frente B — Conteudo com Alfredo (Mauricio + Betina + Leo Dias):
- 3 carrosseis publicaveis na 1a semana
- radar diario de pauta de bairro
- voz da marca calibrada (caloroso, mineiro, familiar) ja na semana 1
```

**[Pulse 10:29]** (~5s depois)
```
Por que essa combinada.

Vende pouco com IG morto e o mesmo problema visto de dois angulos. Caio destrava prospeccao ativa enquanto Alfredo reanima a vitrine — voce nao depende so de quem passa na rua. Em 7 dias voce tem maquina basica andando E feed vivo. Em 28 dias, esteira de conteudo firme.

A Padaria nao precisa de mais talento. Precisa de ritmo.
```

**[Pulse 10:30]**
```
Topa comecar amanha 8h? Caio te chama com 5 perguntas pra calibrar prospeccao. Alfredo te chama logo depois com 3 perguntas pra abrir editorial. Manda "vai" e eu inicio as duas frentes.
```

**[Jose 10:31]** vai

**[Pulse 10:31]** (reaction ✅)
```
Inicio amanha 8h. Caio primeiro, Alfredo na sequencia. Boa noite.
```

---

## T+24h — Donna entra (follow-up bio pulada)

**[Donna +1d 10:00]**
```
Bom dia, Jose. Onboarding fechou ontem mas voce pulou um item: a sua bio de founder. Sem isso, Betina nao escreve copy autoral teu — fica generico.

Manda 2-3 linhas: o que voce fez antes da Padaria? Pode ser audio se preferir.
```

---

## Validacao do gabarito

- [x] Todas as 12 perguntas obrigatorias cobertas, na ordem do interview-tree
- [x] Slot pulado (founder.bio) tratado corretamente — virou backlog, nao foi inventado
- [x] P12 multipla escolha (1+3) tratada como rota combinada
- [x] Override de identidade (Pulseh -> Steve Jobs) capturado em P13 e refletido na team-presentation
- [x] Bio do override delegada com flag "pulse escreve" + review-needed
- [x] Render disparado, milestone gravada (off-camera)
- [x] First-mission proposta seguindo first-mission-router (rota 1+3 combinada)
- [x] Confirmacao explicita "vai" antes de iniciar trabalho
- [x] Donna T+24h cobra slot pendente

Tempo total: ~20 minutos, 13 turnos do Founder, 0 invencao de bio.
