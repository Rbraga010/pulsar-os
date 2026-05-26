# websearch

Pesquisa na web e devolve os top resultados (título · URL · snippet). Clara usa quando o lojista pergunta algo factual ("qual o horário do Banco do Brasil em Sorocaba?", "concorrência local de gás tá com qual preço?") ou pra checar uma notícia rápida.

## Stack

- Python 3
- **Default GRÁTIS · DuckDuckGo HTML scrape** · `requests` + `beautifulsoup4` · sem API key · sem cadastro
- **Alternativa · Brave Search API** · grátis até 2k requests/mês · relevância melhor

## Custo

- DuckDuckGo · ZERO. Funciona out-of-the-box.
- Brave Search · grátis até 2k buscas/mês (suficiente pra uma loja)

## Pré-requisito

DuckDuckGo: nenhum.

Brave (opcional · só se dono quiser melhor relevância):
- `BRAVE_SEARCH_API_KEY` no `.env`
- Skill `clara-tools-setup.md` ensina o passo a passo (5 min · grátis)

## Setup (1ª vez)

```bash
pip install --user requests beautifulsoup4
```

## Uso

```bash
python3 tools/websearch/search.py "<query>" [--engine=ddg|brave] [--limit=5]
```

### Exemplo

```bash
python3 tools/websearch/search.py "preço médio botijão gás Sorocaba 2026" --limit=5
```

Saída no `stdout`: JSON.

```json
[
  {
    "title": "Preço do gás em Sorocaba · ANP",
    "url": "https://...",
    "snippet": "O preço médio do botijão..."
  }
]
```

## Como Clara invoca (interno)

```bash
results=$(python3 /opt/clones/clara/workspace/tools/websearch/search.py \
  "promoção Claro Sorocaba" \
  --limit=3)

# parse JSON e usa no contexto
echo "$results" | jq -r '.[].title'
```

## Anti-padrões

- Não usar pra notícia financeira sensível · DDG é raspagem · pode ficar defasado
- Não usar como única fonte · cruzar com 2 buscas se a info é decisão de vendas
- Não passar query > 200 caracteres · DDG corta resultado
- Não buscar info pessoal de cliente · Clara é sócia, não detetive

## Fallback

Se DDG retorna lista vazia (raspagem quebrou · DDG mudou HTML), Clara avisa o lojista honestamente:

> Cara · a busca rápida não trouxe nada útil. Quer que eu tente com outra palavra?

E se o dono já tem Brave configurada, Clara muda pra `--engine=brave` automático.

## Troubleshooting

- "ModuleNotFoundError: bs4" · roda `pip install --user beautifulsoup4`
- DDG retorna lista vazia · provável mudança no HTML deles · ajustar selector `div.result` no script
- Brave HTTP 401 · key inválida ou expirada · refazer em https://api.search.brave.com/app/keys
