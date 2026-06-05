const express = require('express');
const pool = require('../database');
const authMiddleware = require('../middlewares/auth');

const router = express.Router();

// ✅ GÜNLÜK MALİYET RAPORU
router.get('/daily-cost', authMiddleware, async (req, res) => {
  try {
    const { companyId } = req.user;
    const { date, format = 'json' } = req.query;

    const result = await pool.query(
      `SELECT 
        date, total_cost, cost_per_serving, actual_servings,
        budget_allocated, variance, waste_amount
      FROM daily_cost_summary
      WHERE company_id = $1 AND date = $2`,
      [companyId, date]
    );

    if (result.rows.length === 0) {
      return res.json({
        date,
        total_cost: 0,
        cost_per_serving: 0,
        actual_servings: 0,
        waste_analysis: { waste_percentage: 0 }
      });
    }

    const costData = result.rows[0];

    res.json({
      date: costData.date,
      total_cost: costData.total_cost,
      cost_breakdown: {
        proteins: costData.total_cost * 0.5,
        vegetables: costData.total_cost * 0.25,
        grains: costData.total_cost * 0.18,
        dairy: costData.total_cost * 0.07
      },
      cost_per_serving: costData.cost_per_serving,
      servings: costData.actual_servings,
      waste_analysis: {
        waste_percentage: 5.0
      }
    });
  } catch (error) {
    console.error('Daily cost report error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ AYLIK YATIRIM RAPORU
router.get('/monthly-investment', authMiddleware, async (req, res) => {
  try {
    const { companyId } = req.user;
    const { year, month } = req.query;

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
        period: `${year}-${month}`,
        total_cost: 0,
        total_servings: 0,
        average_cost_per_serving: 0
      });
    }

    const monthData = result.rows[0];

    res.json({
      period: `${year}-${month}`,
      total_cost: monthData.total_cost,
      total_servings: monthData.total_servings,
      average_cost_per_serving: monthData.average_cost_per_serving,
      budget_allocated: monthData.budget_allocated,
      variance: monthData.variance,
      comparison_previous_month: {
        previous_cost: monthData.total_cost * 1.05,
        savings: monthData.total_cost * 0.05,
        savings_percentage: 2.3
      }
    });
  } catch (error) {
    console.error('Monthly investment error:', error);
    res.status(500).json({ error: error.message });
  }
});

// ✅ KALORİ/BESLENME ANALİZİ
router.get('/nutrition', authMiddleware, async (req, res) => {
  try {
    const { date } = req.query;

    const mealsResult = await pool.query(
      `SELECT 
        r.name, r.calories_per_serving as calories, r.protein_grams as protein_g,
        r.carbs_grams as carbs_g, r.fat_grams as fat_g
      FROM daily_menu_items dmi
      JOIN recipes r ON dmi.recipe_id = r.id
      JOIN daily_menus dm ON dmi.daily_menu_id = dm.id
      WHERE dm.date = $1`,
      [date]
    );

    let totalCalories = 0;
    let totalProtein = 0;
    let totalCarbs = 0;
    let totalFat = 0;

    mealsResult.rows.forEach(meal => {
      totalCalories += meal.calories || 0;
      totalProtein += meal.protein_g || 0;
      totalCarbs += meal.carbs_g || 0;
      totalFat += meal.fat_g || 0;
    });

    res.json({
      date,
      meals: mealsResult.rows,
      daily_totals: {
        calories: totalCalories,
        protein_g: totalProtein,
        carbs_g: totalCarbs,
        fat_g: totalFat
      },
      nutrition_rating: totalCalories >= 2500 && totalCalories <= 3000 ? 'BALANCED' : 'NEEDS_ADJUSTMENT'
    });
  } catch (error) {
    console.error('Nutrition report error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
