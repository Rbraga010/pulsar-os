#!/usr/bin/env python3
"""
Clara · OCR de panfleto
Extrai texto de foto de panfleto/oferta (lojista manda foto da concorrência ou
da própria oferta pra Clara ler).

Uso:
    python3 ocr.py <image_path>

Saída (JSON em stdout):
    {
      "text": "...",
      "lang": "por+eng",
      "tool": "tesseract",
      "psm": 6,
      "char_count": 234,
      "confidence_estimate": "high" | "low",
      "fallback_suggestion": "use claude-vision se confidence_estimate=low"
    }

Princípio gratuito: Tesseract local. Se texto curto/inválido (confidence_estimate=low),
Clara pode fallback pra Claude Vision (o LLM que ela já usa lê imagem sem custo extra).
"""

import sys
import json
import subprocess
import os
import re


def estimate_confidence(text: str) -> str:
    """Heurística simples: texto muito curto ou só ruído = low confidence."""
    if not text or len(text.strip()) < 20:
        return "low"
    # se >50% dos chars são não-imprimíveis ou só pontuação isolada, low
    printable_ratio = sum(1 for c in text if c.isalnum() or c.isspace()) / max(len(text), 1)
    if printable_ratio < 0.6:
        return "low"
    # palavras com >=3 letras
    words = re.findall(r"[A-Za-zÀ-ÿ]{3,}", text)
    if len(words) < 3:
        return "low"
    return "high"


def run_tesseract(image_path: str, psm: int = 6) -> str:
    """Roda tesseract com português+inglês, PSM configurável."""
    result = subprocess.run(
        ["tesseract", image_path, "-", "-l", "por+eng", "--psm", str(psm)],
        capture_output=True,
        text=True,
        timeout=60,
    )
    if result.returncode != 0:
        raise RuntimeError(f"tesseract falhou: {result.stderr.strip()}")
    return result.stdout


def main():
    if len(sys.argv) < 2:
        print("Uso: python3 ocr.py <image_path>", file=sys.stderr)
        sys.exit(2)

    image_path = sys.argv[1]
    if not os.path.exists(image_path):
        print(f"Arquivo não encontrado: {image_path}", file=sys.stderr)
        sys.exit(3)

    try:
        text = run_tesseract(image_path, psm=6)
        confidence = estimate_confidence(text)

        result = {
            "text": text.strip(),
            "lang": "por+eng",
            "tool": "tesseract",
            "psm": 6,
            "char_count": len(text.strip()),
            "confidence_estimate": confidence,
            "fallback_suggestion": (
                "Texto baixo · Clara pode usar Claude Vision direto na imagem "
                f"({image_path}) sem custo extra"
                if confidence == "low"
                else None
            ),
            "image_path": image_path,
        }
        print(json.dumps(result, ensure_ascii=False, indent=2))
    except Exception as e:
        print(
            json.dumps(
                {"error": str(e), "tool": "tesseract", "image_path": image_path},
                ensure_ascii=False,
            ),
            file=sys.stderr,
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
