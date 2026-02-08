#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

BASE_URL="http://localhost"

echo " Testing Incident Platform..."
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
