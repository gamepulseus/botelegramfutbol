FROM python:3.11-slim

# Metadata
LABEL maintainer="ElOnceTitular"
LABEL description="Bot de Telegram para resultados de fútbol en vivo con API-Football v3"

# Evitar buffering de stdout/stderr (logs inmediatos)
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema (mínimas)
# No necesitamos nada extra: solo Python y requests
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements primero (mejor cache de capas)
COPY requirements.txt .

# Instalar dependencias Python
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Crear directorio de datos para persistencia
RUN mkdir -p /data

# Copiar código del bot
COPY bot.py config.py api_client.py telegram_client.py formatter.py state.py ./

# Usuario no-root por seguridad
RUN useradd -m -u 1000 botuser && chown -R botuser:botuser /app /data
USER botuser

# Variables por defecto (se sobrescriben desde Railway)
ENV POLL_INTERVAL_SECONDS=60
ENV TIMEZONE=America/Caracas
ENV LANGUAGE=es
ENV LOG_LEVEL=INFO
ENV STATE_FILE=/data/state.json

# Comando de arranque
CMD ["python", "bot.py"]
