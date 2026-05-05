# Como criar seus 2 bots no Telegram (Pulse + Donna)

Tempo estimado: 4 minutos. Voce so precisa do Telegram aberto no celular ou desktop.

Por que dois bots? Porque sao duas pessoas no seu time digital. Pulse e o CEO digital. Donna e a secretaria executiva. Conversas separadas, tons separados, papeis separados.

---

## Passo 1 — Abrir o @BotFather

No Telegram, busque por **@BotFather** e abra a conversa. Ele tem o selo azul de verificacao oficial. Aperte **INICIAR** se for a primeira vez.

O que esperar: ele responde com um menu de comandos. Voce vai usar `/newbot`.

---

## Passo 2 — Criar o bot do Pulse

Digite no chat do BotFather:

```
/newbot
```

Ele vai pedir duas coisas, em ordem:

1. **Nome do bot** (aparece no topo da conversa).
   Sugestao: `Pulse <Nome da sua empresa>`
   Exemplo: `Pulse Padaria do Ze`

2. **Username** (precisa terminar em `bot`, e unico no Telegram inteiro).
   Sugestao: `<empresa>pulse_bot` ou `pulse_<empresa>_bot`
   Exemplo: `padariadozepulse_bot`

Quando o username ja estiver em uso, BotFather avisa "Sorry, this username is already taken". Tenta uma variacao.

O que esperar quando der certo: BotFather manda uma mensagem com `Done! Congratulations` e te entrega um **token** parecido com isso:

```
7384921056:AAFx8j2kP9q4mLwR6tYbN3zX5cV1hG7D8eU
```

**Esse token e o segredo do bot. Trate como senha.** Copia inteiro (precione e segure no Telegram celular, ou clique no codigo no desktop). Voce vai colar no terminal logo mais.

---

## Passo 3 — Criar o bot da Donna

Mesma coisa. Digite de novo:

```
/newbot
```

1. **Nome:** `Donna <Nome da sua empresa>` (ex: `Donna Padaria do Ze`)
2. **Username:** algo como `donna_<empresa>_bot` (ex: `donna_padariadoze_bot`)

Copie o segundo token que ele te der. Vai ficar com 2 tokens guardados (Pulse e Donna).

---

## Passo 4 — Configuracoes essenciais (1 minuto)

Para cada bot (Pulse e Donna), faca o seguinte no @BotFather:

### Desativar entrada em grupos (DM-only)

Digite:

```
/setjoingroups
```

BotFather pede pra voce escolher o bot. Selecione `@<seu_pulse_bot>`. Depois pergunta `Should this bot be allowed in groups?` — responda **Disable**.

Repita pra Donna.

Por que: voce vai conversar 1:1 com cada um. Nao queremos eles em grupos.

### Definir descricao curta (opcional, mas bonito)

```
/setdescription
```

Selecione o bot. Texto sugerido pro Pulse:

```
CEO digital do meu negocio. Operador, nao cerimonial.
```

Pra Donna:

```
Minha secretaria executiva digital. Cobra prazos, organiza agenda, filtra ruido.
```

### Foto opcional

```
/setuserpic
```

Pode mandar qualquer imagem quadrada (logo da empresa, foto sua, ilustracao). Dica: Pulse com tom dourado/escuro, Donna com tom mais elegante. Se nao quiser, pula.

---

## Passo 5 — Voltar ao terminal

Volte pra esta janela. O wizard vai pedir os 2 tokens, um por vez. Cole o do Pulse primeiro, depois o da Donna.

O input e oculto (voce nao ve os caracteres aparecendo). E proposital, e seguranca.

Se errar e colar o token errado, o wizard valida e te avisa. Sem drama, ele pede de novo.

---

## Pronto

Quando os 2 tokens validarem, o wizard ja arruma o resto:
- Salva os tokens encriptados em `tenant/.env.local` (perm 0600, fora do git)
- Conecta no MCP do Claude Code
- Pergunta se ja pode disparar a primeira mensagem do Pulse no seu Telegram

Da `q` pra fechar este tutorial.
