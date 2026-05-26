---
slug: clara-memoria-cliente
title: Como Clara mantém memória viva do lojista
category: orchestration
agent: clara
version: v1.0
lastReview: 2026-05-22
---

# Skill · Memória do Cliente (Lojista)

## Princípio

Clara é sócia parceira · não atendente que esquece. Toda info importante do dono fica em memória persistente · indexada · sempre atualizada (nunca duplicada).

## Estrutura de arquivos

```
cerebro/memory/
├── MEMORY.md           # index com pointers · ler PRIMEIRO sempre
├── dono.md             # dados pessoais + família
├── loja.md             # negócio · produto · time · faturamento
├── metas.md            # objetivos · progresso · histórico de batidas
├── historico-conversas.md  # key moments · decisões tomadas · padrões
├── claro-vendas.md     # vendas Claro feitas · objeções recorrentes
└── sessions/
    └── YYYY-MM-DD.md   # diário · 1 por dia · compacta no fim
```

## MEMORY.md (index · max 200 linhas)

```markdown
# MEMORY INDEX · Clara

## Dono
- [Dono · Pessoa e Família](dono.md) — Quem é · família · padrões emocionais
- [Loja](loja.md) — Negócio · produto · faturamento · time
- [Metas](metas.md) — Objetivos 30/60/90 dias · progresso

## Operação
- [Histórico Conversas](historico-conversas.md) — Key decisions · learnings
- [Vendas Claro](claro-vendas.md) — Histórico vendas · objeções comuns

## Diário
- [2026-05-22](sessions/2026-05-22.md) — Hoje
```

## dono.md (exemplo)

```markdown
---
name: dono
description: Dados pessoais + família · usado pra criar vínculo
last_update: 2026-05-22
---

# Dono · Pedro Silva

## Pessoal
- Nome: Pedro Silva (chama Pedrinho · amigos)
- Cidade: Sorocaba-SP · bairro Jardim Simus
- Idade aproximada: 38 anos
- Esposa: Mariana (gestora de RH em farmácia)
- Filhos:
  - João · 8 anos · 3º ano · gosta futebol Palmeiras
  - Sofia · 4 anos · pré-escola · alérgica a leite
- Pais: ambos vivos · moram cidade vizinha (Itu)

## Padrões emocionais
- Segunda-feira sempre apertado (caixa baixo · estresse)
- Sexta-feira motivado (semana fechando)
- Domingo de noite ansioso (semana começando)
- Quando esposa viaja a trabalho · fica mais sobrecarregado (cuidar dos 2 filhos sozinho)

## Hobbies / o que importa
- Futebol Palmeiras (segue todo jogo)
- Churrasco família domingo
- Quer dar curso pro João (inglês)

## Datas importantes
- Aniversário Pedro: 14/agosto
- Aniversário Mariana: 03/março
- Aniversário João: 21/junho
- Aniversário Sofia: 09/novembro
- Aniversário casamento: 12/setembro
```

## loja.md (exemplo)

```markdown
---
name: loja
description: Negócio · produto · time · saúde financeira
last_update: 2026-05-22
---

# Loja Pedrinho Modas

## Identidade
- Nome: Pedrinho Modas
- Cidade: Sorocaba-SP · Jardim Simus
- Endereço: Rua das Flores 123
- Inaugurada: 2018
- Site: pedrinhomodas.com.br (vai criar via Dev)
- IG: @pedrinhomodas (1.2k seguidores)
- WhatsApp: 15 99999-9999

## Produto
- Carro-chefe: roupa feminina casual (60% faturamento)
- Secundário: acessórios · bolsa (25%)
- Terciário: roupa infantil (15%)
- Ticket médio: R$ 85
- Margem: 50% (média)
- Faturamento mês: R$ 18-22k (variável)

## Time
- 2 pessoas: Pedro + Joana (vendedora · part-time tarde)
- Sem outros

## Caixa
- Status: saudável (não apertado · não sobrando)
- Reserva: 2-3 meses de operação
- Maior gasto fixo: aluguel R$ 3.200/mês · folha R$ 4.500/mês

## Sazonalidade
- Forte: Dia das Mães · Black Friday · Natal · Volta às aulas
- Fraco: fevereiro · agosto

## Plano Claro
- Pedro: NET fibra residencial (300mb)
- Loja: empresa Claro (chip empresa + WiFi cliente)
- Cliente: NUNCA ofereceu plano Claro pra cliente final (oportunidade)
```

## metas.md (exemplo)

```markdown
---
name: metas
description: Objetivos · progresso · histórico
last_update: 2026-05-22
---

# Metas · Pedro Silva

## Trimestre atual (Mai-Jul 2026)
- Faturamento: R$ 75k (vs R$ 60k tri anterior · +25%)
- Vender 10 planos Claro pra clientes
- Lançar site
- Reduzir custo fornecedor X em 15%

## Progresso
- Faturamento maio: R$ 19k (semana 1: 5k · semana 2: 4k · semana 3: 5k)
- Planos Claro vendidos: 0 (não começou)
- Site: não começou
- Custo fornecedor X: não atacou ainda

## Próximo passo concreto
- Esta semana: lançar 1 post IG promo Dia das Mães · começar conversa fornecedor X
```

## historico-conversas.md (exemplo)

```markdown
---
name: historico-conversas
description: Key moments · decisões · learnings
last_update: 2026-05-22
---

# Histórico Conversas · Clara × Pedro

## Decisões tomadas
- 22/05/2026: Pedro decidiu lançar site (Clara vai entregar 1 página vitrine)
- 22/05/2026: Pedro topou estratégia de oferecer Claro pra cliente que compra acima R$ 100

## Learnings
- Pedro não gosta de planilha · prefere voz no WhatsApp
- Pedro responde melhor de manhã (9-11h)
- Pedro fica sobrecarregado quando esposa viaja (cuidado · não pede coisa nova nessas semanas)
- Pedro confia em mim mais quando lembro dos filhos (mencionar João/Sofia gera vínculo)

## Coisas que Pedro NÃO quer
- Não quer abrir loja 2 (foco em 1)
- Não quer demitir Joana (vínculo afetivo)
- Não quer cobrar caro · prefere giro
```

## Como ATUALIZAR (não duplicar)

A cada conversa que revela info nova:
1. Identifica qual arquivo (dono.md · loja.md · metas.md · etc)
2. Lê arquivo
3. ATUALIZA campo existente OU adiciona linha nova
4. Atualiza `last_update` no frontmatter
5. SALVA

NUNCA cria arquivo novo · NUNCA duplica info.

## Como RECALL (usar memória)

A cada mensagem do dono:
1. Lê MEMORY.md (index)
2. Lê dono.md + loja.md (sempre)
3. Lê metas.md se conversa for sobre objetivo
4. Lê historico-conversas.md se contexto exige (decisão anterior · padrão)
5. Lê sessions/HOJE.md se conversa contínua
6. USA info pra personalizar resposta:
   - "Pedro · lembra que você tinha falado em [X]?"
   - "Como tá a Sofia depois da gripe?"
   - "Sua meta de R$ 75k tá no 25% · vamos olhar?"

## Sessions diárias

`sessions/YYYY-MM-DD.md` · 1 arquivo por dia de atividade. Salva:
- Resumo do que rolou
- Decisões tomadas
- Próximo passo (pra amanhã saber onde parou)

No fim do dia (cron 22h BRT) · compacta · atualiza MEMORY.md · remove arquivos sessions com mais de 30 dias (movem pra archive).

## Privacidade

- Memória fica LOCAL na VPS do cliente
- ZERO upload pra servidor externo
- Cliente pode rodar `pulsar-os memory export` pra ver tudo
- Cliente pode rodar `pulsar-os memory clear` pra resetar
- Nunca compartilha info de cliente A com cliente B (cada VPS isolada)

## Anti-padrões

❌ Criar arquivo novo a cada conversa (deve atualizar existente)
❌ Esquecer de atualizar `last_update` (perde sinal de freshness)
❌ Salvar info pra "depois usar" sem propósito claro (lixo)
❌ Mencionar info pessoal pra forçar venda ("vi que tem 2 filhos · compra plano X pra eles")
❌ Salvar info que dono confidenciou em momento vulnerável (briga conjugal · etc) · respeita privacidade
