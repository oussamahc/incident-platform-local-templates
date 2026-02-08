const { Counter, Histogram, Gauge } = require('prom-client');

// Custom metrics for incident platform

// Counter: Total alerts received
const alertsReceivedTotal = new Counter({
  name: 'alerts_received_total',
  help: 'Total number of alerts received',
  labelNames: ['severity', 'service']
});

// Counter: Alerts correlated to incidents
const alertsCorrelatedTotal = new Counter({
  name: 'alerts_correlated_total',
  help: 'Total number of alerts correlated to incidents',
  labelNames: ['result']
});

// Counter: Total incidents created
const incidentsTotal = new Counter({
  name: 'incidents_total',
  help: 'Total number of incidents',
  labelNames: ['status', 'severity']
});

// Histogram: Mean Time To Acknowledge (MTTA)
const incidentMTTA = new Histogram({
  name: 'incident_mtta_seconds',
  help: 'Time to acknowledge incidents in seconds',
  labelNames: ['severity'],
  buckets: [30, 60, 120, 300, 600, 1800, 3600] // 30s to 1 hour
});

// Histogram: Mean Time To Resolve (MTTR)
const incidentMTTR = new Histogram({
  name: 'incident_mttr_seconds',
  help: 'Time to resolve incidents in seconds',
  labelNames: ['severity'],
  buckets: [300, 600, 1800, 3600, 7200, 14400, 28800] // 5 min to 8 hours
});

// Gauge: Open incidents count
const openIncidentsGauge = new Gauge({
  name: 'open_incidents',
  help: 'Current number of open incidents',
  labelNames: ['severity']
});

// Counter: Notifications sent
const notificationsSentTotal = new Counter({
  name: 'oncall_notifications_sent_total',
  help: 'Total notifications sent',
  labelNames: ['channel', 'status']
});

// Counter: Escalations
const escalationsTotal = new Counter({
  name: 'escalations_total',
  help: 'Total number of escalations',
  labelNames: ['team', 'reason']
});

// HTTP request metrics
const httpRequestDuration = new Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duration of HTTP requests in seconds',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.001, 0.01, 0.1, 0.5, 1, 2, 5]
});

module.exports = {
  customMetrics: {
    alertsReceivedTotal,
    alertsCorrelatedTotal,
    incidentsTotal,
    incidentMTTA,
    incidentMTTR,
    openIncidentsGauge,
    notificationsSentTotal,
    escalationsTotal,
    httpRequestDuration
  }
};
