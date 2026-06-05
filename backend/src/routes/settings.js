const express = require('express');
const pool = require('../database');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// ✅ ŞİRKET AYARLARI GET
router.get('/company', authMiddleware, async (req, res) => {
  try {
    const { companyId } = req.user;

    const result = await pool.query(
      `SELECT id, name, email, phone, monthly_budget, subscription_tier, status
      FROM companies
      WHERE id = $1`,
      [companyId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Company not found' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Settings error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ ŞİRKET AYARLARI GÜNCELLE
router.put('/company', authMiddleware, async (req, res) => {
  try {
    const { companyId } = req.user;
    const { monthly_budget, subscription_tier } = req.body;

    await pool.query(
      `UPDATE companies 
      SET monthly_budget = $1, subscription_tier = $2, updated_at = NOW()
      WHERE id = $3`,
      [monthly_budget, subscription_tier, companyId]
    );

    res.json({
      updated_at: new Date(),
      message: 'Settings updated successfully'
    });
  } catch (error) {
    console.error('Update settings error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
