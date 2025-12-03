-- Create database
CREATE DATABASE IF NOT EXISTS profit_store;
USE profit_store;

SET FOREIGN_KEY_CHECKS = 0;

-- Drop existing tables if rerunning
DROP TABLE IF EXISTS Payments;
DROP TABLE IF EXISTS OrderLines;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS Products;
DROP TABLE IF EXISTS Brands;
DROP TABLE IF EXISTS Categories;
DROP TABLE IF EXISTS Suppliers;
DROP TABLE IF EXISTS Users;

SET FOREIGN_KEY_CHECKS = 1;

-- USERS (employees/admins)
CREATE TABLE Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Admin','Employee') NOT NULL DEFAULT 'Employee'
);

-- SUPPLIERS
CREATE TABLE Suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100)
);

-- CATEGORIES
CREATE TABLE Categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- BRANDS
CREATE TABLE Brands (
  brand_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- PRODUCTS
CREATE TABLE Products (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  brand_id INT NOT NULL,
  supplier_id INT NOT NULL,
  name VARCHAR(100) NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  quantity_on_hand INT NOT NULL DEFAULT 0,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES Categories(category_id),
  CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES Brands(brand_id),
  CONSTRAINT fk_products_supplier FOREIGN KEY (supplier_id) REFERENCES Suppliers(supplier_id)
);

-- CUSTOMERS
CREATE TABLE Customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  loyalty_points INT DEFAULT 0
);

-- ORDERS
CREATE TABLE Orders (
  order_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT,
  employee_id INT NOT NULL,
  total_amount DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
  CONSTRAINT fk_orders_employee FOREIGN KEY (employee_id) REFERENCES Users(user_id)
);

-- ORDER LINES
CREATE TABLE OrderLines (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  line_total DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  CONSTRAINT fk_ol_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  CONSTRAINT fk_ol_product FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- PAYMENTS
CREATE TABLE Payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payment_method ENUM('Cash','Card') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pay_order FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

---------------------------------------------------
-- SEED DATA
---------------------------------------------------

-- Users (passwords are bcrypt hashes)
-- admin / admin123
-- emily / password123
INSERT INTO Users (username, password_hash, role) VALUES
('admin', '$2b$12$Nz8YXmA83YSPYfl7KZNxhegB3AjJlzkIpXwYfaWaWJH81t8309Ahu', 'Admin'),
('emily', '$2b$12$RKgcZuyGcEjYVJ60ocTc9uMyud9sbhO71tZ9J0FkUBdpAT/0Dve8S', 'Employee');

-- Suppliers
INSERT INTO Suppliers (name, email) VALUES
('Main Supplier', 'main@supplier.com'),
('Global Sports Imports', 'contact@globalsports.com'),
('FitGear Wholesale', 'sales@fitgear.com');

-- Categories
INSERT INTO Categories (name) VALUES
('Footwear'),
('Gym Equipment'),
('Clothing'),
('Accessories');

-- Brands
INSERT INTO Brands (name) VALUES
('Nike'),
('Adidas'),
('ProFit'),
('Under Armour');

-- Products (with stock)
INSERT INTO Products (category_id, brand_id, supplier_id, name, unit_price, quantity_on_hand) VALUES
-- 1
(1, 1, 1, 'Running Shoes',            59.99, 50),
-- 2
(2, 3, 1, 'Yoga Mat',                 20.00, 200),
-- 3
(2, 2, 2, 'Football',                 25.50, 60),
-- 4
(3, 2, 2, 'Basketball Jersey',        39.90, 35),
-- 5
(2, 1, 3, 'Tennis Racket',           80.00, 20),
-- 6
(4, 3, 1, 'Water Bottle',             10.00, 80),
-- 7
(4, 4, 3, 'Gym Gloves',               15.00, 40),
-- 8
(4, 3, 1, 'Sports Socks (pair)',       5.50, 300),
-- 9
(3, 4, 2, 'Hoodie',                   45.00, 25),
-- 10
(2, 3, 3, 'Resistance Band Set',      30.00, 50);

-- Customers
INSERT INTO Customers (full_name, phone, loyalty_points) VALUES
('Ali Hassan',        '70111111', 50),
('Maya Khalil',       '70222222', 10),
('Karim Nassar',      '70333333', 20),
('Sara Mansour',      '70444444', 0),
('Omar Itani',        '70555555', 15);

---------------------------------------------------
-- Sample Orders, OrderLines and Payments
-- These are consistent with stock and prices above.
---------------------------------------------------

-- Order 1
INSERT INTO Orders (order_id, customer_id, employee_id, total_amount, discount_amount, created_at) VALUES
(1, 1, 2, 124.98, 5.00, '2025-11-30 10:15:00');
-- 2 x Running Shoes (59.99) + 1 x Water Bottle (10.00) = 129.98 - 5.00 = 124.98
INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES
(1, 1, 2, 119.98),
(1, 6, 1, 10.00);
INSERT INTO Payments (order_id, payment_method, amount, payment_date) VALUES
(1, 'Card', 124.98, '2025-11-30 10:16:00');

-- Order 2
INSERT INTO Orders (order_id, customer_id, employee_id, total_amount, discount_amount, created_at) VALUES
(2, 2, 2, 75.50, 0.00, '2025-12-01 14:30:00');
-- 1 x Yoga Mat (20.00) + 1 x Football (25.50) + 2 x Gym Gloves (15.00) = 75.50
INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES
(2, 2, 1, 20.00),
(2, 3, 1, 25.50),
(2, 7, 2, 30.00);
INSERT INTO Payments (order_id, payment_method, amount, payment_date) VALUES
(2, 'Cash', 75.50, '2025-12-01 14:31:00');

-- Order 3
INSERT INTO Orders (order_id, customer_id, employee_id, total_amount, discount_amount, created_at) VALUES
(3, 3, 2, 92.00, 10.00, '2025-12-02 11:05:00');
-- 1 x Tennis Racket (80.00) + 4 x Socks (5.50) = 102.00 - 10.00 = 92.00
INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES
(3, 5, 1, 80.00),
(3, 8, 4, 22.00);
INSERT INTO Payments (order_id, payment_method, amount, payment_date) VALUES
(3, 'Card', 92.00, '2025-12-02 11:06:00');

-- Order 4
INSERT INTO Orders (order_id, customer_id, employee_id, total_amount, discount_amount, created_at) VALUES
(4, 4, 2, 84.90, 0.00, '2025-12-02 17:45:00');
-- 1 x Jersey (39.90) + 1 x Hoodie (45.00) = 84.90
INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES
(4, 4, 1, 39.90),
(4, 9, 1, 45.00);
INSERT INTO Payments (order_id, payment_method, amount, payment_date) VALUES
(4, 'Cash', 84.90, '2025-12-02 17:46:00');

-- Order 5
INSERT INTO Orders (order_id, customer_id, employee_id, total_amount, discount_amount, created_at) VALUES
(5, 5, 2, 70.00, 0.00, '2025-12-03 09:20:00');
-- 1 x Resistance Band Set (30.00) + 2 x Yoga Mat (20.00) = 70.00
INSERT INTO OrderLines (order_id, product_id, quantity, line_total) VALUES
(5, 10, 1, 30.00),
(5, 2, 2, 40.00);
INSERT INTO Payments (order_id, payment_method, amount, payment_date) VALUES
(5, 'Card', 70.00, '2025-12-03 09:21:00');

---------------------------------------------------
-- Adjust stock to account for sales above
---------------------------------------------------
UPDATE Products SET quantity_on_hand = quantity_on_hand - 2 WHERE product_id = 1;  -- shoes
UPDATE Products SET quantity_on_hand = quantity_on_hand - 3 WHERE product_id = 2;  -- yoga mat
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 3;  -- football
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 4;  -- jersey
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 5;  -- racket
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 6;  -- bottle
UPDATE Products SET quantity_on_hand = quantity_on_hand - 2 WHERE product_id = 7;  -- gloves
UPDATE Products SET quantity_on_hand = quantity_on_hand - 4 WHERE product_id = 8;  -- socks
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 9;  -- hoodie
UPDATE Products SET quantity_on_hand = quantity_on_hand - 1 WHERE product_id = 10; -- bands
