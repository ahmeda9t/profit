const express = require('express');
const pool = require('../db');
const { ensureAuthenticated } = require('../authMiddleware');

const router = express.Router();

// List orders
router.get('/', ensureAuthenticated, async (req, res) => {
  if (!req.session.user || req.session.user.role !== 'Admin') {
    return res.status(403).send('Forbidden');
  }

  const [orders] = await pool.query(
    `SELECT 
        o.order_id,
        o.total_amount,
        o.created_at,
        DATE_FORMAT(o.created_at, '%Y-%m-%d %H:%i') AS created_at_formatted,
        o.status,
        o.delivery_name,
        o.delivery_phone,
        u.username AS customer_username,
        pmt.payment_method
     FROM Orders o
     LEFT JOIN Users u ON o.employee_id = u.user_id
     LEFT JOIN Payments pmt ON pmt.order_id = o.order_id
     ORDER BY o.created_at DESC`
  );

  res.render('admin/orders', { user: req.session.user, orders });
});

// Update status
router.post('/:id/status', ensureAuthenticated, async (req, res) => {
  if (!req.session.user || req.session.user.role !== 'Admin') {
    return res.status(403).send('Forbidden');
  }

  const orderId = req.params.id;
  const { status } = req.body;

  await pool.query(
    'UPDATE Orders SET status = ? WHERE order_id = ?',
    [status, orderId]
  );

  res.redirect('/admin/orders');
});

module.exports = router;
