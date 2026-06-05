const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();
const pool = require('./src/database');

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Routes
app.use('/api/v1/auth', require('./src/routes/auth'));
app.use('/api/v1/dashboard', require('./src/routes/dashboard'));
app.use('/api/v1/menus', require('./src/routes/menus'));
app.use('/api/v1/recipes', require('./src/routes/recipes'));
app.use('/api/v1/inventory', require('./src/routes/inventory'));
app.use('/api/v1/reports', require('./src/routes/reports'));
app.use('/api/v1/settings', require('./src/routes/settings'));

// Health Check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: err.message || 'Internal Server Error'
  });
});

// Start Server
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
});

module.exports = app;
