# Incident Platform - Docker Compose Starter Template

This template provides a complete Docker Compose setup for the Incident & On-Call Management Platform.

## Quick Start

1. **Copy environment file**:
   ```bash
   cp .env.example .env
Build and start all services:

bash
docker compose build
docker compose up -d
Verify services are running:

bash
docker compose ps
Check health endpoints:

bash
curl http://localhost:8001/health  # Alert Ingestion
curl http://localhost:8002/health  # Incident Management
curl http://localhost:8003/health  # On-Call Service
curl http://localhost:8080/health  # Web UI
Access monitoring:

Prometheus: http://localhost:9090

Grafana: http://localhost:3000 (admin/admin)

Service Ports
Service	Port	Description
Alert Ingestion	8001	Receives alerts from monitoring systems
Incident Management	8002	Manages incident lifecycle
On-Call Service	8003	Handles on-call schedules and escalation
Web UI	8080	User interface and API gateway
Prometheus	9090	Metrics collection
Grafana	3000	Dashboards and visualization
PostgreSQL	5432	Database (internal only)
Useful Commands
View logs:

bash
docker compose logs -f                    # All services
docker compose logs -f alert-ingestion    # Specific service
Restart a service:

bash
docker compose restart incident-management
Stop all services:

bash
docker compose down
Stop and remove volumes (clean slate):

bash
docker compose down -v
Scale a service (bonus feature):

bash
docker compose up -d --scale incident-management=3
Testing
Send a test alert:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "frontend-api",
    "severity": "high",
    "message": "High CPU usage detected",
    "labels": {"environment": "production", "region": "us-east-1"},
    "timestamp": "2026-02-09T10:00:00Z"
  }'
Next Steps
Implement service logic in services/ directories

Add custom Grafana dashboards in monitoring/grafana-dashboards/

Configure CI/CD pipeline

Add tests and quality gates

Troubleshooting
Services can't communicate:

Ensure all services are on the same Docker network

Use service names (e.g., http://incident-management:8002) not localhost

Prometheus not scraping metrics:

Check Prometheus targets: http://localhost:9090/targets

Ensure /metrics endpoints return Prometheus format

Database connection errors:

Wait for database to be healthy: docker compose ps database

Check logs: docker compose logs database

text

---

## Usage Instructions

1. Download this template
2. Create the directory structure
3. Copy the file contents into respective files
4. Run `docker compose up -d`
5. Start implementing your services!

**Time Saved**: 2-3 hours of boilerplate setup