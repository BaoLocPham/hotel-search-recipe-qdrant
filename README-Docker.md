# Docker Setup for Hotel Search Application

This guide explains how to run the hotel search application using Docker and Docker Compose.

## Prerequisites

- Docker and Docker Compose installed
- OpenAI API key (for Natural Language Queries)
- Qdrant API key (optional, will be auto-generated if not provided)

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd hotel-search-recipe-qdrant
   ```

2. **Set up environment variables:**
   ```bash
   cp docker.env.example .env
   # Edit .env and add your API keys
   ```

3. **Start all services:**
   ```bash
   docker-compose up -d
   ```

4. **Wait for services to be healthy:**
   ```bash
   docker-compose ps
   ```

5. **Access the applications:**
   - **Frontend (Streamlit):** http://localhost:8501
   - **Backend API:** http://localhost:8080/docs
   - **Qdrant Dashboard:** http://localhost:6333/dashboard

## Services

### 1. Qdrant Vector Database
- **Port:** 6333 (HTTP), 6334 (gRPC)
- **Dashboard:** http://localhost:6333/dashboard
- **Storage:** Persistent volume `qdrant_storage`

### 2. Superlinked Backend
- **Port:** 8080
- **API Docs:** http://localhost:8080/docs
- **Health Check:** http://localhost:8080/health

### 3. Streamlit Frontend
- **Port:** 8501
- **URL:** http://localhost:8501

## Environment Variables

Create a `.env` file based on `docker.env.example`:

```bash
# Required
OPENAI_API_KEY=your-openai-api-key-here

# Optional (will use defaults if not set)
QDRANT_API_KEY=your-qdrant-api-key-here
OPENAI_MODEL=gpt-4o
TEXT_EMBEDDER_NAME=sentence-transformers/all-mpnet-base-v2
```

## Data Ingestion

After starting the services, you need to ingest the hotel dataset:

```bash
# Wait for the backend to be healthy, then run:
curl -X 'POST' \
  'http://localhost:8080/data-loader/hotel/run' \
  -H 'accept: application/json' \
  -d ''
```

## Development Mode

For development with live code reloading:

```bash
# Use the override file for development
docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d
```

This will mount your local code directories as volumes, allowing you to make changes without rebuilding containers.

## Useful Commands

### View logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f superlinked-backend
docker-compose logs -f streamlit-frontend
docker-compose logs -f qdrant
```

### Stop services
```bash
docker-compose down
```

### Stop and remove volumes
```bash
docker-compose down -v
```

### Rebuild containers
```bash
docker-compose build --no-cache
docker-compose up -d
```

### Check service health
```bash
docker-compose ps
```

## Troubleshooting

### Service won't start
1. Check if ports are already in use:
   ```bash
   netstat -tulpn | grep :8080
   netstat -tulpn | grep :8501
   netstat -tulpn | grep :6333
   ```

2. Check logs for errors:
   ```bash
   docker-compose logs [service-name]
   ```

### Backend health check failing
- Ensure Qdrant is running and healthy
- Check if OpenAI API key is valid
- Verify environment variables are set correctly

### Frontend not loading
- Ensure backend is healthy first
- Check if Streamlit is running on port 8501
- Verify the API URL configuration

### Data ingestion issues
- Wait for backend to be fully healthy
- Check if dataset URLs are accessible
- Verify Qdrant connection

## Production Deployment

For production deployment:

1. Remove the override file or don't use it
2. Set proper environment variables
3. Use proper secrets management
4. Consider using external Qdrant instance
5. Set up proper monitoring and logging

## Cleanup

To completely remove all containers, volumes, and images:

```bash
docker-compose down -v --rmi all
docker system prune -a
``` 