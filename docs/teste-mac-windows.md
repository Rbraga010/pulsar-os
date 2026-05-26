# Testar a Clara no Mac ou Windows

> **Atenção:** Mac e Windows funcionam pra TESTE só. Em produção, use VPS Linux 24/7 (Hetzner R$ 30/mês ou similar). Por quê? Clara precisa estar viva o tempo todo pra responder cliente · notebook que desliga = Clara dorme = você perde lead.
>
> Mas pra você ver funcionando antes de comprar VPS, o caminho abaixo serve direitinho.

---

## Mac

### 1. Instala Docker Desktop
- Baixa em https://www.docker.com/products/docker-desktop/
- Abre o `.dmg` · arrasta pra Applications · roda
- Faz login (conta Docker grátis · pode usar conta GitHub)
- Confirma na barra de menu (ícone da baleia) que tá "Docker Desktop is running"

### 2. Abre o Terminal do Mac
Spotlight (Cmd+Espaço) → digita "Terminal" → Enter.

### 3. Cria um pasta pra Clara
```bash
mkdir -p ~/pulsar-os && cd ~/pulsar-os
```

### 4. Baixa só o docker-compose.yml e .env.example
```bash
curl -fsSL -o docker-compose.yml https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/docker/docker-compose.yml
curl -fsSL -o .env.example https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/docker/.env.example
cp .env.example .env
```

### 5. Preenche o .env
Abre o `.env` em qualquer editor (TextEdit serve):
```
TELEGRAM_BOT_TOKEN=cola_o_token_do_BotFather
CHAT_ID_OWNER=cola_seu_chat_id_do_userinfobot
```
Salva.

### 6. Sobe a Clara
```bash
docker compose up -d
```
(Vai puxar 3.28GB da imagem · 5-15 min dependendo da sua internet.)

### 7. Loga o cérebro (1x só)
```bash
docker exec -it clara claude login
```
Abre browser · loga conta Claude Max · volta no terminal.

### 8. Vê os logs
```bash
docker compose logs -f
```
Quando aparecer "Container vivo" · pronto. Abre Telegram, manda "oi Clara".

---

## Windows

### Requisito: WSL2
Windows não roda script Linux nativo. Solução: WSL2 (Subsistema Windows pra Linux · vem grátis da Microsoft).

### 1. Habilita WSL2
PowerShell ADMIN:
```powershell
wsl --install
```
Reinicia o PC.

Depois do reboot, abre o "Ubuntu" que aparece no menu Iniciar. Cria usuário e senha · pronto, você tem um Linux dentro do Windows.

### 2. Instala Docker Desktop
- Baixa em https://www.docker.com/products/docker-desktop/
- Instala · escolhe "Use WSL2 instead of Hyper-V"
- Abre o Docker Desktop · vai em Settings → Resources → WSL Integration → ativa pro Ubuntu

### 3. Abre o Ubuntu (WSL)
Menu Iniciar → "Ubuntu" → Enter.

### 4. A partir daqui é igual Linux
Cola o comando padrão:
```bash
curl -fsSL https://raw.githubusercontent.com/Rbraga010/pulsar-os/main/install.sh | sudo bash
```

E segue o passo a passo do install.sh normalmente.

---

## Parar e desligar

Mac/Windows:
```bash
cd ~/pulsar-os    # ou onde você criou
docker compose down
```

Pra voltar a usar:
```bash
docker compose up -d
```

---

## Quando migrar pra VPS de verdade

Quando você decidir levar a sério (vender + ter Clara 24/7):

1. Aluga VPS na Hetzner (CPX11 · R$ 30/mês · Brasil ou Frankfurt)
2. SSH na VPS: `ssh root@SEU-IP`
3. Roda o curl-pipe-bash padrão
4. Migra o .env do Mac/Windows pra VPS (mesma token Telegram · não precisa criar bot novo)
5. Loga claude `docker exec -it clara claude login` de novo (cada máquina é um login)
6. Pode desligar o Mac/Windows · Clara segue rodando na nuvem

Tudo que tava na memória dela (dono.md · loja.md · metas.md · histórico) você COPIA do volume Docker do Mac/Windows pra VPS:

```bash
# No Mac/Windows
docker run --rm -v clara-memory:/source -v $(pwd):/backup busybox tar czf /backup/clara-memory.tar.gz /source

# Manda o arquivo pra VPS via scp
scp clara-memory.tar.gz root@SEU-IP:/tmp/

# Na VPS · DEPOIS de já ter rodado o install.sh
docker run --rm -v clara-memory:/target -v /tmp:/backup busybox tar xzf /backup/clara-memory.tar.gz -C /target --strip-components=1
docker compose restart
```

Pronto · Clara abre os olhos no novo computador lembrando de tudo.
