const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../database');

const router = express.Router();

// ✅ REGISTER
router.post('/register', async (req, res) => {
  try {
    const { email, password, company_name, first_name, last_name } = req.body;

    // Validate
    if (!email || !password || !company_name) {
      return res.status(400).json({ error: 'Missing required fields' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert company
    const companyResult = await pool.query(
      'INSERT INTO companies (name) VALUES ($1) RETURNING id',
      [company_name]
    );
    const companyId = companyResult.rows[0].id;

    // Insert user
    const userResult = await pool.query(
      'INSERT INTO users (company_id, email, password_hash, first_name, last_name, role) VALUES ($1, $2, $3, $4, $5, $6) RETURNING id, email, role',
      [companyId, email, hashedPassword, first_name, last_name, 'admin']
    );

    const token = jwt.sign(
      { userId: userResult.rows[0].id, companyId, role: 'admin' },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.status(201).json({
      token,
      user: userResult.rows[0],
      company_id: companyId
    });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ LOGIN
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password required' });
    }

    // Get user
    const result = await pool.query(
      'SELECT u.id, u.email, u.password_hash, u.role, u.company_id FROM users u WHERE u.email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];

    // Check password
    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last login
    await pool.query('UPDATE users SET last_login = NOW() WHERE id = $1', [user.id]);

    // Generate token
    const token = jwt.sign(
      { userId: user.id, companyId: user.company_id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        role: user.role,
        company_id: user.company_id
      }
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
