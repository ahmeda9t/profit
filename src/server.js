const express = require('express');
const session = require('express-session');
const methodOverride = require('method-override');
const path = require('path');
require('dotenv').config();
const pool = require('./db');
const { ensureAuthenticated } = require('./authMiddleware');

const authRoutes = require('./routes/auth');
const shopRoutes = require('./routes/shop');
const productRoutes = require('./routes/products');
const salesRoutes = require('./routes/sales');
const reportRoutes = require('./routes/reports');
const adminOrdersRoutes = require('./routes/adminOrders');

const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, '..', 'views'));

app.use(express.urlencoded({ extended: true }));
app.use(express.json());
app.use(methodOverride('_method'));

app.use(
  session({
    secret: process.env.SESSION_SECRET || 'change_me',
    resave: false,
    saveUninitialized: false
  })
);

app.use((req, res, next) => {
  res.locals.currentUser = req.session.user || null;
  next();
});

app.use(express.static(path.join(__dirname, '..', 'public')));

// Routes
app.use('/', authRoutes);

app.get('/', ensureAuthenticated, async (req, res) => {
  if (req.session.user.role === 'Admin') {
    const [[{ countProducts }]] = await pool.query('SELECT COUNT(*) AS countProducts FROM Products');
    const [[{ countCustomers }]] = await pool.query('SELECT COUNT(*) AS countCustomers FROM Customers');
    const [[{ todayRevenue }]] = await pool.query(
      'SELECT COALESCE(SUM(total_amount),0) AS todayRevenue FROM Orders WHERE DATE(created_at) = CURDATE()'
    );
    const [lowStock] = await pool.query(
      'SELECT name, quantity_on_hand FROM Products WHERE quantity_on_hand <= 5 ORDER BY quantity_on_hand ASC LIMIT 10'
    );
    return res.render('dashboard', {
      user: req.session.user,
      stats: { countProducts, countCustomers, todayRevenue },
      lowStock
    });
  }
  return res.redirect('/shop/home');
});

app.use('/products', productRoutes);
app.use('/sales', salesRoutes);
app.use('/reports', reportRoutes);
app.use('/shop', shopRoutes);
app.use('/admin/orders', adminOrdersRoutes);

// 404
app.use((req, res) => {
  res.status(404).send('Not Found');
});

const port = process.env.PORT || 4000;
app.listen(port, () => {
  console.log(`ProFit server running on http://localhost:${port}`);
});
