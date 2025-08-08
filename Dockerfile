# Multi-stage Dockerfile for Hotel Search Application

# Base stage with common dependencies
FROM python:3.11-slim as base

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Backend stage
FROM base as backend

# Copy backend requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend application
COPY superlinked_app/ ./superlinked_app/

# Create .env file from example (will be overridden by docker-compose)
RUN cp superlinked_app/.env-example superlinked_app/.env

# Expose backend port
EXPOSE 8080

# Backend health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

# Frontend stage
FROM base as frontend

# Copy frontend application first
COPY frontend_app/app/ ./frontend_app/app/

# Copy frontend requirements
COPY frontend_app/pyproject.toml ./frontend_app/
COPY frontend_app/settings.toml ./frontend_app/

# Install frontend dependencies
WORKDIR /app/frontend_app
RUN pip install --no-cache-dir -e .

# Expose frontend port
EXPOSE 8501

# Frontend health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8501/_stcore/health || exit 1

# Final stage - Backend
FROM backend as superlinked-backend

# Set environment variables
ENV PYTHONPATH=/app
ENV APP_MODULE_PATH=superlinked_app

# Command to run the Superlinked server
CMD ["python", "-m", "superlinked.server"]

# Final stage - Frontend
FROM frontend as streamlit-frontend

# Set environment variables
ENV PYTHONPATH=/app/frontend_app

# Command to run the Streamlit app
CMD ["streamlit", "run", "app/frontend/main.py", "--server.port=8501", "--server.address=0.0.0.0"] 