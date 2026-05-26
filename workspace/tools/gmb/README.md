# gmb · Google Meu Negócio (Business Profile API)

Stub Clara para Google Business Profile · postar atualizações na ficha do GMB · listar e responder reviews automaticamente.

## Status

**STUB FUNCIONAL · não autenticado ainda.** Código pronto. Lojista precisa fazer OAuth no Google Cloud antes de Clara conseguir postar.

## Stack

- Python puro (stdlib · zero pip)
- Google Business Profile API (gratuita)

## Pré-requisitos do lojista (setup OAuth · 1x)

1. **Lojista tem ficha verificada no Google Meu Negócio** (sem isso, API não responde)
2. **Criar projeto no Google Cloud Console** (https://console.cloud.google.com)
3. **Ativar APIs**:
   - Business Profile API
   - My Business Account Management API
   - My Business Business Information API
4. **OAuth Consent Screen** configurado (External, scope `business.manage`)
5. **Solicitar acesso** à My Business API legacy (form Google · até 5 dias úteis): https://developers.google.com/my-business/content/prereqs
6. **Criar credencial OAuth Desktop App** e gerar refresh token (helper script · fornecemos no roadmap)
7. Salvar no `.env`:
   ```
   GMB_ACCESS_TOKEN=ya29...
   GMB_ACCOUNT_ID=accounts/123456789
   ```

(Access tokens expiram em 1h · refresh token vive · Clara renova automaticamente em integração final · stub atual só consome `GMB_ACCESS_TOKEN` direto)

## Uso

### Listar localizações da conta

```bash
python3 gmb.py list_locations
```

### Criar post na ficha (atualização)

```bash
python3 gmb.py create_post "accounts/123/locations/456" \
  "Promoção da semana · Claro 30GB R$ 54,90 · ativa aqui na loja"
```

Com imagem:
```bash
python3 gmb.py create_post "accounts/123/locations/456" \
  "Promoção da semana..." --image="https://cdn.exemplo.com/promo.png"
```

### Listar reviews

```bash
python3 gmb.py list_reviews "accounts/123/locations/456"
```

### Responder review

```bash
python3 gmb.py reply_review "accounts/123/locations/456/reviews/789" \
  "Valeu, fulano! Volta sempre na loja"
```

## Como Clara invoca

Quando o lojista pede "responde os reviews do Google":
1. Clara lista reviews recentes não-respondidos
2. Pra cada um, gera resposta no tom do lojista (Donna Paulsen + linguagem balcão)
3. Pede aprovação no Telegram ("vou responder assim · ok?")
4. Aprovado · executa `reply_review`

Quando lojista pede "publica essa promoção no Google também":
- Clara renderiza imagem (carousel-renderer)
- Sobe pro CDN
- Executa `create_post` com `--image=URL`

## Limitações conhecidas

- API GMB legacy é restrita · Google avalia caso a caso · aprovação até 5 dias úteis
- Cota: 50 posts/dia por location · 100 review-replies/dia
- Sem suporte direto a Stories/Reels do Google

## Anti-padrões

- Não usar API paga de terceiros (ex: BrightLocal · ZipReview) · Business Profile API gratuita resolve
- Não responder review com texto genérico ("obrigado!") · personaliza no nome e contexto
- Não pedir senha Google do lojista · OAuth resolve

## Roadmap

- [ ] Helper de refresh token automático (lib `google-auth` opcional)
- [ ] Detecção de "review com 1-3 estrelas" → escalar pra lojista (não responder automático)
- [ ] Stats agregados (avaliação média · número de reviews recebidas no mês)
