# Clara · sua sócia digital · guia de instalação

Olá. Você acaba de receber a Clara · a sócia agêntica da PulsarH.AI que vai morar no seu Telegram, ajudar a vender mais e cuidar da rotina da loja com você.

Este guia leva uns 15 minutos. Sem mistério. Vai.


## O que é a Clara

A Clara é um programa que roda numa máquina sua (uma VPS Linux barata ou até num computador antigo) e te atende pelo Telegram como se fosse uma sócia. Ela:

- Bate papo com você sobre a loja
- Cria carrossel pro Instagram
- Posta no Google Meu Negócio
- Envia WhatsApp em massa pros clientes
- Gera Pix Copia-e-Cola e QR Code na hora
- Lembra de tudo que você falou
- Te dá ideia de venda quando você tá perdido


## O que você precisa antes de começar

Três coisas:

1. **Uma VPS Linux** (Ubuntu, Debian · qualquer uma com 2GB de RAM serve · custa uns R$ 30/mês na Hetzner, Digital Ocean, etc).
2. **Docker instalado nessa VPS**. Se não tem, roda na VPS:
   ```
   curl -fsSL https://get.docker.com | sh
   ```
3. **Conta de Claude Max OU ChatGPT Plus/Pro** (o "cérebro" da Clara). Você já paga por ela na sua vida pessoal · agora aproveita.


## Passo 1 · Cria o bot da Clara no Telegram

1. Abre o Telegram e procura por `@BotFather`
2. Manda `/newbot`
3. Ele pergunta o nome · pode chamar de "Clara da [sua loja]"
4. Depois pede um username · termina com `_bot`, exemplo: `clara_loja_silva_bot`
5. O BotFather te manda um token gigantão · COPIA, vai precisar


## Passo 2 · Pega seu chat_id do Telegram

1. No Telegram, procura `@userinfobot`
2. Manda `/start`
3. Ele te responde com um número (ex: `123456789`) · esse é seu `chat_id`. Copia também.


## Passo 3 · Baixa a Clara na VPS

Conecta na VPS por SSH e roda:

```
git clone <repo-da-clara> /opt/clara
cd /opt/clara/docker
```

(Substitui `<repo-da-clara>` pelo link que a PulsarH te passou.)


## Passo 4 · Configura o arquivo .env

Ainda na pasta `/opt/clara/docker`:

```
cp .env.example .env
nano .env
```

Você precisa preencher só DUAS linhas:

- `TELEGRAM_BOT_TOKEN=` cola o token do passo 1
- `CHAT_ID_OWNER=` cola o número do passo 2

Salva (Ctrl+O · Enter · Ctrl+X no nano).


## Passo 5 · Sobe a Clara

```
docker compose up -d
```

Vai demorar 5-10 minutos da primeira vez (baixando imagem). Depois fica pronto rapidinho.

Pra ver se subiu:
```
docker compose logs -f
```

Vai aparecer uma mensagem dizendo que falta logar o motor. Calma, é o próximo passo.


## Passo 6 · Loga o cérebro da Clara (1x só)

Você escolhe UM dos dois:

**Opção A · Claude Max (recomendado)**
```
docker exec -it clara claude login
```
Vai aparecer um link · abre no navegador · loga com sua conta Anthropic · pronto.

**Opção B · ChatGPT/Codex**
```
docker exec -it clara codex login
```
Mesma coisa · loga com sua conta OpenAI.

Pode fechar a janela depois. A Clara guarda o login pra sempre.


## Passo 7 · Fala com ela

Abre o Telegram. Procura pelo bot que você criou (aquele `clara_loja_silva_bot` por exemplo).

Manda `/start`.

Ela responde. Daí é só conversar como se fosse uma sócia humana.


## Se algo travar

**"docker compose: command not found"**
Docker não tá instalado. Volta no item 2 da lista de "o que você precisa antes".

**"Permission denied"**
Tenta com `sudo` na frente do comando.

**Clara não responde no Telegram**
Roda `docker compose logs -f` e olha as últimas linhas. Geralmente é:
- Token errado no .env (volta no passo 4)
- Motor não logado (volta no passo 6)
- Seu chat_id não tá no `CHAT_ID_OWNER` (volta no passo 4)

**Quero falar com alguém**
Manda mensagem pra equipe da PulsarH.AI no número que te passamos. Anexa as últimas 20 linhas do `docker compose logs`.


## Comandos úteis pro dia a dia

| Pra fazer isso | Roda isso |
|---|---|
| Ver se tá rodando | `docker compose ps` |
| Ver logs em tempo real | `docker compose logs -f` |
| Reiniciar | `docker compose restart` |
| Parar | `docker compose down` |
| Atualizar versão | `docker compose pull && docker compose up -d` |
| Entrar no terminal da Clara | `docker exec -it clara bash` |

Boa, sócio. Bora vender.
