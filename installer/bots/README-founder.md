# Pulsar OS — Bots Wizard (Founder, 1 pagina)

Voce ja rodou o `install.sh` (Iniciativa 4a) e tem Postgres, repo e Vercel de pe. Falta o Telegram. E aqui que voce entra — @BotFather nao tem API publica, voce precisa criar os bots na mao. Eu te guio.

## 3 comandos

```bash
pulsar-os bots-wizard          # cria bots no @BotFather, valida tokens, salva seguro
pulsar-os smoke                # captura seu chat_id + dispara primeira mensagem do Pulse
pulsar-os onboarding-resume    # se interrompeu a entrevista, retoma de onde parou
```

Equivalente direto (se `pulsar-os` nao estiver no PATH):

```bash
bash installer/bots/wizard.sh
bash installer/smoke/first-message.sh
bash installer/smoke/validate.sh   # checklist pos-smoke
```

## O que voce precisa em maos

- Telegram aberto (celular ou desktop)
- 4 minutos
- Atencao no que o wizard pedir (ele guia)

## FAQ

### E se eu errar o token?

Cola de novo. O wizard valida em `api.telegram.org/getMe`. Se nao bater, ele te avisa "token nao valida" e pede de novo. Sem drama.

### E se @BotFather travar / nao responder?

Acontece em horario de pico. Aguarda 30s e manda `/newbot` de novo. Se persistir, fecha e reabre o Telegram. Se ainda nao funcionar, espera 5min — algo do lado deles.

### Como deletar um bot e recomecar?

No @BotFather: `/deletebot` → escolhe o bot → confirma com texto exato `Yes, I am totally sure.` → bot some. Depois roda `bash installer/bots/wizard.sh` de novo.

### Como gerar tokens em conta de cliente diferente da minha?

Voce tem duas opcoes:

1. **Recomendado:** o cliente cria os bots na conta dele (no Telegram dele) e te passa os tokens via canal seguro (1Password, Bitwarden, mensagem efemera). O wizard so cola os tokens — nao importa quem criou.
2. **Voce cria pra ele:** abre Telegram com o numero do cliente (ou cria conta dedicada), passa pelo @BotFather, depois transfere com `/transferownership` se precisar. Mais trabalho, menos comum.

Em ambos casos: tokens ficam em `tenant/.env.local` (perm 0600) na VPS do cliente, nunca commitados.

### Onde meus tokens ficam salvos?

`tenant/.env.local` na VPS. Permissao 0600 (so root le). Esta no `.gitignore` — nunca vai pro repositorio. Tambem propagado pra `~/.claude/config.json` no nó MCP `plugin:telegram:telegram`.

### Posso rodar o wizard 2x?

Sim, idempotente. Ele detecta tokens ja validados e pula direto pro smoke. So vai te pedir tokens de novo se algum deles invalidar (ex: voce revogou via @BotFather `/revoke`).

### O smoke nao captura meu chat_id

O wizard polla `getUpdates` por 60s aguardando voce mandar `/start` no @<seu_pulse_bot>. Se voce demorar mais que isso, ele encerra. Manda `/start` e roda `bash installer/smoke/first-message.sh` de novo — desta vez ele captura na hora.

### Pulse mandou a primeira mensagem mas nao continua

Voce respondeu? Pulse so avanca quando ve resposta sua. Se respondeu e ele travou, roda `bash installer/smoke/validate.sh` pra ver onde quebrou (token? chat_id? MCP?). Resultado aponta o problema.

### Erro: "jq: command not found"

`apt install -y jq` (Ubuntu/Debian) ou `brew install jq` (mac). Pre-requisito do wizard.

### Erro: "curl: (7) Failed to connect"

Sem internet ou firewall. Checa: `curl -fsS https://api.telegram.org/`. Se 403/timeout, libera saida pra `api.telegram.org:443` no firewall da VPS.

## Troubleshooting express

| Sintoma | Acao |
|---|---|
| Token valida mas mensagem nao chega | Voce mandou /start no bot? Sem isso Telegram nao deixa o bot te falar. |
| Wizard pede tokens de novo na 2a rodada | Token foi revogado (@BotFather `/revoke`). Cria novo bot ou gera novo token. |
| `validate.sh` falha em "MCP telegram" | Reabre Claude Code. Config so carrega no boot. |
| `validate.sh` falha em "chat_id" | Roda `first-message.sh` ate o fim. |

## O que vem depois

Quando smoke passa: Pulse te entrevista (12 perguntas, 5min), depois Falconi renderiza `CLAUDE.md` + `agents-config.json` baseado nas suas respostas. Final: equipe digital apresentada e primeira missao priorizada. Iniciativa 3 do Pulsar OS cuida disso ponta-a-ponta.
