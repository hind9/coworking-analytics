# Use the official Python slim image
FROM python:3.13-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=5153 \
    FLASK_APP=analytics.app \
    FLASK_RUN_HOST=0.0.0.0 \
    FLASK_RUN_PORT=5153

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy requirements first for better caching
COPY analytics/requirements.txt .

# Install Python dependencies including psycopg (modern version)
RUN pip install --no-cache-dir psycopg[binary] && \
    pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY analytics/ ./analytics/

# Expose the Flask port
EXPOSE 5153

# Run the app using Python module
CMD ["python", "-m", "analytics.app"]
