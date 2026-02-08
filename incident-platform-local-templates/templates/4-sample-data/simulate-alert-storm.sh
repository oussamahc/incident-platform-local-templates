#!/bin/bash

SERVICE="frontend-api"
BASE_URL="http://localhost:8001/api/v1/alerts"

echo " Simulating alert storm for service: $SERVICE"

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

echo " Alert storm simulation complete"
