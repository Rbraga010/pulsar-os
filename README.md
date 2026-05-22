# Pulsar OS

Estrutura agentica para lojistas Claro · 4 agentes (Clara orquestradora + Dev + Marketing + Comercial) que rodam na sua VPS, gerenciados via Telegram.

## O que e

Voce e lojista Claro. Hoje voce vende plano no balcao. Quer vender mais, atender melhor, ter conteudo automatico no Instagram e nunca perder lead no WhatsApp. Pulsar OS faz isso.

- **Clara** · seu braco direito · recebe tudo via Telegram e delega
- **Dev** · faz site, sistema, automacao
- **Marketing** · cria post, copy, calendario
- **Comercial** · atende cliente, qualifica via SPIN, fecha plano Claro

## Quanto custa

Voce paga **uma vez** pelo produto (Pulsar OS · estrutura). Depois roda na **sua VPS**, usando **sua conta Claude OU Codex**. Sem mensalidade nossa. Sem dependencia.

## Como instalar

### Pre-requisitos
- VPS Linux (Ubuntu 22.04 recomendado · qualquer com 2GB RAM)
- Conta Claude Code (Anthropic) OU Codex (OpenAI)
- Bot Telegram (criar gratis em `@BotFather`)
- Acesso root na VPS

### Passo a passo

```bash
# 1. Conecte na sua VPS
ssh root@SEU-IP

# 2. Clone o repositorio
git clone https://github.com/Rbraga010/pulsar-os.git
cd pulsar-os

# 3. Rode o wizard
sudo ./setup-pulsar-os.sh
```

O wizard pergunta:
- Caminho de instalacao (default `/opt/pulsar-os`)
- Provider AI (Anthropic ou OpenAI)
- Token Telegram (opcional · pode configurar depois)
- Seu email e nome (commits git)
- Dominio Vercel (opcional)

Depois disso, voce manda `/start` no bot Telegram e a Clara responde.

## Estrutura de pastas (apos instalar)

```
/opt/pulsar-os/
├── bot/                       # Bot Telegram (Python, sempre rodando)
│   ├── inbox/                 # Mensagens recebidas
│   ├── outbox/                # Respostas a enviar
│   ├── sent/                  # Historico envios
│   ├── logs/
│   └── .env                   # Tokens (NUNCA commit)
├── workspace/
│   ├── cerebro/
│   │   ├── agents/            # Souls dos 4 agentes
│   │   │   ├── clara.md
│   │   │   ├── dev.md
│   │   │   ├── marketing.md
│   │   │   └── comercial.md
│   │   ├── skills/            # Conhecimento especifico
│   │   ├── memory/            # Memoria persistente
│   ├── knowledge/             # Documentos da sua loja
│   └── projetos/              # Output (sites · scripts · etc)
└── logs/
```

## Configurando depois da instalacao

### Mudar tom da Clara
Edite `workspace/cerebro/agents/clara.md`

### Adicionar conhecimento Claro (planos · cobertura · processos)
Cole docs em `workspace/knowledge/claro/`

### Customizar SPIN do Comercial
Edite `workspace/cerebro/skills/comercial-spin.md`

## Suporte

- Documentacao: [docs/onboarding.md](docs/onboarding.md)
- Comunidade: (em breve · Telegram group)
- Issues no GitHub

## Privacidade

- Voce roda na **sua VPS** · ningum tem acesso aos seus dados
- Mandamos UM heartbeat anonimo por dia (apenas install ID + versao) para acompanhar quantas instalacoes existem
- Voce pode desativar removendo o cron job: `crontab -e` e apagar a linha com `pulsar-os/heartbeat`

## Licenca

Proprietaria comercial · ver [LICENSE.md](LICENSE.md). Voce pode usar e customizar localmente. Nao pode redistribuir o produto.
