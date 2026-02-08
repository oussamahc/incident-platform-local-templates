Template 4: Sample Alert Payloads & Test Data
Complete set of sample alert payloads, curl commands, and mock data for testing the incident platform.

Sample Alert Payloads
1. High Severity - Production API Alert
json
{
  "service": "frontend-api",
  "severity": "high",
  "message": "HTTP 5xx error rate exceeds threshold (15% of requests)",
  "labels": {
    "environment": "production",
    "region": "us-east-1",
    "endpoint": "/api/users",
    "error_rate": "15.3%"
  },
  "timestamp": "2026-02-09T10:30:00Z"
}
curl command:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "frontend-api",
    "severity": "high",
    "message": "HTTP 5xx error rate exceeds threshold (15% of requests)",
    "labels": {
      "environment": "production",
      "region": "us-east-1",
      "endpoint": "/api/users",
      "error_rate": "15.3%"
    }
  }'
2. Critical Severity - Database Connection Failure
json
{
  "service": "postgres-primary",
  "severity": "critical",
  "message": "Database connection pool exhausted - 0 available connections",
  "labels": {
    "environment": "production",
    "cluster": "us-east-1",
    "instance": "postgres-primary-01",
    "pool_size": "100",
    "active_connections": "100"
  },
  "timestamp": "2026-02-09T10:35:00Z"
}
curl command:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "postgres-primary",
    "severity": "critical",
    "message": "Database connection pool exhausted - 0 available connections",
    "labels": {
      "environment": "production",
      "cluster": "us-east-1",
      "instance": "postgres-primary-01"
    }
  }'
3. Medium Severity - High CPU Usage
json
{
  "service": "backend-worker",
  "severity": "medium",
  "message": "CPU usage above 80% for 5 minutes",
  "labels": {
    "environment": "production",
    "region": "us-west-2",
    "instance": "worker-03",
    "cpu_usage": "85.2%",
    "duration": "5m"
  },
  "timestamp": "2026-02-09T10:40:00Z"
}
curl command:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "backend-worker",
    "severity": "medium",
    "message": "CPU usage above 80% for 5 minutes",
    "labels": {
      "environment": "production",
      "region": "us-west-2",
      "cpu_usage": "85.2%"
    }
  }'
4. Low Severity - Disk Space Warning
json
{
  "service": "log-storage",
  "severity": "low",
  "message": "Disk usage at 75% - cleanup recommended",
  "labels": {
    "environment": "production",
    "region": "eu-west-1",
    "mount": "/var/log",
    "disk_usage": "75%",
    "available_space": "50GB"
  },
  "timestamp": "2026-02-09T10:45:00Z"
}
curl command:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "log-storage",
    "severity": "low",
    "message": "Disk usage at 75% - cleanup recommended",
    "labels": {
      "environment": "production",
      "mount": "/var/log",
      "disk_usage": "75%"
    }
  }'
5. High Severity - Memory Leak Detected
json
{
  "service": "cache-service",
  "severity": "high",
  "message": "Memory usage increasing steadily - potential memory leak",
  "labels": {
    "environment": "production",
    "region": "ap-southeast-1",
    "instance": "cache-02",
    "memory_usage": "92%",
    "trend": "increasing"
  },
  "timestamp": "2026-02-09T10:50:00Z"
}
curl command:

bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "cache-service",
    "severity": "high",
    "message": "Memory usage increasing steadily - potential memory leak",
    "labels": {
      "environment": "production",
      "memory_usage": "92%"
    }
  }'
Alert Storm Simulation
Simulate alert storm (multiple related alerts for correlation testing):

Script: simulate-alert-storm.sh
bash
#!/bin/bash

SERVICE="frontend-api"
BASE_URL="http://localhost:8001/api/v1/alerts"

echo "🚨 Simulating alert storm for service: $SERVICE"

for i in {1..5}; do
  echo "Sending alert $i/5..."
  
  curl -X POST $BASE_URL \
    -H "Content-Type: application/json" \
    -d "{
      \"service\": \"$SERVICE\",
      \"severity\": \"high\",
      \"message\": \"HTTP 5xx error rate spike - alert $i\",
      \"labels\": {
        \"environment\": \"production\",
        \"alert_number\": \"$i\"
      }
    }" \
    -s -o /dev/null -w "Status: %{http_code}\n"
  
  # Small delay between alerts (2 seconds)
  sleep 2
done

echo "✅ Alert storm simulation complete"
Run:

bash
chmod +x simulate-alert-storm.sh
./simulate-alert-storm.sh
Mock On-Call Schedule Data
Sample On-Call Schedules (SQL Insert)
sql
-- Insert sample on-call schedules for Platform Engineering team

-- Week 1: Alice (Primary), Bob (Secondary)
INSERT INTO oncall_schedules (team, engineer, start_date, end_date, rotation_type, is_primary)
VALUES 
  ('platform-engineering', 'alice@company.com', '2026-02-09', '2026-02-15', 'weekly', true),
  ('platform-engineering', 'bob@company.com', '2026-02-09', '2026-02-15', 'weekly', false);

-- Week 2: Bob (Primary), Carol (Secondary)
INSERT INTO oncall_schedules (team, engineer, start_date, end_date, rotation_type, is_primary)
VALUES 
  ('platform-engineering', 'bob@company.com', '2026-02-16', '2026-02-22', 'weekly', true),
  ('platform-engineering', 'carol@company.com', '2026-02-16', '2026-02-22', 'weekly', false);

-- Week 3: Carol (Primary), Alice (Secondary)
INSERT INTO oncall_schedules (team, engineer, start_date, end_date, rotation_type, is_primary)
VALUES 
  ('platform-engineering', 'carol@company.com', '2026-02-23', '2026-03-01', 'weekly', true),
  ('platform-engineering', 'alice@company.com', '2026-02-23', '2026-03-01', 'weekly', false);

-- Frontend team schedule
INSERT INTO oncall_schedules (team, engineer, start_date, end_date, rotation_type, is_primary)
VALUES 
  ('frontend-team', 'david@company.com', '2026-02-09', '2026-02-15', 'weekly', true),
  ('frontend-team', 'eve@company.com', '2026-02-09', '2026-02-15', 'weekly', false);

-- Backend team schedule
INSERT INTO oncall_schedules (team, engineer, start_date, end_date, rotation_type, is_primary)
VALUES 
  ('backend-team', 'frank@company.com', '2026-02-09', '2026-02-15', 'weekly', true),
  ('backend-team', 'grace@company.com', '2026-02-09', '2026-02-15', 'weekly', false);
JSON Format (API)
json
{
  "schedules": [
    {
      "team": "platform-engineering",
      "rotations": [
        {
          "start_date": "2026-02-09",
          "end_date": "2026-02-15",
          "primary": {
            "name": "Alice Johnson",
            "email": "alice@company.com",
            "phone": "+1-555-0101"
          },
          "secondary": {
            "name": "Bob Smith",
            "email": "bob@company.com",
            "phone": "+1-555-0102"
          }
        },
        {
          "start_date": "2026-02-16",
          "end_date": "2026-02-22",
          "primary": {
            "name": "Bob Smith",
            "email": "bob@company.com",
            "phone": "+1-555-0102"
          },
          "secondary": {
            "name": "Carol White",
            "email": "carol@company.com",
            "phone": "+1-555-0103"
          }
        }
      ]
    },
    {
      "team": "frontend-team",
      "rotations": [
        {
          "start_date": "2026-02-09",
          "end_date": "2026-02-15",
          "primary": {
            "name": "David Lee",
            "email": "david@company.com",
            "phone": "+1-555-0104"
          },
          "secondary": {
            "name": "Eve Martinez",
            "email": "eve@company.com",
            "phone": "+1-555-0105"
          }
        }
      ]
    }
  ]
}
Comprehensive Test Script
test-platform.sh
bash
#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost"

echo "🧪 Testing Incident Platform..."
echo "================================"

# Test 1: Health checks
echo ""
echo "${YELLOW}Test 1: Health Checks${NC}"
services=("8001" "8002" "8003" "8004" "8080")
for port in "${services[@]}"; do
  response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL:$port/health)
  if [ "$response" -eq 200 ]; then
    echo "${GREEN}✓${NC} Service on port $port is healthy"
  else
    echo "${RED}✗${NC} Service on port $port failed (HTTP $response)"
  fi
done

# Test 2: Send test alerts
echo ""
echo "${YELLOW}Test 2: Alert Ingestion${NC}"

# High severity alert
response=$(curl -s -X POST $BASE_URL:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{
    "service": "test-service",
    "severity": "high",
    "message": "Test high severity alert"
  }' -w "%{http_code}")

if [[ "$response" == *"201"* ]]; then
  echo "${GREEN}✓${NC} High severity alert created"
else
  echo "${RED}✗${NC} Failed to create alert"
fi

# Test 3: Check Prometheus metrics
echo ""
echo "${YELLOW}Test 3: Prometheus Metrics${NC}"

response=$(curl -s $BASE_URL:8001/metrics | grep -c "alerts_received_total")
if [ "$response" -gt 0 ]; then
  echo "${GREEN}✓${NC} Prometheus metrics available"
else
  echo "${RED}✗${NC} Prometheus metrics not found"
fi

# Test 4: Check Grafana
echo ""
echo "${YELLOW}Test 4: Grafana Dashboard${NC}"

response=$(curl -s -o /dev/null -w "%{http_code}" $BASE_URL:3000/api/health)
if [ "$response" -eq 200 ]; then
  echo "${GREEN}✓${NC} Grafana is accessible"
  echo "   Open: http://localhost:3000 (admin/admin)"
else
  echo "${RED}✗${NC} Grafana is not accessible"
fi

# Test 5: Check Prometheus targets
echo ""
echo "${YELLOW}Test 5: Prometheus Targets${NC}"

response=$(curl -s $BASE_URL:9090/api/v1/targets | grep -o '"health":"up"' | wc -l)
echo "${GREEN}✓${NC} Prometheus has $response healthy targets"

echo ""
echo "================================"
echo "Test suite completed!"
Run:

bash
chmod +x test-platform.sh
./test-platform.sh
Sample Incident Data (SQL)
sql
-- Insert sample incidents for testing

-- Incident 1: Resolved
INSERT INTO incidents (incident_id, title, service, severity, status, assigned_to, created_at, acknowledged_at, resolved_at, mtta_seconds, mttr_seconds)
VALUES (
  'incident-001',
  'High error rate on frontend-api',
  'frontend-api',
  'high',
  'resolved',
  'alice@company.com',
  '2026-02-08 10:00:00',
  '2026-02-08 10:03:00',
  '2026-02-08 10:45:00',
  180,   -- 3 minutes to acknowledge
  2700   -- 45 minutes to resolve
);

-- Incident 2: Open
INSERT INTO incidents (incident_id, title, service, severity, status, assigned_to, created_at, acknowledged_at, resolved_at)
VALUES (
  'incident-002',
  'Database connection issues',
  'postgres-primary',
  'critical',
  'acknowledged',
  'bob@company.com',
  '2026-02-09 09:30:00',
  '2026-02-09 09:32:00',
  NULL
);

-- Incident 3: Recently created
INSERT INTO incidents (incident_id, title, service, severity, status, assigned_to, created_at)
VALUES (
  'incident-003',
  'Memory leak in cache service',
  'cache-service',
  'high',
  'open',
  'carol@company.com',
  '2026-02-09 10:50:00'
);
Prometheus Alert Examples
Sample alerts for testing AlertManager (optional)
text
# Example Prometheus alert that would trigger your platform

groups:
  - name: application_alerts
    interval: 30s
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.05
        for: 2m
        labels:
          severity: high
          service: "{{ $labels.service }}"
        annotations:
          summary: "High error rate on {{ $labels.service }}"
          message: "Error rate is {{ $value }} requests/second"

      - alert: ServiceDown
        expr: up{job!="prometheus"} == 0
        for: 1m
        labels:
          severity: critical
          service: "{{ $labels.job }}"
        annotations:
          summary: "Service {{ $labels.job }} is down"
          message: "{{ $labels.job }} has been down for more than 1 minute"
Quick Commands Reference
Start Platform
bash
docker compose up -d
Send Single Alert
bash
curl -X POST http://localhost:8001/api/v1/alerts \
  -H "Content-Type: application/json" \
  -d '{"service":"test","severity":"high","message":"Test"}'
Check Alert Metrics
bash
curl http://localhost:8001/metrics | grep alerts_received
View All Incidents
bash
curl http://localhost:8002/api/v1/incidents
Get Current On-Call
bash
curl http://localhost:8003/api/v1/oncall/current?team=platform-engineering
Check Prometheus Targets
bash
curl http://localhost:9090/api/v1/targets | jq
Access Services
Web UI: http://localhost:8080

Grafana: http://localhost:3000 (admin/admin)

Prometheus: http://localhost:9090

Alert API: http://localhost:8001

Incident API: http://localhost:8002

On-Call API: http://localhost:8003

Performance Testing
Load test script (requires wrk or ab)
bash
# Using Apache Bench (ab)
ab -n 1000 -c 10 -p alert.json -T application/json \
  http://localhost:8001/api/v1/alerts

# alert.json content:
# {"service":"load-test","severity":"medium","message":"Load test alert"}
These templates and test data save 1-2 hours of creating sample payloads and test scripts!