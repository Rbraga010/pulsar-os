# google-workspace

Calendar + Gmail da conta Google do dono. Clara consulta agenda, cria evento e envia email · tudo via OAuth de 5 minutos · 1 vez só.

## Stack

- Python 3 · `google-auth-oauthlib` · `google-api-python-client`
- OAuth 2.0 (token salvo em `data/google-token.pickle`)
- Scopes:
  - `https://www.googleapis.com/auth/calendar`
  - `https://www.googleapis.com/auth/gmail.send`

## Custo

Zero. API gratuita do Google · sem limite prático pra uso de uma loja.

## Pré-requisito

1. Dono cria projeto OAuth no Google Cloud Console (5 min · grátis)
2. Baixa o JSON do OAuth Client e salva em `data/google-oauth-client.json`
3. Roda `python3 tools/google-workspace/setup.py` 1x · autoriza no browser · token fica salvo

Skill `clara-tools-setup.md` ensina o passo a passo.

## Setup (1ª vez)

```bash
# 1. instala libs
pip install --user google-auth-oauthlib google-api-python-client

# 2. coloca o client secret em data/google-oauth-client.json
# (dono baixa do Google Cloud Console)

# 3. roda OAuth 1x
python3 tools/google-workspace/setup.py
# segue o link · autoriza · token salvo em data/google-token.pickle
```

Daqui em diante Clara opera direto · sem reautorizar (refresh token cuida).

## Uso

### Calendar

```bash
# listar próximos eventos
python3 tools/google-workspace/calendar.py list_events --max=10

# criar evento (assume BRT se sem timezone)
python3 tools/google-workspace/calendar.py create_event \
  --title="Reunião fornecedor Claro" \
  --start="2026-05-25T14:00" \
  --duration=60 \
  --description="Pauta · novo plano controle" \
  --location="Av Paulista 1000"
```

### Gmail

```bash
python3 tools/google-workspace/gmail.py send_email \
  --to=fornecedor@x.com \
  --subject="Pedido de proposta" \
  --body="Oi · gostaria de receber a tabela atualizada · obrigado, João"
```

## Como Clara invoca (interno)

```bash
# lojista: "agenda reunião com o Pedro amanhã 9h"
python3 /opt/clones/clara/workspace/tools/google-workspace/calendar.py create_event \
  --title="Reunião Pedro" \
  --start="$(date -d 'tomorrow 09:00' -Iseconds)" \
  --duration=60

# lojista: "manda email pro contador pedindo o boleto"
python3 /opt/clones/clara/workspace/tools/google-workspace/gmail.py send_email \
  --to="$contador_email" \
  --subject="Boleto INSS" \
  --body="Oi · pode me mandar o boleto do INSS deste mês? Obrigado · João"
```

## Se OAuth não rodou ainda

Tools saem com `exit 2` e imprimem:

> OAuth Google não rodou ainda. Roda 1x:
>   python3 tools/google-workspace/setup.py
> Depois Clara pode mexer em agenda e enviar email.

Clara repassa pro lojista e oferece guiar o setup.

## Anti-padrões

- Não enviar email em massa via Gmail · cota diária da conta pessoal é ~500/dia · pra disparo usa serviço apartado
- Não criar evento sem confirmar com o lojista · agenda é território dele
- Não usar Gmail pra phishing-like (responder pelo lojista a clientes sem aprovação)
- Não esconder evento criado · sempre mandar o `htmlLink` pro lojista conferir
- Não pedir mais scopes do que precisa (não pede `gmail.modify` · só `gmail.send`)

## Anti-anti-padrão (Clara faz)

- Sempre joga BRT default · maioria dos lojistas brasileiros vive em UTC-3
- Confirma horário antes de criar evento · "Beleza, amanhã 9h da manhã, 1 hora · pode bloquear?"
- Quando recebe `403 insufficient permissions`, avisa que o scope precisa ser refeito · não silencia o erro

## Troubleshooting

- `exit 2 · OAuth não rodou` · faltou rodar `setup.py`
- `403 insufficient_permissions` · scope mudou · refazer setup
- `RefreshError` · refresh token revogado pelo dono ou app GCP em modo test expirou · refazer setup
- Token expira em modo "Testing" do GCP a cada 7 dias · dono precisa publicar app pra estabilizar (ou aceitar reauth semanal)
