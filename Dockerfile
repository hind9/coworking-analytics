FROM python:3.12-slim-bullseye

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=5153 \
    FLASK_APP=analytics.app \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5153

WORKDIR /app

# Install build dependencies for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libpq-dev \
        python3-dev \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY analytics/requirements.txt .

# Install Python dependencies (verify psycopg2 installation)
RUN pip install --no-cache-dir -r requirements.txt 

# Copy app code
COPY analytics/ ./analytics/

EXPOSE 5153

CMD ["python", "-m", "analytics.app"]
