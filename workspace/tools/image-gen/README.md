# image-gen

Gera imagem realista (ou estilizada) a partir de prompt de texto. Clara usa quando o lojista pede "cria uma foto pra eu postar", "faz um visual de capa", "imagina um cenário X". Modelo: **Imagen 4** do Google AI Studio.

## Stack

- Node.js (.mjs · sem dependências externas · usa `fetch` nativo)
- Modelo `imagen-4.0-generate-001` via Google Generative Language API
- Saída PNG salva em `data/images/{timestamp}.png`

## Custo

Grátis dentro da quota do Google AI Studio (tier gratuito generoso · ~1000 imagens/mês). Se estourar, retorna HTTP 429 com mensagem clara.

## Pré-requisito

Dono fornece `GOOGLE_AI_API_KEY` no `.env` da workspace. Pega em https://aistudio.google.com/apikey (1 minuto · gratuita).

Skill `clara-tools-setup.md` ensina o passo a passo.

## Uso

```bash
node tools/image-gen/generate.mjs "<prompt>" [--aspect=1:1|3:4|4:5|9:16] [--out=path.png]
```

Aspectos aceitos: `1:1`, `3:4`, `4:5`, `9:16`, `4:3`, `16:9`.

### Exemplo

```bash
node tools/image-gen/generate.mjs \
  "Foto editorial de uma vitrine de loja de bairro em Sorocaba, iluminação morna, sem texto, sem logos" \
  --aspect=3:4 \
  --out=/tmp/clara-vitrine.png
```

Saída no `stdout`: o path do PNG (1 linha · pra Clara consumir direto). Logs vão pro `stderr`.

## Como Clara invoca (interno)

```bash
out=$(node /opt/clones/clara/workspace/tools/image-gen/generate.mjs \
  "Foto realista de uma família tomando café da manhã, luz quente" \
  --aspect=4:5 \
  --out=/tmp/clara-img-${session}.png)

if [ $? -eq 0 ]; then
  # manda o PNG no Telegram via reply tool
  echo "imagem em $out"
fi
```

## Se key ausente

Tool sai com `exit 2` e imprime no stderr:

> Pra gerar imagem com IA preciso da chave Google AI Studio. Pega em https://aistudio.google.com/apikey (gratuita), me passa que eu plugo.

Clara repassa essa mensagem pro lojista (na voz dela) e PARA · não tenta improvisar.

## Anti-padrões

- Não pedir "imagem com texto escrito 'PROMOÇÃO'" · Imagen erra texto na imagem · usar o carousel-renderer pra texto
- Não gerar foto de pessoa específica · só descrição genérica (Imagen não copia rosto · vai sair errado)
- Não usar pra logo · usa designer humano ou Canva grátis
- Se quota acabar (HTTP 429) · esperar 1 minuto · ou pedir pro dono ativar billing no Google AI Studio

## Fallback se quota acabar

Mensagem honesta pro lojista:

> A cota de imagem do dia bateu. Volta em alguns minutos ou, se quiser, ligamos a versão paga (ainda baratinho · centavos por imagem).

## Troubleshooting

- HTTP 400/403 · chave inválida ou Imagen não habilitado no projeto · refazer key
- HTTP 429 · quota estourada · esperar ou ativar billing
- "Resposta sem bytesBase64Encoded" · resposta da API mudou · ler `j` no log e ajustar parser
