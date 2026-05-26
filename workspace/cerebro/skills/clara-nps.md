---
slug: clara-nps
title: NPS pós-venda · Clara escuta o cliente do lojista
category: comercial
agent: clara
version: v1.0
lastReview: 2026-05-26
---

# Skill · Clara NPS

## Quando ler esta skill

- Toda venda registrada com `cliente_id` preenchido dispara automaticamente um follow-up T+7
- Lojista pergunta "como tá meu NPS?" / "tem cliente reclamando?" / "o que a galera tá achando?"
- Clara revisa semanal · agrupa respostas · destaca detratores que precisam de resgate
- Cliente responde uma pesquisa NPS · Clara classifica e age

## Princípio inviolável

**Clara NUNCA fala com cliente do lojista sem o lojista aprovar.**

A pesquisa NPS é enviada via WhatsApp Baileys EM NOME DO LOJISTA · mas:
1. Texto da mensagem é mostrado ao lojista 1ª vez (na ativação do flow) pra ele aprovar
2. Após primeira aprovação, Clara passa a enviar automaticamente · MAS NUNCA inventa promessa em nome do lojista
3. Se cliente responder com algo fora do esperado (reclamação grave, dúvida técnica, pedido especial), Clara PARA o flow automático e avisa o lojista pra ele assumir
4. Detrator (nota 0-6) gera notificação imediata pro lojista · ele decide se liga, manda WhatsApp, dá brinde, etc

## Como funciona o flow

```
[VENDA REGISTRADA com cliente_id]
        ↓
[Scheduler agenda follow_ups com motivo='nps_pesquisa', prazo=T+7]
        ↓
[T+7: scheduler.py dispara · invoca whatsapp-baileys]
        ↓
[Cliente recebe: "Oi Maria, é a {LojaNome}! Você comprou faz uma semana · 
 numa escala de 0 a 10, quanto recomenda a gente pra um amigo? Manda o número."]
        ↓
[Cliente responde]
        ↓
[Clara classifica:
  0-6 = detrator (alerta lojista AGORA)
  7-8 = neutro (registra)
  9-10 = promotor (pede review no GMB de bônus)]
        ↓
[Registra em nps_respostas]
```

## Triggers

### Trigger 1 · Toda venda com cliente_id

Quando lojista digita "Vendi X pra Maria Silva, R$ 879, Pix", Clara:

```sql
-- registra venda
INSERT INTO vendas (...) VALUES (...);

-- agenda NPS pra +7 dias
INSERT INTO follow_ups (cliente_id, motivo, prazo, canal, mensagem_template)
VALUES (
  :cliente_id,
  'nps_pesquisa',
  datetime('now', '+7 days', 'localtime'),
  'whatsapp',
  'nps_basico_v1'
);
```

### Trigger 2 · Cliente responde

Quando chega mensagem do cliente no WhatsApp Baileys com número 0-10, Clara:

```python
nota = int(match)
classificacao = (
  'detrator' if nota <= 6 else
  'neutro' if nota <= 8 else
  'promotor'
)
# insere nps_respostas
# se detrator → alerta lojista
# se promotor → pede review GMB
# se neutro → só registra
```

## Tradução pra balcão (mensagens)

### Mensagem da pesquisa pro cliente (com aprovação do lojista na 1ª vez)

```
Oi {NOME_CLIENTE}, é a equipe da {LOJA_NOME} 👋

Você comprou com a gente faz uma semana · 
queria saber como foi a experiência.

Numa escala de 0 a 10, quanto você recomenda 
a gente pra um amigo ou família?

Manda só o número 😊
```

### Resposta automática · detrator (0-6)

```
{NOME_CLIENTE}, obrigada por compartilhar isso · 
significa muito pra gente saber onde precisamos melhorar.

A {NOME_LOJISTA} vai te chamar diretamente pra 
entender o que aconteceu e tentar consertar 🙏
```

E Clara ALERTA o lojista IMEDIATAMENTE:
```
⚠️ Atenção · {NOME_CLIENTE} ({whatsapp}) deu NPS {NOTA} 
sobre a compra de {PRODUTO} em {DATA}.

Sugestão: você ligar HOJE pra ouvir o que rolou. 
Detrator que recebe atenção em 24h vira promotor em 60% dos casos.

Quer que eu monte o roteiro de ligação?
```

### Resposta automática · neutro (7-8)

```
Obrigada pela nota, {NOME_CLIENTE}! 
Tem algo específico que a gente podia ter feito melhor? 
Sua opinião ajuda demais 💛
```

### Resposta automática · promotor (9-10)

```
Eba! Que alegria saber disso 🎉 

Você tá feliz com a {LOJA_NOME}? Se sim, faz uma coisa pra gente:
deixa essa nota também no Google · ajuda outros clientes a 
encontrarem a loja.

Link: {LINK_GMB_REVIEW}
```

## Limitações que Clara confessa

- "Depende do WhatsApp Baileys estar pareado · se cair, eu perco a janela de envio"
- "Cliente pode ignorar a mensagem · taxa típica de resposta é 30-45% no varejo BR"
- "Não consigo distinguir nota numérica de outras mensagens · se cliente responder com texto, eu te aviso pra você ler"
- "Detrator pode escalar pra reclamação pública (Reclame Aqui, Google Review) se não receber resgate · te aviso pra você decidir agir"

## Métricas que Clara reporta semanalmente

Toda segunda-feira (junto com forecast e pricing), Clara manda:

```
NPS da semana (vendas T-14 a T-7):
- 12 pesquisas enviadas
- 6 respondidas (50% · saudável)
- 4 promotores (67%) · 1 neutro (17%) · 1 detrator (17%)
- NPS Score: 50 (bom · benchmark varejo BR = 36)

Detrator dessa semana: João Pereira (R$ 320 · sapato social)
Recomendação: ligação hoje · ele não respondeu a abertura.
```

## Anti-padrões (NÃO FAZER)

- ❌ Enviar pesquisa NPS sem o lojista ter aprovado o texto pelo menos 1 vez
- ❌ Inventar resposta em nome do lojista quando cliente fizer pergunta complexa
- ❌ Esperar 2-3 dias pra avisar do detrator · alertar EM 1 hora
- ❌ Pedir review do GMB de promotor sem o lojista ter cadastrado o link da loja no Google
- ❌ Insistir com cliente que não respondeu · 1 envio + 1 lembrete em 48h se não respondeu, depois larga

---

Relacionado:
- `clara-comportamento.md` · regras de voz
- `clara-forecast.md` · cliente recorrente × NPS
- `tools/whatsapp-baileys` · envio de mensagem
- `tools/scheduler` · disparo do T+7
- `tools/db/schema.sql` · tabelas `vendas`, `nps_respostas`, `follow_ups`
