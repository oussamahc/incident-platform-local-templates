# Quick Start Guide: Docker Compose Setup

Get your incident platform running in 10 minutes or less!

---

## Prerequisites

Before starting, ensure you have:

- **Docker Desktop (v20.10+)** installed and running
  - Windows/Mac: Download from https://www.docker.com/products/docker-desktop
  - Linux: Install Docker Engine + Docker Compose plugin
- **8 GB RAM** minimum (16 GB recommended)
- **20 GB free disk space**
- **Ports available:** 8001-8004, 8080, 3000, 5432, 9090

**Verify Docker:**

```bash
docker --version
docker compose version
```

---

## Step 1: Clone Repository (1 minute)

```bash
# Clone your team's repository
git clone https://github.com/yourteam/incident-platform
cd incident-platform

# Or use starter template
git clone https://github.com/hackathon2026/incident-platform-local-templates
cd incident-platform-local-templates
```

---

## Step 2: Project Structure Setup (2 minutes)

Your project should have this structure:

```text
incident-platform/
├── docker-compose.yml           # Main orchestration file
├── .env                          # Environment variables
├── services/                     # Microservices
│   ├── alert-ingestion/
│   │   ├── Dockerfile
│   │   └── [service code]
│   ├── incident-management/
│   ├── oncall-service/
│   ├── notification-service/
│   └── web-ui/
├── monitoring/                   # Monitoring configs
│   ├── prometheus/
│   │   ├── prometheus.yml
│   │   └── alerts.yml
│   └── grafana/
│       ├── provisioning/
│       └── dashboards/
└── init-db/                      # Database initialization
    └── 01-init-schema.sql
```

If starting from scratch, copy the template files:

```bash
cp docker-compose.template.yml docker-compose.yml
cp .env.example .env
```

---

## Step 3: Configure Environment (1 minute)

Edit `.env` file with your configuration:

```bash
# Database Configuration
POSTGRES_DB=incident_platform
POSTGRES_USER=postgres
POSTGRES_PASSWORD=hackathon2026

# Service URLs (Docker network - don't change)
ALERT_SERVICE_URL=http://alert-ingestion:8001
INCIDENT_SERVICE_URL=http://incident-management:8002
ONCALL_SERVICE_URL=http://oncall-service:8003

# Grafana (default credentials)
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=admin
```

> **Note:** For hackathon, keep default values!

---

## Step 4: Build All Services (3 minutes)

```bash
# Build all Docker images
docker compose build

# Expected output:
# [+] Building 120.5s (45/45) FINISHED
# => [alert-ingestion] building...
# => [incident-management] building...
# ...
```

This step takes 2-4 minutes depending on your machine.

**Troubleshooting:**
- Build fails? Check Dockerfiles have correct paths
- Out of space? Run `docker system prune -a` to clean up
- Slow build? Ensure `.dockerignore` excludes `node_modules/venv`

---

## Step 5: Start the Platform (2 minutes)

```bash
# Start all services in background
docker compose up -d

# Expected output:
# [+] Running 8/8
#  [CREATED] Network incident-platform
#  [STARTED] Container incident-platform-db
#  [STARTED] Container alert-ingestion
#  [STARTED] Container incident-management
#  [STARTED] Container oncall-service
#  [STARTED] Container notification-service
#  [STARTED] Container web-ui
#  [STARTED] Container prometheus
#  [STARTED] Container grafana
```

Check all services are running:

```bash
docker compose ps
```

Expected status: All services should show "Up" or "Up (healthy)".

---

## Step 6: Verify Health (1 minute)

Check each service is healthy:

```bash
# Quick health check script
for port in 8001 8002 8003 8004 8080; do
  echo -n "Port $port: "
  curl -s http://localhost:$port/health | grep -o '"status":"[^"]*"' || echo "FAIL"
done
```

Expected: All services return `"status":"healthy"`

Individual checks:

```bash
curl http://localhost:8001/health  # Alert Ingestion
curl http://localhost:8002/health  # Incident Management
curl http://localhost:8003/health  # On-Call Service
curl http://localhost:8004/health  # Notification Service
curl http://localhost:8080/health  # Web UI
```

---

## Step 7: Access Services

Your platform is now running! Access these URLs:

| Service | URL | Credentials |
|---------|-----|-------------|
| Web UI | http://localhost:8080 | None |
| Grafana | http://localhost:3000 | admin/admin |
| Prometheus | http://localhost:9090 | None |
| Alert API | http://localhost:8001 | None |
| Incident API | http://localhost:8002 | None |
| On-Call API | http://localhost:8003 | None |

---

## Step 8: Send Test Alert (1 minute)
Test the platform with a sample alert:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "frontend-api",
    "severity": "high",
    "message": "Test alert - Platform is working!",
    "labels": {
      "environment": "production",
      "test": "true"
    }
  }'
```

Expected response:

```json
{
  "alert_id": "alert-abc123",
  "status": "received",
  "action": "processing",
  "timestamp": "2026-02-09T10:30:00Z"
}
```

---

## Step 9: View in Grafana

1. Open http://localhost:3000
2. Login with `admin` / `admin`
3. Navigate to **Dashboards → Live Incident Overview**
4. You should see your test alert!

---

## Common Issues & Fixes

### Issue: Port already in use

**Error:** `Bind for 0.0.0.0:8080 failed: port is already allocated`

**Fix:**

```bash
# Find what's using the port
lsof -i :8080  # macOS/Linux
netstat -ano | findstr :8080  # Windows

# Kill the process or change port in docker-compose.yml
```

### Issue: Services not healthy

**Error:** unhealthy status in `docker compose ps`

**Fix:**

```bash
# Check logs
docker compose logs [service-name]

# Example: check alert-ingestion
docker compose logs alert-ingestion

# Restart specific service
docker compose restart alert-ingestion
```

### Issue: Database connection failed

**Error:** database service shows unhealthy

**Fix:**

```bash
# Check database logs
docker compose logs database

# Restart database
docker compose restart database

# Wait 10 seconds, then check again
docker compose ps database
```

### Issue: Build fails - dependency errors

**Error:** npm install failed or pip install failed

**Fix:**

```bash
# Clear Docker cache and rebuild
docker compose build --no-cache

# If still fails, check Dockerfile paths
```

### Issue: Out of disk space

**Error:** no space left on device

**Fix:**

```bash
# Remove unused Docker resources
docker system prune -a --volumes

# This removes:
# - Stopped containers
# - Unused images
# - Unused volumes
# - Build cache
```

---

## Useful Commands

### View Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f alert-ingestion

# Last 100 lines
docker compose logs --tail=100
```

### Restart Services

```bash
# Restart all
docker compose restart

# Restart specific service
docker compose restart incident-management
```

### Stop Platform

```bash
# Stop all services
docker compose down

# Stop and remove volumes (clears all data)
docker compose down -v
```

### Scale Services

```bash
# Run 3 instances of incident-management
docker compose up -d --scale incident-management=3

# Check scaled instances
docker compose ps incident-management
```

### Execute Commands in Container

```bash
# Open shell in container
docker compose exec alert-ingestion sh

# Run command
docker compose exec database psql -U postgres -d incident_platform
```

### Check Resource Usage

```bash
# Real-time stats
docker stats

# Container details
docker compose ps -a
```

---

## Next Steps

**Platform is running!**

Now you can:

1. **Build your services** - Implement alert correlation, incident management, etc.
2. **Add custom metrics** - Instrument your code with Prometheus metrics
3. **Create Grafana dashboards** - Visualize incidents, MTTA, MTTR
4. **Setup CI/CD pipeline** - Automate build, test, deploy
5. **Test end-to-end flow** - Alert → Incident → Notification → Resolution

---

## Quick Reference

### Start Platform

```bash
docker compose up -d
```

### Stop Platform

```bash
docker compose down
```

### View Logs

```bash
docker compose logs -f
```

### Check Status

```bash
docker compose ps
```

### Rebuild Service

```bash
docker compose build [service-name]
docker compose up -d [service-name]
```

### Clean Everything

```bash
docker compose down -v
docker system prune -a
```

---

## Success Checklist

- [ ] Docker Desktop installed and running
- [ ] Repository cloned
- [ ] .env file configured
- [ ] All images built successfully (`docker compose build`)
- [ ] All services started (`docker compose up -d`)
- [ ] All health checks passing (`curl http://localhost:*/health`)
- [ ] Grafana accessible at http://localhost:3000
- [ ] Test alert sent successfully
- [ ] Alert visible in Grafana dashboard

> **If all checked** - You're ready to build!

---

## Getting Help

- **Discord:** #docker-help channel
- **Documentation:** https://docs.hackathon2026.dev/local-edition
- **Common Issues:** https://docs.hackathon2026.dev/troubleshooting

> **Pro Tip:** Keep `docker compose logs -f` running in a separate terminal to monitor real-time activity!
