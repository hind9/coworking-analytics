# Use the official Python slim image
FROM python:3.13-slim-bullseye

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV APP_PORT=5153

# Install system dependencies
RUN apt update -y && \
    apt install -y gcc libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app


# Copy requirements and install dependencies
COPY analytics/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire analytics app
COPY analytics/ ./analytics/

# Expose the port your Flask app will run on
EXPOSE 5153

# Set environment variables for Flask
ENV FLASK_APP=analytics.app
ENV FLASK_RUN_HOST=0.0.0.0
ENV FLASK_RUN_PORT=5153

# Command to run the app using Waitress
CMD ["python", "-m", "analytics.app"]
