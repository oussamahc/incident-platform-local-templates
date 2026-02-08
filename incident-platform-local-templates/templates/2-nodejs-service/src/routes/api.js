const express = require('express');
const router = express.Router();
const { customMetrics } = require('../metrics');

// Example API endpoint - Alert Ingestion
router.post('/alerts', async (req, res, next) => {
  const startTime = Date.now();

  try {
    const { service, severity, message, labels, timestamp } = req.body;

    // Validate request
    if (!service || !severity || !message) {
      return res.status(400).json({
        error: 'Missing required fields: service, severity, message'
      });
    }

    // Increment alerts received metric
    customMetrics.alertsReceivedTotal.inc({ 
      severity: severity.toLowerCase(), 
      service 
    });

    // TODO: Implement alert processing logic
    // - Store alert in database
    // - Check for correlation with existing incidents
    // - Create new incident or attach to existing

    const alertId = `alert-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    
    // Record HTTP request duration
    const duration = (Date.now() - startTime) / 1000;
    customMetrics.httpRequestDuration.observe({
      method: 'POST',
      route: '/api/v1/alerts',
      status_code: 201
    }, duration);

    res.status(201).json({
      alert_id: alertId,
      status: 'received',
      message: 'Alert received and processing'
    });

  } catch (error) {
    next(error);
  }
});

// Example GET endpoint
router.get('/alerts/:alertId', async (req, res, next) => {
  try {
    const { alertId } = req.params;
    
    // TODO: Fetch alert from database

    res.json({
      alert_id: alertId,
      service: 'example-service',
      severity: 'high',
      message: 'Example alert',
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    next(error);
  }
});

module.exports = router;
