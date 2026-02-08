-- Create schemas for each service
CREATE SCHEMA IF NOT EXISTS alerts;
CREATE SCHEMA IF NOT EXISTS incidents;
CREATE SCHEMA IF NOT EXISTS oncall;

-- Alerts schema tables
CREATE TABLE IF NOT EXISTS alerts.alerts (
    id SERIAL PRIMARY KEY,
    alert_id VARCHAR(255) UNIQUE NOT NULL,
    service VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    message TEXT NOT NULL,
    labels JSONB,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
    incident_id INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_alerts_service_severity ON alerts.alerts(service, severity);
CREATE INDEX idx_alerts_timestamp ON alerts.alerts(timestamp);
CREATE INDEX idx_alerts_incident_id ON alerts.alerts(incident_id);

-- Incidents schema tables
CREATE TABLE IF NOT EXISTS incidents.incidents (
    id SERIAL PRIMARY KEY,
    incident_id VARCHAR(255) UNIQUE NOT NULL,
    title VARCHAR(500) NOT NULL,
    service VARCHAR(255) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'open',
    assigned_to VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    acknowledged_at TIMESTAMP,
    resolved_at TIMESTAMP,
    notes TEXT[]
);

CREATE INDEX idx_incidents_status ON incidents.incidents(status);
CREATE INDEX idx_incidents_service ON incidents.incidents(service);
CREATE INDEX idx_incidents_severity ON incidents.incidents(severity);

-- On-call schema tables
CREATE TABLE IF NOT EXISTS oncall.schedules (
    id SERIAL PRIMARY KEY,
    team VARCHAR(255) NOT NULL,
    rotation_type VARCHAR(50) NOT NULL,
    start_date DATE NOT NULL,
    engineers JSONB NOT NULL,
    escalation_minutes INTEGER DEFAULT 5,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS oncall.escalations (
    id SERIAL PRIMARY KEY,
    incident_id VARCHAR(255) NOT NULL,
    from_engineer VARCHAR(255) NOT NULL,
    to_engineer VARCHAR(255) NOT NULL,
    reason VARCHAR(255),
    escalated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_escalations_incident ON oncall.escalations(incident_id);
