const express = require('express');
const pool = require('../db');
const { ensureAuthenticated, ensureRole } = require('../authMiddleware');

const router = express.Router();

// List products
router.get('/', ensureAuthenticated, async (req, res) => {
  const [rows] = await pool.query(`
    SELECT p.product_id, p.name, p.unit_price, p.quantity_on_hand,
           c.name AS category_name, b.name AS brand_name
    FROM Products p
    JOIN Categories c ON p.category_id = c.category_id
    JOIN Brands b ON p.brand_id = b.brand_id
    ORDER BY p.product_id
  `);
  res.render('products/index', { products: rows, user: req.session.user });
});

// New product form
router.get('/new', ensureRole('Admin'), async (req, res) => {
  const [cats] = await pool.query('SELECT * FROM Categories');
  const [brands] = await pool.query('SELECT * FROM Brands');
  const [suppliers] = await pool.query('SELECT * FROM Suppliers');
  res.render('products/form', { product: null, categories: cats, brands, suppliers, user: req.session.user });
});

// Create
router.post('/', ensureRole('Admin'), async (req, res) => {
  const { name, category_id, brand_id, supplier_id, unit_price, quantity_on_hand, badge } = req.body;
  await pool.query(
    'INSERT INTO Products (name, category_id, brand_id, supplier_id, unit_price, quantity_on_hand, badge) VALUES (?,?,?,?,?,?,?)',
    [name, category_id, brand_id, supplier_id, unit_price, quantity_on_hand, badge || null]
  );
  res.redirect('/products');
});

// Edit form
router.get('/:id/edit', ensureRole('Admin'), async (req, res) => {
  const id = req.params.id;
  const [[product]] = await pool.query('SELECT * FROM Products WHERE product_id = ?', [id]);
  const [cats] = await pool.query('SELECT * FROM Categories');
  const [brands] = await pool.query('SELECT * FROM Brands');
  const [suppliers] = await pool.query('SELECT * FROM Suppliers');
  res.render('products/form', { product, categories: cats, brands, suppliers, user: req.session.user });
});

// Update
router.post('/:id', ensureRole('Admin'), async (req, res) => {
  const id = req.params.id;
  const { name, category_id, brand_id, supplier_id, unit_price, quantity_on_hand, badge } = req.body;
  await pool.query(
    'UPDATE Products SET name=?, category_id=?, brand_id=?, supplier_id=?, unit_price=?, quantity_on_hand=?, badge=? WHERE product_id=?',
    [name, category_id, brand_id, supplier_id, unit_price, quantity_on_hand, badge || null, id]
  );
  res.redirect('/products');
});

// Delete
router.post('/:id/delete', ensureRole('Admin'), async (req, res) => {
  const id = req.params.id;
  await pool.query('DELETE FROM Products WHERE product_id=?', [id]);
  res.redirect('/products');
});

module.exports = router;
