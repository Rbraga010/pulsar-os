#!/usr/bin/env python3
"""
Clara · Pix QR Code (BR Code · padrão Banco Central)

Gera Pix Copia-e-Cola + QR code PNG. Padrão oficial BACEN · gratuito · zero
intermediário · funciona com qualquer banco BR.

Uso:
    python3 pix.py <chave_pix> <valor> <nome_recebedor> <cidade> [descricao] [--out=/tmp/pix.png]

Exemplo:
    python3 pix.py rbraga01.rb@gmail.com 54.90 "Rodrigo Braga" "Sorocaba" "Claro 30GB"

Saída JSON:
    {
      "payload": "00020126...",
      "qr_png": "/tmp/pix.png",
      "amount": 54.90,
      "receiver": "Rodrigo Braga",
      "city": "Sorocaba",
      "description": "Claro 30GB"
    }
"""

import sys
import os
import json
import argparse
import unicodedata


def crc16_ccitt(data: bytes) -> int:
    """CRC16-CCITT (poly 0x1021, init 0xFFFF) · padrão BR Code BACEN."""
    crc = 0xFFFF
    for byte in data:
        crc ^= byte << 8
        for _ in range(8):
            if crc & 0x8000:
                crc = (crc << 1) ^ 0x1021
            else:
                crc <<= 1
            crc &= 0xFFFF
    return crc


def ascii_normalize(s: str, max_len: int = None) -> str:
    """BR Code aceita só ASCII printable. Remove acentos, sanitiza."""
    s = unicodedata.normalize("NFKD", s).encode("ASCII", "ignore").decode("ASCII")
    s = "".join(c for c in s if 32 <= ord(c) < 127)
    s = s.upper().strip()
    if max_len:
        s = s[:max_len]
    return s


def tlv(tag: str, value: str) -> str:
    """Tag-Length-Value · formato BACEN."""
    length = f"{len(value):02d}"
    return f"{tag}{length}{value}"


def build_payload(chave: str, valor: float, nome: str, cidade: str, descricao: str = "", txid: str = "***") -> str:
    """Monta payload BR Code Pix estático."""
    nome = ascii_normalize(nome, 25) or "RECEBEDOR"
    cidade = ascii_normalize(cidade, 15) or "BRASIL"
    descricao = ascii_normalize(descricao, 50)
    txid = ascii_normalize(txid, 25) or "***"

    # Merchant Account Info (tag 26 · Pix)
    mai = tlv("00", "BR.GOV.BCB.PIX") + tlv("01", chave.strip())
    if descricao:
        mai += tlv("02", descricao)

    # Additional Data (tag 62 · txid)
    add = tlv("05", txid)

    payload = ""
    payload += tlv("00", "01")            # Payload Format Indicator
    payload += tlv("26", mai)             # Merchant Account Information (Pix)
    payload += tlv("52", "0000")          # Merchant Category Code
    payload += tlv("53", "986")           # Currency · BRL
    if valor and valor > 0:
        payload += tlv("54", f"{valor:.2f}")  # Amount
    payload += tlv("58", "BR")            # Country
    payload += tlv("59", nome)            # Merchant Name
    payload += tlv("60", cidade)          # Merchant City
    payload += tlv("62", add)             # Additional Data Field
    payload += "6304"                     # CRC tag + length placeholder
    crc = crc16_ccitt(payload.encode("ascii"))
    payload += f"{crc:04X}"
    return payload


def generate_qr_png(payload: str, out_path: str) -> str:
    import qrcode
    qr = qrcode.QRCode(
        version=None,
        error_correction=qrcode.constants.ERROR_CORRECT_M,
        box_size=10,
        border=2,
    )
    qr.add_data(payload)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    img.save(out_path)
    return out_path


def main():
    parser = argparse.ArgumentParser(description="Gera Pix Copia-e-Cola + QR code PNG.")
    parser.add_argument("chave", help="Chave Pix (email, CPF, CNPJ, telefone, chave aleatória)")
    parser.add_argument("valor", type=float, help="Valor em BRL (ex: 54.90 · 0 = sem valor fixo)")
    parser.add_argument("nome", help="Nome do recebedor (até 25 chars ASCII)")
    parser.add_argument("cidade", help="Cidade do recebedor (até 15 chars ASCII)")
    parser.add_argument("descricao", nargs="?", default="", help="Descrição opcional (até 50 chars)")
    parser.add_argument("--out", default="/tmp/pix-qr.png", help="Path PNG saída (default /tmp/pix-qr.png)")
    parser.add_argument("--txid", default="***", help="TXID (default '***' · estático)")
    args = parser.parse_args()

    payload = build_payload(args.chave, args.valor, args.nome, args.cidade, args.descricao, args.txid)
    qr_path = generate_qr_png(payload, args.out)

    print(json.dumps({
        "payload": payload,
        "qr_png": qr_path,
        "amount": args.valor,
        "receiver": args.nome,
        "city": args.cidade,
        "description": args.descricao,
        "chave_pix": args.chave,
    }, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
