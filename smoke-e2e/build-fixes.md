# Build fixes — Iniciativa 8 smoke

## Execução do build.sh

**Comando:**
```bash
cd /root/pulsarh-workspace/pulsar-os
bash dist/build.sh --version v1.0.0 --output /tmp/pulsar-os-build/
```

**Resultado:** SUCESSO de primeira. Sem correções necessárias.

```
[01:31:56] preflight ok
[01:31:56] copiando core/
[01:31:56] copiando installer/ (excluindo docs internas)
[01:31:56] criando tenant/ vazio
[01:31:56] empacotando → /tmp/pulsar-os-build//pulsar-os-v1.0.0.zip
[01:31:56]   344K  /tmp/pulsar-os-build/pulsar-os-v1.0.0.zip
[01:31:56]   sha256: 8198780d1a72ad6ed7e797a74ed024ef78c94883d0bf3dab1dba221e481de13e
[01:31:56] build concluído
```

## Observações

- Tempo de build: <1s (rsync + cp + zip).
- Zip 344K, descompactado 760K (90 arquivos). **Muito abaixo** dos 5-15 MB previstos no STRUCTURE.md — porque os SVGs do vórtice são pequenos e os PNGs ainda menores.
- Path output gerou `//` na concatenação (`/tmp/pulsar-os-build//pulsar-os-v1.0.0.zip`) — cosmético, sem impacto.
- Sem warnings, sem erros, sem fixes aplicados.

## Idempotência

Re-rodando o build, mesmo SHA256 só se nenhum arquivo-fonte mudou. **Não foi re-testado** nesta iniciativa (não-bloqueante). Recomendação: validar idempotência em iniciativa de QA pré-GA.
