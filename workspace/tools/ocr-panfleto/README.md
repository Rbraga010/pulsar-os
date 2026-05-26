# ocr-panfleto

Extrai texto de foto de panfleto. Lojista manda foto da oferta da concorrência (ou da própria) pra Clara ler e comparar.

## Stack

- **Tesseract 5.x** (português + inglês) · gratuito · local · zero conta
- **Fallback**: Claude Vision (LLM que Clara já usa) se confidence baixa

## Uso

```bash
python3 ocr.py <image_path>
```

### Exemplo

```bash
python3 ocr.py /tmp/panfleto-vivo.jpg
```

Saída:
```json
{
  "text": "...",
  "lang": "por+eng",
  "tool": "tesseract",
  "psm": 6,
  "char_count": 234,
  "confidence_estimate": "high",
  "fallback_suggestion": null,
  "image_path": "/tmp/panfleto-vivo.jpg"
}
```

## Como Clara invoca

```bash
# Recebe foto via Telegram → salva temp → roda OCR
out=$(python3 /opt/clones/clara/workspace/tools/ocr-panfleto/ocr.py /tmp/foto.jpg)
# Se confidence=low, usa Claude Vision direto (já tem na sessão)
```

## Anti-padrões

- Não usar API paga de OCR (Google Vision, AWS Textract) · Tesseract resolve 80% dos casos
- Se Tesseract falhar (confidence_estimate=low), Clara usa Claude Vision **direto na imagem** · sem custo extra (já tá no contexto dela)

## Troubleshooting

- **`tesseract: command not found`** → `apt install tesseract-ocr tesseract-ocr-por tesseract-ocr-eng`
- **Texto saindo embaralhado** → ajustar PSM (default 6 = bloco uniforme · 3 = automático · 11 = sparse text)
- **Foto torta/escura** → pré-processar com ImageMagick: `convert in.jpg -auto-level -auto-gamma -sharpen 0x1 out.jpg`
