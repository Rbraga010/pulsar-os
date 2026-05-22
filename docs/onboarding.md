# Pulsar OS · Guia de onboarding

Voce instalou. Agora o que fazer?

## 1. Teste o bot Telegram

Manda `/start` para o bot que voce configurou. Se a Clara nao responder em 10s, veja logs:

```bash
tail -f /opt/pulsar-os/bot/logs/bot.log
systemctl status pulsar-os-clara-bot.service
```

Se o bot esta rodando mas Clara nao responde, a sessao Claude/Codex pode nao estar ativa. Reinicie:

```bash
systemctl restart pulsar-os-clara-bot.service
```

## 2. Conheca a Clara

A Clara e sua orquestradora. Voce pode pedir qualquer coisa relacionada a sua loja Claro:

- "Cria um post pra venda da semana"
- "Configura o site da loja"
- "Atende esse cliente que entrou pelo WhatsApp" (cola o texto)
- "Faz calendario editorial pro mes que vem"
- "Liga pra esse lead: <telefone>"

Ela decide se faz sozinha ou delega pro **Dev**, **Marketing** ou **Comercial**.

## 3. Personalize as Souls

As personalidades dos 4 agentes estao em texto markdown · voce edita direto.

```bash
nano /opt/pulsar-os/workspace/cerebro/agents/clara.md
nano /opt/pulsar-os/workspace/cerebro/agents/comercial.md
nano /opt/pulsar-os/workspace/cerebro/agents/marketing.md
nano /opt/pulsar-os/workspace/cerebro/agents/dev.md
```

Sugestoes do que customizar:
- Nome da loja
- Cidade onde atua
- Tom de voz mais formal ou mais informal
- Especialidades extras (ex: "vendemos celulares fisicos tambem")

## 4. Adicione conhecimento Claro

Crie a pasta `workspace/knowledge/claro/` e cole documentos:

```bash
mkdir -p /opt/pulsar-os/workspace/knowledge/claro
cd /opt/pulsar-os/workspace/knowledge/claro
# Cole aqui: planos.md, cobertura.md, scripts-atendimento.md, etc
```

A Clara, Comercial e Marketing leem essa pasta automaticamente.

## 5. Atualize a skill de planos Claro

Quando voce receber os documentos oficiais do Rodrigo Braga, atualize:

```bash
nano /opt/pulsar-os/workspace/cerebro/skills/comercial-planos-claro.md
```

Substitua o placeholder pelos planos reais. O Comercial vai usar essa skill em todo atendimento.

## 6. Conecte WhatsApp (opcional · proximas versoes)

Em v0.2.0 sera disponivel integracao WhatsApp via Z-API ou Twilio. Por enquanto, copie/cole conversas no Telegram.

## 7. Site da loja (opcional)

Peca pra Clara: "Faz um site simples pra loja"

Ela delega pro Dev, que cria um Next.js com:
- Landing page
- Formulario WhatsApp
- Localizacao + horario
- Plano destaque

Deploy automatico via Vercel (precisa conta gratuita).

## 8. Marketing automatico (opcional · proximas versoes)

Em v0.3.0 sera disponivel integracao com Instagram Graph API para postagem programada.

## Comandos uteis

```bash
# Status do bot
systemctl status pulsar-os-clara-bot.service

# Reiniciar bot
systemctl restart pulsar-os-clara-bot.service

# Logs em tempo real
tail -f /opt/pulsar-os/bot/logs/bot.log

# Ver mensagens pendentes
ls /opt/pulsar-os/bot/inbox/

# Ver respostas a enviar
ls /opt/pulsar-os/bot/outbox/

# Ver histórico envios
ls /opt/pulsar-os/bot/sent/ | tail -20

# Postgres (se instalou)
docker logs pulsar-os-db
docker exec -it pulsar-os-db psql -U pulsar -d pulsar_os
```

## Problemas comuns

### Bot nao responde
1. `systemctl status pulsar-os-clara-bot.service` · esta rodando?
2. `tail -50 /opt/pulsar-os/bot/logs/bot.log` · algum erro?
3. Token Telegram esta certo em `bot/.env`?

### Clara responde mas erra muito
- Provavelmente Soul desconfigurada. Verifica `workspace/cerebro/agents/clara.md` e adiciona contexto da sua loja.

### Comercial fala de planos que nao existem
- Skill `comercial-planos-claro.md` ainda esta com placeholder. Atualize com docs reais.

### Postgres nao conecta
- Verifica se o container ta UP: `docker ps | grep pulsar-os-db`
- Logs: `docker logs pulsar-os-db`

## Suporte

- GitHub Issues: https://github.com/Rbraga010/pulsar-os/issues
- Email: rodrigo@pulsarh.com.br
- Telegram group: (em breve)
