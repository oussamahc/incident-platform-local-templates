require('dotenv').config();

module.exports = {
  port: process.env.SERVICE_PORT || 8001,
  database: {
    url: process.env.DATABASE_URL || 'postgresql://postgres:hackathon2026@localhost:5432/incident_platform'
  },
  services: {
    incidentManagement: process.env.INCIDENT_SERVICE_URL || 'http://incident-management:8002',
    onCall: process.env.ONCALL_SERVICE_URL || 'http://oncall-service:8003'
  },
  environment: process.env.NODE_ENV || 'development'
};
