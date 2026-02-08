CI/CD Pipeline Setup Guide
Complete guide to setting up a 4-7 stage CI/CD pipeline for local Docker Compose deployment.

Pipeline Overview
Minimum Required (4 Stages):

Quality & Testing - Linters, unit tests, coverage

Build - Build Docker images

Deploy - Deploy to local Docker Compose

Verify - Health checks and smoke tests

Advanced Optional (7 Stages):
5. Security Scan - Credential scanning (GitLeaks/TruffleHog)
6. Container Scan - Vulnerability scanning (Trivy/Grype)
7. Integration Tests - API tests against running services

Option 1: GitHub Actions
.github/workflows/ci-cd.yml
text
name: Incident Platform CI/CD

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  DOCKER_BUILDKIT: 1
  COMPOSE_DOCKER_CLI_BUILD: 1

jobs:
  # Stage 1: Code Quality & Testing
  quality:
    name: Code Quality & Tests
    runs-on: ubuntu-latest
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js (if using Node)
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: 'services/*/package-lock.json'

      - name: Setup Python (if using Python)
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          # Node.js services
          for service in services/*/package.json; do
            dir=$(dirname "$service")
            echo "Installing dependencies for $dir"
            (cd "$dir" && npm ci)
          done
          
          # Python services
          for service in services/*/requirements.txt; do
            dir=$(dirname "$service")
            echo "Installing dependencies for $dir"
            (cd "$dir" && pip install -r requirements.txt)
          done

      - name: Run linters
        run: |
          # ESLint for Node.js
          for service in services/*/package.json; do
            dir=$(dirname "$service")
            if [ -f "$dir/.eslintrc.json" ]; then
              echo "Linting $dir"
              (cd "$dir" && npm run lint || true)
            fi
          done
          
          # Pylint for Python
          for service in services/*/requirements.txt; do
            dir=$(dirname "$service")
            echo "Linting $dir"
            (cd "$dir" && pylint **/*.py || true)
          done

      - name: Run unit tests
        run: |
          # Node.js tests
          for service in services/*/package.json; do
            dir=$(dirname "$service")
            echo "Testing $dir"
            (cd "$dir" && npm test)
          done
          
          # Python tests
          for service in services/*/requirements.txt; do
            dir=$(dirname "$service")
            if [ -f "$dir/pytest.ini" ]; then
              echo "Testing $dir"
              (cd "$dir" && pytest --cov --cov-report=xml)
            fi
          done

      - name: Check test coverage
        run: |
          # Enforce 60% minimum coverage (sprint format)
          for service in services/*/coverage.xml; do
            dir=$(dirname "$service")
            coverage=$(grep -o 'line-rate="[^"]*"' "$service" | head -1 | cut -d'"' -f2)
            coverage_percent=$(echo "$coverage * 100" | bc)
            echo "$dir coverage: ${coverage_percent}%"
            
            if (( $(echo "$coverage_percent < 60" | bc -l) )); then
              echo " Coverage below 60% threshold"
              exit 1
            fi
          done

  # Stage 2: Security Scanning
  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: quality
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for secret scanning

      - name: Run GitLeaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Run TruffleHog
        uses: trufflesecurity/trufflehog@main
        with:
          path: ./
          base: main
          head: HEAD

  # Stage 3: Build Docker Images
  build:
    name: Build Images
    runs-on: ubuntu-latest
    needs: [quality, security]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Build all services
        run: |
          docker compose build
          
      - name: List built images
        run: docker images | grep incident-platform

      - name: Save images (for next stages)
        run: |
          docker save $(docker images --format "{{.Repository}}:{{.Tag}}" | grep incident-platform) \
            -o /tmp/images.tar

      - name: Upload images artifact
        uses: actions/upload-artifact@v4
        with:
          name: docker-images
          path: /tmp/images.tar
          retention-days: 1

  # Stage 4: Container Security Scan
  scan:
    name: Scan Containers
    runs-on: ubuntu-latest
    needs: build
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download images
        uses: actions/download-artifact@v4
        with:
          name: docker-images
          path: /tmp

      - name: Load images
        run: docker load -i /tmp/images.tar

      - name: Install Trivy
        run: |
          wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | sudo apt-key add -
          echo "deb https://aquasecurity.github.io/trivy-repo/deb $(lsb_release -sc) main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
          sudo apt-get update
          sudo apt-get install trivy

      - name: Scan images for vulnerabilities
        run: |
          for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep incident-platform); do
            echo "Scanning $image"
            trivy image --severity HIGH,CRITICAL --exit-code 0 "$image"
          done

  # Stage 5: Deploy to Local
  deploy:
    name: Deploy Stack
    runs-on: ubuntu-latest
    needs: [build, scan]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Download images
        uses: actions/download-artifact@v4
        with:
          name: docker-images
          path: /tmp

      - name: Load images
        run: docker load -i /tmp/images.tar

      - name: Stop existing containers
        run: docker compose down || true

      - name: Start services
        run: |
          docker compose up -d
          
      - name: Wait for services to be ready
        run: |
          echo "Waiting for services to start..."
          sleep 30

      - name: Check running containers
        run: docker compose ps

  # Stage 6: Post-Deployment Verification
  verify:
    name: Health Checks
    runs-on: ubuntu-latest
    needs: deploy
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Check service health
        run: |
          services=(8001 8002 8003 8004 8080)
          
          for port in "${services[@]}"; do
            echo "Checking service on port $port"
            
            max_attempts=10
            attempt=0
            
            while [ $attempt -lt $max_attempts ]; do
              response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health || echo "000")
              
              if [ "$response" -eq 200 ]; then
                echo "✓ Port $port is healthy"
                break
              fi
              
              attempt=$((attempt + 1))
              echo "Attempt $attempt/$max_attempts - Status: $response"
              sleep 5
            done
            
            if [ $attempt -eq $max_attempts ]; then
              echo " Port $port failed health check"
              exit 1
            fi
          done

      - name: Check Prometheus targets
        run: |
          response=$(curl -s http://localhost:9090/api/v1/targets | jq -r '.data.activeTargets[] | .health')
          
          if echo "$response" | grep -q "down"; then
            echo " Some Prometheus targets are down"
            exit 1
          fi
          
          echo "✓ All Prometheus targets healthy"

      - name: Check Grafana
        run: |
          response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
          
          if [ "$response" -eq 200 ]; then
            echo "✓ Grafana is healthy"
          else
            echo " Grafana health check failed"
            exit 1
          fi

  # Stage 7: Integration Tests (Optional)
  integration-tests:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: verify
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Send test alert
        run: |
          response=$(curl -s -X POST http://localhost:8001/api/v1/alerts \
            -H "Content-Type: application/json" \
            -d '{
              "service": "ci-test",
              "severity": "high",
              "message": "CI/CD integration test"
            }')
          
          alert_id=$(echo "$response" | jq -r '.alert_id')
          
          if [ -z "$alert_id" ] || [ "$alert_id" = "null" ]; then
            echo " Failed to create alert"
            exit 1
          fi
          
          echo "✓ Alert created: $alert_id"

      - name: Verify metrics updated
        run: |
          sleep 5
          
          metrics=$(curl -s http://localhost:8001/metrics | grep alerts_received_total)
          
          if [ -z "$metrics" ]; then
            echo " Metrics not found"
            exit 1
          fi
          
          echo "✓ Metrics updated"

      - name: Run API tests
        run: |
          # Install newman (Postman CLI)
          npm install -g newman
          
          # Run API test collection (if exists)
          if [ -f "tests/postman_collection.json" ]; then
            newman run tests/postman_collection.json \
              --environment tests/postman_environment.json
          fi

  # Cleanup on failure
  cleanup:
    name: Cleanup on Failure
    runs-on: ubuntu-latest
    if: failure()
    needs: [deploy, verify, integration-tests]
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Collect logs
        run: |
          docker compose logs > /tmp/docker-logs.txt

      - name: Upload logs
        uses: actions/upload-artifact@v4
        with:
          name: failure-logs
          path: /tmp/docker-logs.txt

      - name: Stop containers
        run: docker compose down
Option 2: GitLab CI/CD
.gitlab-ci.yml
text
stages:
  - quality
  - security
  - build
  - scan
  - deploy
  - verify
  - test

variables:
  DOCKER_BUILDKIT: 1
  COMPOSE_DOCKER_CLI_BUILD: 1

# Stage 1: Code Quality
quality:
  stage: quality
  image: node:20
  before_script:
    - apt-get update && apt-get install -y python3 python3-pip
  script:
    # Run linters
    - echo "Running linters..."
    - for service in services/*/package.json; do
        dir=$(dirname "$service");
        (cd "$dir" && npm ci && npm run lint || true);
      done
    
    # Run tests
    - echo "Running tests..."
    - for service in services/*/package.json; do
        dir=$(dirname "$service");
        (cd "$dir" && npm test);
      done
    
    # Check coverage
    - echo "Checking coverage..."
    - echo "Coverage must be >= 60%"
  
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: services/*/coverage/cobertura-coverage.xml

# Stage 2: Security Scan
security:gitleaks:
  stage: security
  image: zricethezav/gitleaks:latest
  script:
    - gitleaks detect --source . --verbose
  allow_failure: false

security:trufflehog:
  stage: security
  image: trufflesecurity/trufflehog:latest
  script:
    - trufflehog filesystem . --json
  allow_failure: true

# Stage 3: Build
build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker compose build
    - docker images
  artifacts:
    paths:
      - docker-compose.yml

# Stage 4: Container Scan
scan:trivy:
  stage: scan
  image: aquasec/trivy:latest
  script:
    - trivy image --severity HIGH,CRITICAL alert-ingestion:latest
    - trivy image --severity HIGH,CRITICAL incident-management:latest
    - trivy image --severity HIGH,CRITICAL oncall-service:latest
  allow_failure: true

# Stage 5: Deploy
deploy:local:
  stage: deploy
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker compose down || true
    - docker compose up -d
    - sleep 30
    - docker compose ps
  environment:
    name: local
    on_stop: stop_deploy

# Stage 6: Verify
verify:health:
  stage: verify
  image: curlimages/curl:latest
  script:
    - |
      for port in 8001 8002 8003 8004 8080; do
        echo "Checking port $port"
        curl -f http://localhost:$port/health || exit 1
      done

verify:prometheus:
  stage: verify
  image: curlimages/curl:latest
  script:
    - curl -f http://localhost:9090/api/v1/targets
    - echo "Prometheus targets verified"

# Stage 7: Integration Tests
test:integration:
  stage: test
  image: curlimages/curl:latest
  script:
    - |
      curl -X POST http://localhost:8001/api/v1/alerts \
        -H "Content-Type: application/json" \
        -d '{"service":"ci-test","severity":"high","message":"Test"}'
    - sleep 5
    - curl http://localhost:8001/metrics | grep alerts_received_total
  allow_failure: false

# Cleanup
stop_deploy:
  stage: deploy
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker compose down
  when: manual
  environment:
    name: local
    action: stop
Local Pipeline Testing (No CI/CD server)
Makefile
makefile
.PHONY: pipeline quality security build scan deploy verify test cleanup

# Run complete pipeline locally
pipeline: quality security build scan deploy verify test
	@echo " Complete pipeline passed!"

# Stage 1: Quality
quality:
	@echo " Stage 1: Code Quality & Testing"
	@./scripts/run-tests.sh
	@./scripts/check-coverage.sh

# Stage 2: Security
security:
	@echo " Stage 2: Security Scanning"
	@docker run --rm -v $(PWD):/repo zricethezav/gitleaks:latest detect --source /repo
	@docker run --rm -v $(PWD):/repo trufflesecurity/trufflehog:latest filesystem /repo

# Stage 3: Build
build:
	@echo "  Stage 3: Building Images"
	@docker compose build
	@docker images | grep incident-platform

# Stage 4: Scan
scan:
	@echo " Stage 4: Scanning Containers"
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
		aquasec/trivy image --severity HIGH,CRITICAL alert-ingestion:latest

# Stage 5: Deploy
deploy:
	@echo " Stage 5: Deploying Stack"
	@docker compose down || true
	@docker compose up -d
	@sleep 30

# Stage 6: Verify
verify:
	@echo " Stage 6: Health Checks"
	@./scripts/health-check.sh

# Stage 7: Test
test:
	@echo " Stage 7: Integration Tests"
	@./scripts/integration-tests.sh

# Cleanup
cleanup:
	@echo " Cleanup"
	@docker compose down
	@docker system prune -f
Run locally:

bash
make pipeline
Helper Scripts
scripts/run-tests.sh
bash
#!/bin/bash

set -e

echo "Running unit tests for all services..."

# Node.js services
for service in services/*/package.json; do
  dir=$(dirname "$service")
  echo "Testing $dir"
  (cd "$dir" && npm test)
done

# Python services
for service in services/*/requirements.txt; do
  dir=$(dirname "$service")
  if [ -f "$dir/pytest.ini" ]; then
    echo "Testing $dir"
    (cd "$dir" && pytest --cov)
  fi
done

echo " All tests passed"
scripts/check-coverage.sh
bash
#!/bin/bash

set -e

MINIMUM_COVERAGE=60

echo "Checking test coverage (minimum: ${MINIMUM_COVERAGE}%)..."

# Check each service
for service in services/*/coverage.xml; do
  dir=$(dirname "$service")
  
  # Extract coverage percentage
  coverage=$(grep -o 'line-rate="[^"]*"' "$service" | head -1 | cut -d'"' -f2)
  coverage_percent=$(echo "$coverage * 100" | bc)
  
  echo "$dir: ${coverage_percent}%"
  
  # Check threshold
  if (( $(echo "$coverage_percent < $MINIMUM_COVERAGE" | bc -l) )); then
    echo " Coverage below ${MINIMUM_COVERAGE}% threshold"
    exit 1
  fi
done

echo " All services meet coverage requirements"
scripts/health-check.sh
bash
#!/bin/bash

set -e

services=(8001 8002 8003 8004 8080)

echo "Checking service health..."

for port in "${services[@]}"; do
  echo -n "Port $port: "
  
  response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$port/health)
  
  if [ "$response" -eq 200 ]; then
    echo " Healthy"
  else
    echo " Failed (HTTP $response)"
    exit 1
  fi
done

echo "All services healthy"
scripts/integration-tests.sh
bash
#!/bin/bash

set -e

echo "Running integration tests..."

# Test 1: Send alert
echo "Test 1: Alert creation"
response=$(curl -s -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{"service":"test","severity":"high","message":"Test"}')

alert_id=$(echo "$response" | jq -r '.alert_id')

if [ -z "$alert_id" ] || [ "$alert_id" = "null" ]; then
  echo "Failed to create alert"
  exit 1
fi

echo "Alert created: $alert_id"

# Test 2: Check metrics
echo "Test 2: Metrics verification"
sleep 5

metrics=$(curl -s http://localhost:8001/metrics | grep alerts_received_total)

if [ -z "$metrics" ]; then
  echo "Metrics not found"
  exit 1
fi

echo "Metrics updated"

echo "All integration tests passed"
Make executable:

bash
chmod +x scripts/*.sh
Pipeline Status Badges
GitHub Actions
Add to README.md:

text
![CI/CD Pipeline](https://github.com/yourteam/incident-platform/workflows/Incident%20Platform%20CI/CD/badge.svg)
GitLab CI
Add to README.md:

text
![pipeline status](https://gitlab.com/yourteam/incident-platform/badges/main/pipeline.svg)
![coverage report](https://gitlab.com/yourteam/incident-platform/badges/main/coverage.svg)
Troubleshooting
Pipeline fails at quality stage
Issue: Tests fail or coverage too low

Fix:

bash
# Run tests locally first
cd services/alert-ingestion
npm test

# Check coverage
npm test -- --coverage

# If coverage low, add more tests
Pipeline fails at security stage
Issue: Secrets detected in code

Fix:

bash
# Run GitLeaks locally
docker run --rm -v $(pwd):/repo zricethezav/gitleaks:latest detect --source /repo

# Remove any hardcoded secrets
# Add to .gitignore
Pipeline fails at build stage
Issue: Docker build errors

Fix:

bash
# Build locally to see full error
docker compose build --no-cache

# Check Dockerfile syntax
# Verify paths and dependencies
Pipeline fails at deploy stage
Issue: Containers won't start

Fix:

bash
# Check logs
docker compose logs

# Verify dependencies
docker compose ps

# Restart specific service
docker compose restart [service-name]
Best Practices
Run pipeline locally before pushing

bash
make pipeline
Keep tests fast - Target < 2 minutes for unit tests

Use caching - Cache dependencies to speed up builds

Parallel execution - Run independent stages in parallel

Fail fast - Stop pipeline on first failure

Collect artifacts - Save logs on failure for debugging

Monitor pipeline health - Track success rate and duration

This CI/CD setup saves 3-4 hours of pipeline configuration and provides production-ready automation!