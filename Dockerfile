# Pulsar OS · Clara bot container
# Usado pelo docker-compose.yml junto com Postgres
FROM python:3.11-slim

LABEL org.opencontainers.image.title="Pulsar OS · Clara bot"
LABEL org.opencontainers.image.version="0.1.0"
LABEL org.opencontainers.image.source="https://github.com/Rbraga010/pulsar-os"
LABEL org.opencontainers.image.licenses="Proprietary"

# Sistema base
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ffmpeg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Bot deps
RUN pip install --no-cache-dir requests

# Bot code
WORKDIR /app
COPY bot/telegram-bot.py /app/telegram-bot.py

# Bot dir (montado pelo compose)
ENV BOT_DIR=/data
VOLUME ["/data"]

CMD ["python3", "/app/telegram-bot.py"]
