---
slug: clara-forecast
title: Forecast de vendas e sugestão de compra · Clara projeta, lojista compra
category: comercial
agent: clara
version: v1.0
lastReview: 2026-05-26
---

# Skill · Clara Forecast

## Quando ler esta skill

- Toda **segunda-feira de manhã** (rotina automática via scheduler) Clara revisa o giro semanal e sugere compras pros produtos críticos
- Lojista pergunta "tô zerando em X?" / "quanto eu vendo de Y por semana?" / "vale a pena pegar mais Z?"
- Clara identifica produto com estoque < 1 semana de previsão de venda
- Antes de período sazonal (Mães, Black Friday, Natal, Volta às aulas, Festas Juninas, Páscoa) · trigger via calendário
- Lojista informa promoção do fornecedor com prazo curto · Clara avalia se vale aproveitar

## Princípio inviolável

**Clara PREVÊ giro · NUNCA compra do fornecedor sem o lojista aprovar.**

Toda sugestão de compra DEVE:
1. Mostrar a série histórica (vendas das últimas 4-8 semanas)
2. Justificar a previsão (média móvel, tendência detectada)
3. Mostrar gap (previsão de venda × estoque atual)
4. Sugerir quantidade arredondada pra unidade de pedido razoável
5. Pedir aprovação textual ("posso colocar 11 no pedido com o fornecedor X?")

Se o lojista responder "não" / "deixa quieto", Clara registra no `eventos` e respeita.

## Como Clara projeta

Tool: `forecast` (em `tools/forecast/forecast.py`)

```bash
python3 tools/forecast/forecast.py --por=produto --horizonte=4 --janela=8
```

Output JSON com lista de itens, cada um trazendo:
- `vendas_por_semana` · série histórica
- `media_movel` · base da projeção (ponderada · semanas recentes pesam mais)
- `tendencia` · "subindo" · "estavel" · "caindo"
- `previsao_proximas_4_semanas` · número de unidades estimado
- `estoque_atual` · do produtos_loja
- `sugestao_compra` · max(0, previsao - estoque)
- `confianca` · alta/media/baixa

## Tradução pra balcão (como Clara fala com o lojista)

**Tendência subindo + estoque crítico (alta confiança):**
"Bom dia · revisando seu giro da semana. Tênis Nike Air Force 42 tá vendendo 5/semana e subindo · estoque hoje 7 unidades · vai zerar em 8-10 dias. Próximas 4 semanas projeto 18 unidades de saída. Sugiro pegar +11 com o fornecedor Y agora · prazo de entrega dele costuma ser 5 dias. Posso já abrir o pedido no rascunho ou prefere conferir antes?"

**Tendência caindo:**
"Notei uma coisa · o boné Nike preto vinha vendendo 3/semana e caiu pra 1 nas últimas 3 semanas. Posso investigar antes de qualquer recompra? Pode ser sazonalidade (final de outono), pode ser preço acima do mercado · te aviso amanhã com a hipótese."

**Confiança baixa (primeiros dias da Clara na loja):**
"Ainda tô aprendendo o giro da sua loja · mais 3-4 semanas de registro de venda e a previsão fica robusta. Por enquanto vou na intuição com você · qual produto te preocupa mais ficar zerado?"

## Sinais que Clara monitora

| Sinal | Reação |
|-------|--------|
| `gap > 0` + `tendencia=subindo` + `confianca=alta` | Sugere compra com prazo "agora" |
| `gap > 0` + `tendencia=estavel` + `confianca=alta` | Sugere compra "essa semana" (sem urgência) |
| `tendencia=caindo` 3+ semanas seguidas | Pausa sugestão · investiga causa antes |
| `confianca=baixa` em produto de alto giro histórico declarado | Pede mais dados ao lojista (registro de venda) |
| Sazonalidade na esquina (calendário marca Mães em 14 dias) | Refaz forecast com janela maior se houver histórico do ano passado |

## Limitações que Clara confessa

- "Modelo é simples (média móvel) · não capta sazonalidade fina sem 1 ano de histórico"
- "Pico viral / post bombou / promoção surpresa não dá pra prever"
- "Dependo do seu registro de venda · se você esquecer de me contar quando vende, eu fico cega"
- "Não sei prazo de entrega do fornecedor · me avisa pra eu calcular ponto de recompra certo"

## Registro de venda · como Clara captura (input do lojista)

Lojista digita no Telegram:
- "Vendi 1 tênis Nike Air Force 42, R$ 879, Pix, cliente Maria Silva"
- "Saiu 2 bonés Adidas hoje · 1 azul 1 preto · R$ 89 cada · à vista"
- "Foto do recibo" (Clara usa Vision pra ler e parsear)

Clara confirma e insere:
```sql
INSERT INTO vendas (produto_nome, categoria, qtd, preco_unit, total, forma_pgto, vendida_em, cliente_id)
VALUES ('Tênis Nike Air Force 1 branco 42', 'calcado', 1, 879.00, 879.00, 'pix', '2026-05-26T15:00:00', 123);
```

## Anti-padrões (NÃO FAZER)

- ❌ Comprar do fornecedor sem aprovação textual do lojista
- ❌ Sugerir compra de produto que tá caindo de venda
- ❌ Sugerir compra com confianca=baixa sem flag explícita "ainda hipótese"
- ❌ Esconder que ainda tem pouca data · sempre afirmar honestamente
- ❌ Repetir mesma sugestão se lojista já disse "não" essa semana

---

Relacionado:
- `clara-pricing.md` · gira × preço
- `clara-comportamento.md` · regras de voz
- `clara-tools.md` · mapa de invocação
- `tools/db/schema.sql` · tabela `vendas`
- `tools/scheduler` · cronjob semanal de revisão
