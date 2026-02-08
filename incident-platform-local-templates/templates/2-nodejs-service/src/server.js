const express = require('express');
const { register, collectDefaultMetrics } = require('prom-client');
const healthRouter = require('./routes/health');
const apiRouter = require('./routes/api');
const errorHandler = require('./middleware/errorHandler');
const { customMetrics } = require('./metrics');
const config = require('./config');

const app = express();

// Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Collect default metrics (CPU, memory, etc.)
collectDefaultMetrics({ register });

// Routes
app.use('/health', healthRouter);
app.use('/metrics', (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(register.metrics());
});
app.use('/api/v1', apiRouter);

// Error handling middleware
app.use(errorHandler);

// Start server
const PORT = config.port;
const server = app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Service running on port ${PORT}`);
  console.log(`📊 Metrics available at http://localhost:${PORT}/metrics`);
  console.log(`❤️  Health check at http://localhost:${PORT}/health`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;
