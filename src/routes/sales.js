const express = require('express');
const pool = require('../db');
const { ensureAuthenticated } = require('../authMiddleware');

const router = express.Router();

// Simple "new sale" screen
router.get('/new', ensureAuthenticated, async (req, res) => {
  const [products] = await pool.query('SELECT * FROM Products WHERE quantity_on_hand > 0');
  res.render('sales/new', { products, user: req.session.user, message: null });
});

router.post('/new', ensureAuthenticated, async (req, res) => {
  /*
    Expect body like:
    customer_name, customer_phone, discount_amount, payment_method
    and arrays product_id[], quantity[]
  */
  const { customer_name, customer_phone, discount_amount = 0, payment_method } = req.body;
  let product_ids = req.body.product_id;
  let quantities = req.body.quantity;

  if (!Array.isArray(product_ids)) {
    product_ids = [product_ids];
    quantities = [quantities];
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // Create / find customer (simple: create every time with given name+phone)
    let customerId = null;
    if (customer_name && customer_name.trim() !== '') {
      const [custRes] = await conn.query(
        'INSERT INTO Customers (full_name, phone) VALUES (?, ?) ON DUPLICATE KEY UPDATE full_name=VALUES(full_name)',
        [customer_name, customer_phone]
      );
      customerId = custRes.insertId || null;
    }

    // Calculate totals
    let total = 0;
    const lineData = [];

    for (let i = 0; i < product_ids.length; i++) {
      const pid = product_ids[i];
      const qty = parseInt(quantities[i], 10);
      if (!qty || qty <= 0) continue;
      const [[product]] = await conn.query('SELECT unit_price, quantity_on_hand FROM Products WHERE product_id=?', [pid]);
      if (!product || product.quantity_on_hand < qty) {
        throw new Error('Insufficient stock for product ' + pid);
      }
      const line_total = product.unit_price * qty;
      total += line_total;
      lineData.push({ pid, qty, line_total });
    }

    const discount = parseFloat(discount_amount) || 0;
    const grandTotal = total - discount;

    // Insert order
    const [orderRes] = await conn.query(
      'INSERT INTO Orders (customer_id, employee_id, total_amount, discount_amount) VALUES (?,?,?,?)',
      [customerId, req.session.user.id, grandTotal, discount]
    );
    const orderId = orderRes.insertId;

    // Insert lines & update stock
    for (const line of lineData) {
      await conn.query(
        'INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES (?,?,?,?)',
        [orderId, line.pid, line.qty, line.line_total]
      );
      await conn.query(
        'UPDATE Products SET quantity_on_hand = quantity_on_hand - ? WHERE product_id = ?',
        [line.qty, line.pid]
      );
    }

    // Payment
    await conn.query(
      'INSERT INTO Payments (order_id, payment_method, amount) VALUES (?,?,?)',
      [orderId, payment_method, grandTotal]
    );

    await conn.commit();
    const [products] = await pool.query('SELECT * FROM Products WHERE quantity_on_hand > 0');
    res.render('sales/new', { products, user: req.session.user, message: 'Sale completed. Order ID: ' + orderId });
  } catch (err) {
    await conn.rollback();
    console.error(err);
    res.status(400).send('Error processing sale: ' + err.message);
  } finally {
    conn.release();
  }
});

module.exports = router;
