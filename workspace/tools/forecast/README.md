# forecast

Projeção de vendas dos próximos N períodos baseado no histórico real do CRM da Clara.

## Stack

- Python 3 stdlib pura (sem pandas/numpy · zero dependência)
- SQLite local · tabela `vendas` (schema.sql)
- Média móvel ponderada (peso maior pras semanas mais recentes)

## Custo

Zero · roda local.

## Pré-requisito

Lojista precisa REGISTRAR VENDAS na tabela `vendas` do SQLite. Clara facilita isso · quando o lojista digita "vendi tênis Nike Air Force, R$ 879, Pix, cliente Maria", ela insere via `db/query.py`. Sem dado, sem forecast (claro).

## Uso

```bash
# por produto · próximas 4 semanas
python3 tools/forecast/forecast.py --por=produto --horizonte=4

# por categoria · próximas 8 semanas
python3 tools/forecast/forecast.py --por=categoria --horizonte=8 --janela=12
```

## Output (1 linha JSON)

```json
{
  "ok": true,
  "janela_historica_semanas": 8,
  "horizonte_semanas": 4,
  "itens": [
    {
      "chave": "Tênis Nike Air Force 1 branco 42",
      "vendas_por_semana": [3, 2, 4, 5, 3, 4, 6, 5],
      "media_movel": 4.5,
      "tendencia": "subindo",
      "previsao_proximas_4_semanas": 18.0,
      "estoque_atual": 7,
      "sugestao_compra": 11,
      "confianca": "alta"
    }
  ]
}
```

## Confiança

- `alta` · 6+ semanas com venda
- `media` · 3-5 semanas
- `baixa` · 0-2 semanas (Clara avisa "ainda tô aprendendo seu giro · me dá mais 3-4 semanas")

## Como Clara usa

Skill `clara-forecast.md` ensina:
1. Toda segunda-feira de manhã (cronjob via scheduler), Clara roda forecast automaticamente
2. Se algum produto tem `gap > 0` E `tendencia=subindo` E `confianca=alta`, Clara manda:
   - "Bom dia · revisando o giro semanal. Tênis Nike Air Force 42 tá vendendo 5/semana subindo · estoque hoje 7 · vai zerar em 8-10 dias. Sugiro comprar +11 unidades agora pra não ficar sem na próxima 2 semanas. Posto a sugestão no carrinho do fornecedor X ou prefere conferir antes?"
3. **NUNCA executa compra · só sugere e pede aprovação**

## Limitações honestas (Clara avisa o lojista)

- Modelo simples (média móvel ponderada) · não considera sazonalidade explícita (Natal, dia das mães)
- Precisa mínimo 3 semanas de dados pra confiança subir
- Eventos pontuais (campanha viral, post bombou) não previsíveis
- Não considera evento de fornecedor (promoção, prazo de entrega)

## Próximos passos (roadmap V2)

- Modelo Prophet (Meta) ou ARIMA pra sazonalidade
- Integração com Linx/Bling/Tiny pra puxar venda automaticamente
- Alerta no Telegram quando produto entra em zona crítica (estoque < 1 semana de previsão)
