const express = require('express');
const pool = require('../db');
const { ensureAuthenticated, ensureRole } = require('../authMiddleware');

const router = express.Router();

router.get('/', ensureRole('Admin'), async (req, res) => {
  // default: today
  const today = new Date().toISOString().slice(0, 10);
  const { start_date = today, end_date = today } = req.query;

  const [totals] = await pool.query(
    `SELECT 
       SUM(total_amount) AS revenue,
       COUNT(*) AS transactions
     FROM Orders
     WHERE DATE(created_at) BETWEEN ? AND ?`,
    [start_date, end_date]
  );

  const [topProducts] = await pool.query(
    `SELECT p.name, SUM(ol.quantity) AS qty_sold, SUM(ol.line_total) AS revenue
     FROM OrderLines ol
     JOIN Products p ON ol.product_id = p.product_id
     JOIN Orders o ON ol.order_id = o.order_id
     WHERE DATE(o.created_at) BETWEEN ? AND ?
     GROUP BY p.product_id
     ORDER BY qty_sold DESC
     LIMIT 10`,
    [start_date, end_date]
  );

  const [inventory] = await pool.query(
    `SELECT name, quantity_on_hand FROM Products ORDER BY quantity_on_hand ASC LIMIT 10`
  );

  res.render('reports/index', {
    user: req.session.user,
    start_date,
    end_date,
    totals: totals[0] || { revenue: 0, transactions: 0 },
    topProducts,
    inventory
  });
});

module.exports = router;
