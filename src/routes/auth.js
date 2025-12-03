const express = require('express');
const pool = require('../db');

const router = express.Router();

/* ========== LOGIN ========== */

router.get('/login', (req, res) => {
  res.render('login', { error: null });
});

router.post('/login', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.render('login', { error: 'Please enter username and password.' });
    }

    const [rows] = await pool.query(
      'SELECT * FROM Users WHERE username = ?',
      [username]
    );
    const user = rows[0];

    if (!user || password !== user.password_hash) {
      return res.render('login', { error: 'Invalid username or password' });
    }

    req.session.user = {
      id: user.user_id,
      username: user.username,
      role: user.role
    };

    // Admins -> dashboard, Customers -> shop
    if (user.role === 'Admin') {
      return res.redirect('/');
    } else {
      return res.redirect('/shop/home');
    }
  } catch (err) {
    console.error('Login error:', err);
    return res.status(500).render('login', { error: 'Internal login error' });
  }
});

/* ========== SIGNUP ========== */

router.get('/signup', (req, res) => {
  res.render('signup', { error: null });
});

router.post('/signup', async (req, res) => {
  try {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.render('signup', { error: 'All fields are required' });
    }

    const [existing] = await pool.query(
      'SELECT * FROM Users WHERE username = ?',
      [username]
    );

    if (existing.length > 0) {
      return res.render('signup', { error: 'Username already taken' });
    }

    // New site users are Customers
    await pool.query(
      'INSERT INTO Users (username, password_hash, role) VALUES (?, ?, ?)',
      [username, password, 'Customer']
    );

    return res.redirect('/login');
  } catch (err) {
    console.error('Signup error:', err);
    return res.status(500).render('signup', { error: 'Internal signup error' });
  }
});

// CHANGE PASSWORD (GET)
router.get('/change-password', (req, res) => {
  if (!req.session.user) {
    return res.redirect('/login');
  }
  res.render('change_password', { error: null, success: null, user: req.session.user });
});

// CHANGE PASSWORD (POST)
router.post('/change-password', async (req, res) => {
  if (!req.session.user) {
    return res.redirect('/login');
  }

  const { current_password, new_password, confirm_password } = req.body;

  if (!current_password || !new_password || !confirm_password) {
    return res.render('change_password', {
      error: 'All fields are required.',
      success: null,
      user: req.session.user
    });
  }

  if (new_password !== confirm_password) {
    return res.render('change_password', {
      error: 'New passwords do not match.',
      success: null,
      user: req.session.user
    });
  }

  const [rows] = await pool.query('SELECT * FROM Users WHERE user_id = ?', [req.session.user.id]);
  const user = rows[0];
  if (!user || user.password_hash !== current_password) {
    return res.render('change_password', {
      error: 'Current password is incorrect.',
      success: null,
      user: req.session.user
    });
  }

  await pool.query('UPDATE Users SET password_hash = ? WHERE user_id = ?', [
    new_password,
    req.session.user.id
  ]);

  return res.render('change_password', {
    error: null,
    success: 'Password updated successfully.',
    user: req.session.user
  });
});

/* ========== LOGOUT ========== */

router.post('/logout', (req, res) => {
  req.session.destroy(() => {
    res.redirect('/login');
  });
});

module.exports = router;
