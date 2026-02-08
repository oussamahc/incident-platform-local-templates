# Hackathon 2026: Resources Index

Complete resource package for the DevOps Incident & On-Call Platform Hackathon 2026 - Local Edition.

## What's Included

This resource package contains everything you need to build your incident management platform in 28.5 hours.

**Total Time Saved: 8-12 hours of boilerplate setup, infrastructure configuration, and documentation!**

## Quick Navigation

### Getting Started (Start Here!)
- [Quick Start Guide](quickstart.md) - Get running in 10 minutes
- [Template 1: Docker Compose Starter](../templates/1-docker-compose/README.md) - Infrastructure setup

### Service Templates
- [Template 2: Node.js Microservice](../templates/2-nodejs-service/README.md) - TypeScript/Express template
- [Template 3: Python FastAPI Service](../templates/3-python-service/README.md) - Python/FastAPI template
- [Template 4: Sample Alert Payloads](../templates/4-sample-data/README.md) - Test data and commands

### Advanced Guides
- [CI/CD Pipeline Setup](cicd-pipeline.md) - Complete automation guide
- Docker Optimization Best Practices
- Prometheus Custom Metrics Guide
- Building SRE Dashboards in Grafana

## Template Details

### Template 1: Docker Compose Starter

**What it provides:**

- Complete docker-compose.yml with 8 services
- Prometheus + Grafana pre-configured
- PostgreSQL with schema initialization
- Health checks and dependencies
- Named volumes for persistence
- Docker network setup

⏱️ **Time saved:** 3-4 hours  
📌 **Use when:** Starting your project from scratch

---

### Template 2: Node.js Express Microservice

**What it provides:**

- TypeScript project structure
- Express.js with Prometheus metrics
- Multi-stage Dockerfile (optimized)
- Health check endpoints
- PostgreSQL integration ready
- Unit test setup with Jest
- ESLint + Prettier configuration

⏱️ **Time saved:** 2-3 hours  
📌 **Use when:** Building services in Node.js/TypeScript

**Technologies:**
- Node.js 20
- TypeScript 5.3
- Express 4.18
- prom-client 15.1
- Jest 29

---

### Template 3: Python FastAPI Service

**What it provides:**

- FastAPI project structure
- Prometheus metrics integration
- Multi-stage Dockerfile (Alpine-based)
- Health check endpoints
- PostgreSQL integration ready
- Pydantic models for validation
- pytest setup with coverage

⏱️ **Time saved:** 2-3 hours  
📌 **Use when:** Building services in Python

**Technologies:**
- Python 3.11
- FastAPI 0.109
- prometheus-client 0.19
- uvicorn 0.27
- pytest

---

### Template 4: Sample Alert Payloads & Test Data

**What it provides:**

- 5+ sample alert payloads (all severity levels)
- curl commands for testing
- Alert storm simulation script
- Mock on-call schedule data (SQL + JSON)
- Comprehensive test script
- Sample incident data
- Load testing examples
- Quick command reference

⏱️ **Time saved:** 1-2 hours  
📌 **Use when:** Testing your platform, demonstrating features

---

## Usage Workflows

### Workflow 1: Brand New Project (Fastest Path)

```bash
# Step 1: Start with Docker Compose template (5 min)
cp template1-compose.md/docker-compose.yml .
cp template1-compose.md/monitoring/ ./monitoring/
docker compose up -d

# Step 2: Choose service template (10 min)
# For Node.js:
cp -r template2-nodejs.md/service-template services/alert-ingestion

# For Python:
cp -r template3-python.md/service-template services/alert-ingestion

# Step 3: Implement business logic (remaining time)
# Focus on: alert correlation, incident management, on-call logic

# Step 4: Test with sample data (5 min)
bash template4-samples.md/test-platform.sh

# Step 5: Setup CI/CD (30 min)
cp guide-cicd-pipeline.md/.github/workflows/ci-cd.yml .github/workflows/
```

**Total setup time:** ~1 hour  
**Remaining for development:** 27.5 hours

---

### Workflow 2: Existing Project (Add Components)

#### Adding monitoring:

```bash
# Copy Prometheus + Grafana config
cp template1-compose.md/monitoring/ ./

# Add to docker-compose.yml
# (copy prometheus and grafana service definitions)

docker compose up -d prometheus grafana
```

#### Adding CI/CD:

```bash
# Copy pipeline configuration
cp guide-cicd-pipeline.md/.github/workflows/ci-cd.yml .github/workflows/

# Or for GitLab:
cp guide-cicd-pipeline.md/.gitlab-ci.yml .

# Test locally
make pipeline
```

#### Adding service:

```bash
# Choose template (Node or Python)
cp -r template2-nodejs.md/service-template services/new-service

# Update docker-compose.yml with new service
# Implement business logic
 Documentation Structure
Guides vs Templates
Templates = Copy-paste ready code

docker-compose.yml
- Dockerfiles
- Service source code
- Configuration files

**Guides** = Step-by-step instructions
- How to set up components
- Best practices
- Troubleshooting
- Advanced techniques

---

## 🎓 Learning Path

### For Beginners (Never used Docker Compose)
Read Quick Start Guide - Understand the setup

Follow Template 1 - Get infrastructure running

Choose Template 2 or 3 - Pick one language, understand structure

Use Template 4 - Test with sample data

Study CI/CD Guide - Understand automation

Focus: Get something working first, optimize later

For Intermediate (Familiar with Docker)

1. Skim Quick Start Guide - Quick refresher
2. Use Template 1 - Customize for your needs
3. Mix Template 2 & 3 - Polyglot microservices
4. Implement business logic - Focus on incident platform features
5. Setup CI/CD pipeline - Automate early

**Focus:** Architecture design and feature completeness

---

### For Advanced (Docker experts)

1. Use templates as reference - Don't copy blindly
2. Optimize Dockerfiles - Multi-stage builds, layer caching
3. Advanced monitoring - Custom metrics, SLOs
4. Complete CI/CD - All 7 stages + rollback
5. Performance tuning - Resource limits, scaling

**Focus:** Production-readiness and polish

---

## Customization Guide

### Adapting Node.js Template for Your Service

```javascript
// 1. Change service name in config.ts
export const config = {
  serviceName: 'my-custom-service',  // Change this
  servicePort: 8005,                  // Change port
  // ...
};

// 2. Add your business logic in routes/api.ts
router.post('/my-endpoint', async (req, res) => {
  // Your implementation
});

// 3. Add custom metrics in metrics.ts
export const myCustomMetric = new Counter({
  name: 'my_custom_metric_total',
  help: 'Description of my metric'
});

// 4. Update Dockerfile service name
# In Dockerfile, update labels
LABEL service="my-custom-service"
```

### Adapting Python Template for Your Service

```python
# 1. Change service name in config.py
class Settings(BaseSettings):
    SERVICE_NAME: str = "my-custom-service"  # Change this
    SERVICE_PORT: int = 8005                  # Change port

# 2. Add your business logic in routers/api.py
@router.post("/my-endpoint")
async def my_endpoint(request: MyModel):
    # Your implementation
    pass

# 3. Add custom metrics in metrics.py
my_custom_metric = Counter(
    'my_custom_metric_total',
    'Description of my metric'
)

# 4. Update Dockerfile
# Change CMD or ENTRYPOINT if needed
```

---

## Competition Tips

### Time Management

#### Hour 0-3: Foundation
- Use Template 1 (Docker Compose) → 30 min
- Choose service template (Node or Python) → 15 min
- First service running → 2 hours

#### Hour 3-8: Core Services
- Alert Ingestion → 2 hours
- Incident Management → 2 hours
- Services communicating → 1 hour

#### Hour 8-14: Complete MVP
- On-Call Service → 2 hours
- Web UI → 3 hours
- End-to-end flow working → 1 hour

#### Hour 14-24: Monitoring & Integration
- Prometheus metrics → 2 hours
- Grafana dashboards → 3 hours
- Testing with Template 4 → 1 hour
- Sleep break (recommended!) → 4 hours

#### Hour 24-28: Polish & Submit
- CI/CD pipeline → 2 hours
- Documentation → 1 hour
- Final testing → 1 hour

---

### Team Roles

**4-person team (recommended split):**

- **Person 1:** Infrastructure + Docker Compose (Template 1) → 6 hours, then help others
- **Person 2:** Backend services (Alert + Incident) (Template 2/3) → Full time
- **Person 3:** Backend services (On-Call + Notification) (Template 2/3) → Full time
- **Person 4:** Frontend + Grafana dashboards → Full time

**Parallel work:**

While Person 1 sets up infrastructure, others can:
- Write business logic locally
- Design database schema
- Plan API contracts
- Prepare test data

---

### Quality Over Features

**Must Have (70% of score):**
- 4 core services working
- Docker Compose orchestration
- End-to-end alert → incident flow
- Prometheus + 2 Grafana dashboards
- Health checks passing

**Should Have (20% of score):**
- CI/CD pipeline (4 stages minimum)
- Custom metrics (MTTA, MTTR)
- Clean documentation

**Nice to Have (10% of score):**
- Advanced CI/CD (7 stages)
- Notification service
- Additional dashboards
- Real integrations

> 💡 **Don't over-engineer!** Better to have 4 services working perfectly than 6 services half-broken.

 Common Pitfalls

### Pitfall 1: Too Many Features
- **Problem:** Trying to build everything, nothing works
- **Solution:** Use minimum viable features from templates first

### Pitfall 2: Ignoring Templates
- **Problem:** Reinventing the wheel, wasting 4+ hours
- **Solution:** Copy templates, customize later

### Pitfall 3: No Testing Until End
- **Problem:** Discover major bugs in final hours
- **Solution:** Use Template 4 test scripts throughout development

### Pitfall 4: Manual Deployment
- **Problem:** Can't reliably demo on judge's machine
- **Solution:** Use Template 1 docker-compose.yml, test `docker compose up -d` repeatedly

### Pitfall 5: Hardcoded Secrets
- **Problem:** Automatic disqualification
- **Solution:** Use environment variables, run GitLeaks early (see CI/CD guide)

### Pitfall 6: Missing Health Checks
- **Problem:** Services don't start properly, can't diagnose
- **Solution:** Templates include health checks—keep them!

### Pitfall 7: Ignoring Monitoring
- **Problem:** Can't demonstrate SRE metrics
Solution: Template 1 includes Prometheus/Grafana pre-configured—just add custom metrics

## Resource Comparison

| Resource | Time to Setup | Complexity | Value for Hackathon |
|----------|--------------|------------|---------------------|
| Template 1 (Compose) | 30 min | Medium | ⭐⭐⭐⭐⭐ Essential |
| Template 2 (Node.js) | 15 min | Low | ⭐⭐⭐⭐⭐ Recommended |
| Template 3 (Python) | 15 min | Low | ⭐⭐⭐⭐⭐ Recommended |
| Template 4 (Samples) | 5 min | Very Low | ⭐⭐⭐⭐ Highly Useful |
| Quick Start Guide | 10 min read | Low | ⭐⭐⭐⭐⭐ Start Here |
| CI/CD Guide | 30 min | Medium | ⭐⭐⭐⭐ Important |
| Docker Optimization | 20 min read | Medium | ⭐⭐⭐ Nice to have |
| Prometheus Guide | 20 min read | Medium | ⭐⭐⭐⭐ Important |
| Grafana Guide | 20 min read | Low | ⭐⭐⭐⭐ Important |

---

## Getting Help

---

## Getting Help

### During Hackathon
- **Discord:** #tech-help, #docker-help, #cicd-help
- **Mentors:** Book 15-min slots at https://calendly.com/hackathon2026
- **Documentation:** https://docs.hackathon2026.dev/local-edition

---

## Common Questions

**Q: Which template should I use?**  
A: If comfortable with Node.js → Template 2. If prefer Python → Template 3. Both are equally good!

**Q: Can I mix Node.js and Python services?**  
A: Yes! Polyglot architecture is fine. Use best tool for each service.

**Q: Do I need all 4 templates?**  
A: Template 1 (Compose) is mandatory. Choose Template 2 OR 3 for services. Template 4 is highly recommended for testing.

**Q: Can I modify the templates?**  
A: Absolutely! Templates are starting points, not constraints.

**Q: How much time should I spend on infrastructure?**  
A: Maximum 1 hour with templates. Focus remaining time on features.

---

## Pre-Hackathon Checklist

### Setup (Do This Now!)

- [ ] Docker Desktop installed and running
  - Verify: `docker --version` and `docker compose version`
- [ ] Git installed and configured
- [ ] Code editor (VS Code recommended) installed
- [ ] Downloaded all templates
- [ ] Read Quick Start Guide
- [ ] Tested `docker compose up -d` with Template 1

### Preparation (Optional but Recommended)

- [ ] Read through one service template (Node or Python)
- [ ] Skimmed CI/CD guide
- [ ] Joined Discord server
- [ ] Formed team (2-4 members)
- [ ] Assigned team roles
- [ ] Created GitHub/GitLab repository
- [ ] Planned architecture (rough sketch)

### Test Run (Highly Recommended)

- [ ] Created test project with Template 1
- [ ] Successfully ran `docker compose up -d`
- [ ] Accessed Grafana at http://localhost:3000
- [ ] Sent test alert using Template 4 commands
- [ ] Verified all services healthy

> ✅ **If all checked** - You're ready to compete!

---

## Final Notes

### What These Templates Provide

**Technical Foundation:**
- Production-ready Dockerfiles
- Optimized multi-stage builds
- Health check implementations
- Prometheus metrics integration
- Database connection patterns
- Error handling
- Logging structure

**Infrastructure:**
- Complete Docker Compose orchestration
- Monitoring stack (Prometheus + Grafana)
- Database initialization
- Network configuration
- Volume management

**Development:**
- Project structure
- Configuration management
- Testing setup
- Linting configuration
- CI/CD pipelines

### What You Still Need to Build

**Business Logic:**
- Alert correlation algorithm
- Incident lifecycle management
- On-call schedule computation
- Notification delivery logic
- Web UI components

**Integration:**
- Service-to-service communication
- Database queries
- API endpoint implementation

Custom metrics recording

Domain-Specific:

SRE metrics calculation (MTTA, MTTR)

- Escalation policies
- Alert deduplication
- Incident timeline tracking

### Philosophy

> Templates provide the infrastructure and boilerplate.  
> **You provide the intelligence and features.**

**Goal:** Spend 80% of time on business logic, 20% on setup.

---

## 🎉 Good Luck!

You have everything you need to build an amazing incident management platform!

**Remember:**
- ✅ Start with templates
- 🎯 Focus on core features first
- 🧪 Test continuously (Template 4)
- 📝 Document as you go
- 😴 Sleep at least 3-5 hours

> ⏱️ **Total time saved with templates:** 8-12 hours  
> 💪 **Make it count!**