const express = require('express');
const pool = require('../database');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// ✅ GÜNLÜK ÖZET
router.get('/daily-summary', authMiddleware, async (req, res) => {
  try {
    const { date } = req.query || new Date().toISOString().split('T')[0];
    const { companyId } = req.user;

    // Get daily cost
    const costResult = await pool.query(
      `SELECT 
        date, total_cost, actual_servings, cost_per_serving,
        budget_allocated, variance, waste_amount
      FROM daily_cost_summary 
      WHERE company_id = $1 AND date = $2`,
      [companyId, date]
    );

    if (costResult.rows.length === 0) {
      return res.json({
        date,
        total_cost: 0,
        actual_servings: 0,
        cost_per_serving: 0,
        budget_allocated: 0,
        variance: 0,
        status: 'NO_DATA',
        meals: []
      });
    }

    const dailyCost = costResult.rows[0];

    // Get meals for the day
    const mealsResult = await pool.query(
      `SELECT r.name, dmi.status, SUM(ri.quantity * i.unit_cost) as cost
      FROM daily_menu_items dmi
      JOIN recipes r ON dmi.recipe_id = r.id
      JOIN recipe_ingredients ri ON r.id = ri.recipe_id
      JOIN ingredients i ON ri.ingredient_name = i.name
      JOIN daily_menus dm ON dmi.daily_menu_id = dm.id
      WHERE dm.date = $1
      GROUP BY r.id, r.name, dmi.status`,
      [date]
    );

    res.json({
      date: dailyCost.date,
      total_cost: dailyCost.total_cost,
      actual_servings: dailyCost.actual_servings,
      cost_per_serving: dailyCost.cost_per_serving,
      budget_allocated: dailyCost.budget_allocated,
      variance: dailyCost.variance,
      waste_amount: dailyCost.waste_amount,
      status: dailyCost.variance >= 0 ? 'OK' : 'OVER_BUDGET',
      meals: mealsResult.rows
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ AYLIK İSTATİSTİKLER
router.get('/monthly-stats', authMiddleware, async (req, res) => {
  try {
    const { year, month } = req.query;
    const { companyId } = req.user;

    const result = await pool.query(
      `SELECT 
        year, month, total_cost, total_servings, average_cost_per_serving,
        budget_allocated, variance
      FROM monthly_cost_summary
      WHERE company_id = $1 AND year = $2 AND month = $3`,
      [companyId, year, month]
    );

    if (result.rows.length === 0) {
      return res.json({
        year,
        month,
        total_cost: 0,
        total_servings: 0,
        average_cost_per_serving: 0,
        budget_allocated: 0,
        variance: 0
      });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Monthly stats error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ HAFTALIK TREND
router.get('/weekly-trend', authMiddleware, async (req, res) => {
  try {
    const { companyId } = req.user;

    const result = await pool.query(
      `SELECT 
        week_start_date, total_cost, total_servings, average_cost_per_serving
      FROM weekly_cost_summary
      WHERE company_id = $1
      ORDER BY week_start_date DESC
      LIMIT 12`,
      [companyId]
    );

    res.json({ trends: result.rows });
  } catch (error) {
    console.error('Trend error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
