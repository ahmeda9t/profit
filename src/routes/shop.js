const express = require('express');
const pool = require('../db');
const { ensureAuthenticated } = require('../authMiddleware');

const router = express.Router();

// HOME PAGE FOR CUSTOMERS
router.get('/home', ensureAuthenticated, async (req, res) => {
  const [featured] = await pool.query(
    `SELECT product_id, name, unit_price, quantity_on_hand, image_url
     FROM Products
     ORDER BY product_id DESC
     LIMIT 6`
  );
  res.render('shop/home', { user: req.session.user, featured });
});

// LIST ALL CATEGORIES
router.get('/categories', ensureAuthenticated, async (req, res) => {
  const [categories] = await pool.query(
    `SELECT c.category_id, c.name, COUNT(p.product_id) AS product_count
     FROM Categories c
     LEFT JOIN Products p ON p.category_id = c.category_id
     GROUP BY c.category_id, c.name
     ORDER BY c.name`
  );
  res.render('shop/categories', { user: req.session.user, categories });
});

// PRODUCTS BY CATEGORY
router.get('/categories/:id', ensureAuthenticated, async (req, res) => {
  const categoryId = req.params.id;
  const [[category]] = await pool.query('SELECT * FROM Categories WHERE category_id = ?', [categoryId]);
  if (!category) {
    return res.redirect('/shop/categories');
  }

  const [products] = await pool.query(
    `SELECT product_id, name, unit_price, quantity_on_hand, image_url
     FROM Products
     WHERE category_id = ?
     ORDER BY product_id DESC`,
    [categoryId]
  );

  res.render('shop/category_products', {
    user: req.session.user,
    category,
    products
  });
});

/* ========== BROWSE PRODUCTS (SHOP) ========== */

router.get('/', ensureAuthenticated, async (req, res) => {
  const [products] = await pool.query(
    `SELECT product_id, name, unit_price, quantity_on_hand
     FROM Products
     WHERE quantity_on_hand > 0
     ORDER BY product_id`
  );
  res.render('shop/index', { user: req.session.user, products });
});

/* ========== CART IN SESSION ========== */

// Helper to init cart
function getCart(req) {
  if (!req.session.cart) req.session.cart = [];
  return req.session.cart;
}

// Add to cart
router.post('/add', ensureAuthenticated, async (req, res) => {
  try {
    const { product_id, quantity } = req.body;
    const qty = parseInt(quantity || '1', 10);

    if (!product_id || qty <= 0) {
      return res.redirect('/shop');
    }

    const [[product]] = await pool.query(
      'SELECT product_id, name, unit_price, quantity_on_hand FROM Products WHERE product_id = ?',
      [product_id]
    );

    if (!product || product.quantity_on_hand <= 0) {
      return res.redirect('/shop');
    }

    const cart = getCart(req);

    const existing = cart.find(item => item.product_id === product.product_id);
    if (existing) {
      existing.quantity += qty;
    } else {
      cart.push({
        product_id: product.product_id,
        name: product.name,
        unit_price: product.unit_price,
        quantity: qty
      });
    }

    return res.redirect('/shop/cart');
  } catch (err) {
    console.error('Error adding to cart:', err);
    return res.redirect('/shop');
  }
});

// View cart
router.get('/cart', ensureAuthenticated, (req, res) => {
  const cart = getCart(req);
  let total = 0;
  cart.forEach(item => {
    total += item.unit_price * item.quantity;
  });
  res.render('shop/cart', { user: req.session.user, cart, total });
});

// Remove item from cart
router.post('/cart/remove', ensureAuthenticated, (req, res) => {
  const { product_id } = req.body;
  const cart = getCart(req);
  req.session.cart = cart.filter(item => item.product_id.toString() !== product_id.toString());
  res.redirect('/cart');
});

/* ========== CHECKOUT ========== */

router.get('/checkout', ensureAuthenticated, (req, res) => {
  const cart = getCart(req);
  if (!cart.length) {
    return res.redirect('/shop');
  }
  let total = 0;
  cart.forEach(item => {
    total += item.unit_price * item.quantity;
  });
  res.render('shop/checkout', { user: req.session.user, cart, total, error: null });
});

router.post('/checkout', ensureAuthenticated, async (req, res) => {
  const cart = getCart(req);
  if (!cart.length) {
    return res.redirect('/shop');
  }

  const { delivery_name, delivery_phone, delivery_address } = req.body;

  if (!delivery_name || !delivery_phone || !delivery_address) {
    let total = 0;
    cart.forEach(item => {
      total += item.unit_price * item.quantity;
    });
    return res.render('shop/checkout', {
      user: req.session.user,
      cart,
      total,
      error: 'Please fill all delivery fields.'
    });
  }

  const conn = await pool.getConnection();
  try {
    await conn.beginTransaction();

    // calculate total
    let total = 0;
    for (const item of cart) {
      total += item.unit_price * item.quantity;
    }

    // Insert order (customer_id NULL, employee_id = logged-in user)
    const [orderRes] = await conn.query(
      `INSERT INTO Orders
       (customer_id, employee_id, total_amount, discount_amount,
        delivery_name, delivery_phone, delivery_address)
       VALUES (NULL, ?, ?, 0, ?, ?, ?)`,
      [req.session.user.id, total, delivery_name, delivery_phone, delivery_address]
    );
    const orderId = orderRes.insertId;

    // Insert order lines + reduce stock
    for (const item of cart) {
      const lineTotal = item.unit_price * item.quantity;

      await conn.query(
        'INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES (?,?,?,?)',
        [orderId, item.product_id, item.quantity, lineTotal]
      );

      await conn.query(
        'UPDATE Products SET quantity_on_hand = quantity_on_hand - ? WHERE product_id = ?',
        [item.quantity, item.product_id]
      );
    }

    // Payment row (assume "Cash on Delivery")
    await conn.query(
      'INSERT INTO Payments (order_id, payment_method, amount) VALUES (?,?,?)',
      [orderId, 'Cash', total]
    );

    await conn.commit();

    // Clear cart
    req.session.cart = [];

    // Render thank you page
    return res.render('shop/thankyou', {
      user: req.session.user,
      orderId
    });
  } catch (err) {
    await conn.rollback();
    console.error('Checkout error:', err);
    return res.status(500).send('Error during checkout.');
  } finally {
    conn.release();
  }
});

module.exports = router;
