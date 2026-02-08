# Node.js Microservice Template

Express.js microservice with Prometheus metrics and health checks.

## Features

- ✅ Express.js web framework
- ✅ Prometheus metrics integration
- ✅ Health check endpoints (/health, /ready, /live)
- ✅ Multi-stage Docker build
- ✅ Non-root user execution
- ✅ Graceful shutdown handling
- ✅ Error handling middleware
- ✅ PostgreSQL integration ready

## Quick Start

### Local Development

1. Install dependencies:
   ```bash
   npm install
Set environment variables:

bash
cp .env.example .env
Run in development mode:

bash
npm run dev
Run tests:

bash
npm test
Docker
Build image:

bash
docker build -t alert-ingestion:latest .
Run container:

bash
docker run -p 8001:8001 \
  -e DATABASE_URL=postgresql://postgres:hackathon2026@database:5432/incident_platform \
  alert-ingestion:latest
API Endpoints
Endpoint	Method	Description
/health	GET	Health check with dependency status
/health/ready	GET	Readiness check
/health/live	GET	Liveness check
/metrics	GET	Prometheus metrics
/api/v1/alerts	POST	Create alert (example)
/api/v1/alerts/:id	GET	Get alert by ID (example)
Metrics Exposed
alerts_received_total - Counter of alerts received

alerts_correlated_total - Counter of alerts correlated

incidents_total - Counter of incidents by status

incident_mtta_seconds - Histogram of time to acknowledge

incident_mttr_seconds - Histogram of time to resolve

http_request_duration_seconds - HTTP request latency

Environment Variables
Variable	Default	Description
SERVICE_PORT	8001	Port to run service on
DATABASE_URL	(see .env.example)	PostgreSQL connection string
NODE_ENV	development	Environment (development/production)
Project Structure
text
src/
├── server.js           # Express app setup
├── config.js           # Configuration management
├── metrics.js          # Custom Prometheus metrics
├── routes/
│   ├── health.js       # Health check endpoints
│   └── api.js          # API endpoints
└── middleware/
    └── errorHandler.js # Error handling
Next Steps
Implement your business logic in src/routes/api.js

Add database models and queries

Add unit tests in __tests__/

Configure CI/CD pipeline

Add API documentation (OpenAPI/Swagger)

text

---

## Usage

This template saves 2-3 hours of setup time and provides:
- Production-ready Express.js structure
- Prometheus metrics integration
- Docker optimization
- Health check patterns
- Error handling

**Customize** the routes and add your service-specific logic!