function ensureAuthenticated(req, res, next) {
  if (req.session && req.session.user) return next();
  res.redirect('/login');
}

function ensureRole(role) {
  return (req, res, next) => {
    if (req.session && req.session.user && req.session.user.role === role) return next();
    return res.status(403).send('Forbidden');
  };
}

module.exports = { ensureAuthenticated, ensureRole };
