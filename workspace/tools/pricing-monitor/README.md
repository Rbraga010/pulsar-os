# pricing-monitor

Sensor de preço de mercado. Clara usa pra apoiar o lojista a tomar decisão de preço · NUNCA muda preço sozinha · sempre sugere e pede aprovação.

## Stack

- Python 3 (sem dependências externas · usa só stdlib)
- Tool `websearch` (DuckDuckGo grátis · default)
- Heurística regex pra extrair "R$ X,YZ" de snippets

## Custo

Zero (DuckDuckGo público · sem API key).

## Uso

```bash
python3 tools/pricing-monitor/monitor.py "tênis nike air force 1 branco 42" --cidade=Sorocaba
```

Saída (1 linha JSON):

```json
{
  "produto": "tênis nike air force 1 branco 42",
  "fontes": [{"loja": "centauro", "preco": 899.90, "url": "...", "titulo": "..."}],
  "preco_mediano": 879.90,
  "preco_minimo": 799.90,
  "preco_maximo": 999.90,
  "sugestao": 879.90,
  "confianca": "alta",
  "n_fontes": 5
}
```

Confiança:
- `alta` · 5+ fontes
- `media` · 2-4 fontes
- `baixa` · 0-1 fonte (Clara avisa o dono "ainda não consegui sentir o mercado · me dá os 2-3 concorrentes que mais te preocupam que eu monitoro semanal")

## Como Clara usa

Skill `clara-pricing.md` ensina:
1. Lojista pede: "como tá o preço do tênis Nike Air Force 42 lá fora?"
2. Clara invoca `pricing-monitor` com a descrição do produto + cidade
3. Lê o JSON · interpreta confiança · responde em PT-BR balcão:
   - "Vi 5 lojas online · preço mediano R$ 879,90 · você tá em R$ 920 · 4,5% acima · margem ainda safe?"
4. NUNCA executa alteração de preço · só sugere

## Limitações honestas (Clara avisa o lojista)

- Preço pode vir de marketplace (ML/Shopee) que tem variação alta · não compara igual loja física local
- Sem informação de estoque ou frete embutido no preço
- Loja física vizinha (mesmo bairro) não aparece no websearch · pra isso vale OCR de panfleto da concorrência (tool `ocr-panfleto`)

## Próximos passos (roadmap V2)

- Integração com PriceLab / Precifica (pago) pra quem topar
- Scrape direto de ML/Shopee/Amazon via API oficial
- Histórico de preço (serie temporal) salvo no SQLite
