# tts

Transforma texto em áudio de voz feminina natural em PT-BR. Clara usa quando o lojista pede "me manda em áudio", "responde com a tua voz" ou quando Clara mesma decide mandar áudio (resposta longa · acolhimento humano).

## Stack

- Python 3
- **Default · Google Cloud TTS** · voz `pt-BR-Chirp3-HD-Kore` (feminina · natural · alinhada com voz da Clara)
- **Fallback · OpenAI TTS** · modelo `tts-1` · voz `nova`
- Saída OGG/Opus (nativo do voice note Telegram · não precisa converter)

## Custo

- Google Cloud TTS · **grátis até 4 milhões de caracteres por mês** (mais que suficiente pra uma loja inteira)
- OpenAI TTS · ~ U$ 0,015 por mil caracteres (centavos por minuto de áudio)

Clara prefere Google por default. Se o dono só tem OpenAI configurada, Clara cai pra OpenAI sem reclamar.

## Pré-requisito

Pelo menos UMA das duas:

1. `GOOGLE_APPLICATION_CREDENTIALS` no `.env` apontando pro JSON da service account (Google Cloud TTS) · padrão sugerido: `/opt/clones/clara/workspace/data/gcp-tts.json`
2. `OPENAI_API_KEY` no `.env`

Skill `clara-tools-setup.md` ensina o passo a passo de pegar cada uma.

## Setup primeira execução

Pacote Python `google-cloud-texttospeech` precisa estar instalado. Opções:

```bash
# Opção 1 · manual
pip install --user google-cloud-texttospeech requests

# Opção 2 · primeira execução com bandeira (tenta auto-instalar)
python3 tools/tts/say.py "oi" --first-run
```

OpenAI fallback usa só `requests` (geralmente já instalado).

## Uso

```bash
python3 tools/tts/say.py "<texto>" [--voice=Kore|Charon|Aoede] [--out=path.ogg] [--engine=auto|google|openai]
```

### Exemplo

```bash
python3 tools/tts/say.py \
  "Oi João, bom dia. Hoje eu sugiro a gente atacar o WhatsApp dos top 5 clientes que sumiram." \
  --voice=Kore \
  --out=/tmp/clara-msg.ogg
```

Saída no `stdout`: o path do OGG (1 linha · pra Clara consumir). Logs vão pro `stderr`.

## Como Clara invoca (interno)

```bash
out=$(python3 /opt/clones/clara/workspace/tools/tts/say.py \
  "$texto_resposta" \
  --voice=Kore \
  --out=/tmp/clara-voice-${session}.ogg)

if [ $? -eq 0 ]; then
  # manda como voice note no Telegram (reply files=[$out])
  echo "áudio em $out"
fi
```

## Se ambas as keys ausentes

Tool sai com `exit 2` e imprime no stderr:

> Pra eu mandar áudio preciso de uma das duas: Google Cloud TTS (grátis até 4 milhões de caracteres por mês · te ensino em 5 passos) ou OpenAI (mais simples · poucos centavos por minuto). Qual você prefere?

Clara repassa pro lojista e pergunta qual ele topa configurar.

## Anti-padrões

- Não mandar áudio sem o lojista pedir/aceitar · áudio é íntimo · alguns donos preferem texto
- Não usar voz masculina (Charon/Algenib) sem motivo · Clara tem identidade feminina firme
- Não passar de 2 minutos de áudio · se é longo, manda texto ou divide
- Não converter pra MP3 manualmente · OGG/Opus já é o formato nativo do Telegram voice
