# pix-qr

Gera Pix Copia-e-Cola + QR code PNG no padrão **BR Code** oficial do Banco Central. Lojista usa pra cobrar cliente direto via Pix · sem maquininha · sem intermediário · sem taxa de plataforma.

## Stack

- **Python puro** (`qrcode` + `pillow`) · gratuito
- **CRC16-CCITT** + TLV no padrão BACEN
- **Zero serviço externo** · zero conta bancária PSP intermediária

## Uso

```bash
python3 pix.py <chave_pix> <valor> <nome_recebedor> <cidade> [descricao] [--out=/tmp/pix.png]
```

### Exemplo

```bash
python3 pix.py rbraga01.rb@gmail.com 54.90 "Rodrigo Braga" "Sorocaba" "Claro 30GB"
```

Saída:
```json
{
  "payload": "00020126830014BR.GOV.BCB.PIX0123rbraga01.rb@gmail.com0210CLARO 30GB...",
  "qr_png": "/tmp/pix-qr.png",
  "amount": 54.90,
  "receiver": "Rodrigo Braga",
  "city": "Sorocaba",
  "description": "Claro 30GB",
  "chave_pix": "rbraga01.rb@gmail.com"
}
```

## Como Clara invoca

Quando lojista pede "gera Pix de R$ 54,90 pro cliente fulano pagar":
1. Clara já tem chave Pix do lojista na memória (`cerebro/memory/loja.md`)
2. Executa `python3 pix.py <chave> <valor> "<nome>" "<cidade>" "<desc>"`
3. Captura `payload` (copia-e-cola) + `qr_png` (PNG do QR)
4. Manda os dois pro lojista via Telegram (texto + foto)
5. Lojista repassa pro cliente final

## Padrão BACEN

- Payload Format `01` · estático
- Merchant Category Code `0000`
- Currency `986` (BRL)
- Country `BR`
- TXID default `***` (pagamento avulso · sem reconciliação automática)

Compatível com **qualquer app de banco brasileiro**: Nubank, Itaú, BB, Caixa, PicPay, etc.

## Anti-padrões

- Não usar PSP pago (Gerencianet, Mercado Pago) · BR Code direto resolve · taxa 0
- Para reconciliação automática (saber qual cliente pagou qual cobrança) o lojista precisaria de PSP · isso vai pro escopo "se lojista pedir"

## Validação

- Padrão validado contra https://www.bcb.gov.br/estabilidadefinanceira/pix · seção "Manual do BR Code"
- CRC16-CCITT poly 0x1021, init 0xFFFF
- Testar QR lendo no app do banco · deve detectar como Pix estático
