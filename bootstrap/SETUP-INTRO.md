# Pulsar OS — antes de colar o prompt

Voce baixou o zip, descompactou e abriu o Claude Code. Antes de colar o PROMPT.md, leia esta pagina. Demora 2 minutos.

## O que vai acontecer quando voce colar o prompt

1. **Pulse vai entrar no seu Telegram via Bot.** A conversa de onboarding inteira acontece la, nao na janela do Claude Code. Se voce ainda nao parou tudo pra olhar o celular, pare agora.

2. **12 perguntas em 8 a 10 minutos.** Empresa, dominio, founder, ICP, produto, time, voz, URLs, foco de inteligencia, email Git, dor atual, e uma pergunta opcional sobre personalizar a inspiracao do time.

3. **Sem chute, sem invencao.** Se voce nao sabe responder algo (ex: "minha bio em 3 linhas"), manda `/skip` — slot fica em branco e a Donna te cobra em 24 horas. Pulse NUNCA inventa nada sobre voce.

4. **Pode pausar quando quiser.** Manda `/pausa` no Telegram. Quando voltar, cole o `PROMPT-modo-retomada.md` e ele continua exatamente de onde parou.

5. **Ao final do ritual:**
   - Pulse renderiza o `CLAUDE.md` da sua casa (com sua empresa, ICP, voz, time)
   - Te apresenta os 8 agentes oficiais e os 22 heads
   - Le a dor que voce declarou e propoe a primeira missao concreta com prazo de 7 a 21 dias

## O que NAO vai acontecer

- Pulse nao vai te pedir senha, CNPJ, dados bancarios. Nada disso entra no onboarding — fica pra ritual financeiro com Dalio depois.
- Pulse nao vai fazer commit nem deploy nesta fase. So escreve arquivos em `/tenant/`.
- Pulse nao vai te apresentar 30 personas de uma vez. Voce conhece o time aos poucos.

## Se algo der errado

- **Pulse nao apareceu no Telegram em 30s:** confira se o bot esta pareado. Rode `/telegram:access` no terminal e siga o fluxo.
- **Pulse mandou mensagem estranha ou parou no meio:** cole `PROMPT-modo-retomada.md` no Claude Code. Ele le o que ja foi respondido e segue de onde parou.
- **Voce quer recomecar do zero:** apague `/tenant/onboarding-answers.json` e cole `PROMPT.md` de novo. Vai do P1.

## Checklist antes de colar

- [ ] Telegram aberto no celular ou desktop
- [ ] Bot Pulse pareado (rode `/telegram:access` se duvida)
- [ ] 10 minutos sem interrupcao
- [ ] Caderno aberto pra anotar a dor que voce vai declarar (P12) — vale pensar antes

Pronto? Abre `PROMPT.md`, copia tudo entre as linhas tracejadas, cola no Claude Code, manda. Pulse acorda.
