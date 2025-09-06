FROM python:3.13-slim-bullseye

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=5153 \
    FLASK_APP=analytics.app \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5153

# Install system dependencies required for psycopg2
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements for caching
COPY analytics/requirements.txt .

# Install Python dependencies (now includes psycopg2)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY analytics/ ./analytics/

# Expose Flask port
EXPOSE 5153

# Run the app
CMD ["python", "-m", "analytics.app"]
