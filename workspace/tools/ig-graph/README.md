# ig-graph

Stub Clara para Instagram Graph API (publicar foto · publicar carrossel · insights).

## Status

**STUB FUNCIONAL · não autenticado.** Código pronto. Lojista precisa rodar setup OAuth 1x antes de Clara conseguir postar.

## Stack

- Python puro (stdlib · zero pip)
- Instagram Graph API v21.0 (gratuita pra Business/Creator)

## Pré-requisitos do lojista (setup OAuth · 1x)

1. **Conta Instagram precisa ser Business ou Creator** (não pode ser pessoal)
2. **IG vinculado a uma Facebook Page** (configuração no app IG do celular)
3. **Facebook Developer App** criado em https://developers.facebook.com
   - Adicionar produto "Instagram Graph API"
   - Pedir permissões: `instagram_basic`, `instagram_content_publish`, `pages_show_list`, `pages_read_engagement`
4. **Page Access Token** (long-lived · 60 dias)
   - https://developers.facebook.com/tools/explorer
   - Pegar User Token → trocar por Page Token → trocar por long-lived
5. Salvar no `.env` do lojista:
   ```
   IG_USER_ID=17841400000000000
   IG_ACCESS_TOKEN=EAAB...
   ```

Setup detalhado: https://developers.facebook.com/docs/instagram-api/getting-started

## Uso

### Publicar foto

```bash
python3 ig.py publish_photo "https://cdn.exemplo.com/promo.png" "Promoção 30GB · R$ 54,90"
```

### Publicar carrossel (até 10 imagens)

```bash
python3 ig.py publish_carousel \
  "https://cdn.exemplo.com/slide-1.png" \
  "https://cdn.exemplo.com/slide-2.png" \
  "https://cdn.exemplo.com/slide-3.png" \
  "Promoção Claro · arrasta pra ver os detalhes"
```

(Último arg = caption · antes = URLs das imagens)

### Pegar insights de um post

```bash
python3 ig.py insights 17895695668004551
```

Saída: impressões, alcance, salvamentos, likes, comentários, compartilhamentos.

## Limitação: imagens precisam estar em URL pública

Instagram Graph API exige `image_url` pública (HTTPS · acessível pelo CDN da Meta). Local PNG do `carousel-renderer` precisa subir antes:

**Opções gratuitas:**
- **Cloudflare R2** (10GB free · zero egress)
- **GitHub Pages** (estático · publica raw imagens)
- **Imgur** (free · sem conta · URL direta)
- **VPS do lojista** + Nginx (servir `/opt/clones/clara/workspace/cdn/`)

Clara vai precisar de uma sub-tool "upload-cdn" no futuro (não bloqueia hoje · prioridade 2).

## Como Clara invoca

Quando lojista pede "publica esse carrossel no meu Insta":
1. Clara já renderizou os 6 PNGs via `carousel-renderer`
2. Sobe PNGs pro CDN do lojista (ex: nginx local)
3. Executa `python3 ig.py publish_carousel <url1> <url2> ... "<caption>"`
4. Reporta `media_id` pro lojista e salva no DB (`posts_agendados.posted_media_id`)

## Anti-padrões

- Não usar Instagram pessoal (API não suporta · só Business/Creator)
- Não pedir senha do Instagram do lojista (OAuth resolve · não armazenar credencial em texto)
- Não burlar rate limits (200 posts/hora · 25 carrosséis/dia · banimento fácil)
