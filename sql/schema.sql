CREATE DATABASE IF NOT EXISTS profit_store;
USE profit_store;

-- USERS (employees/admins)
CREATE TABLE IF NOT EXISTS Users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role ENUM('Admin','Employee') NOT NULL DEFAULT 'Employee'
);

-- SUPPLIERS
CREATE TABLE IF NOT EXISTS Suppliers (
  supplier_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100)
);

-- CATEGORIES
CREATE TABLE IF NOT EXISTS Categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- BRANDS
CREATE TABLE IF NOT EXISTS Brands (
  brand_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL
);

-- PRODUCTS
CREATE TABLE IF NOT EXISTS Products (
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
CREATE TABLE IF NOT EXISTS Customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(100) NOT NULL,
  phone VARCHAR(20),
  loyalty_points INT DEFAULT 0
);

-- ORDERS
CREATE TABLE IF NOT EXISTS Orders (
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
CREATE TABLE IF NOT EXISTS OrderLines (
  order_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  line_total DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (order_id, product_id),
  CONSTRAINT fk_ol_order FOREIGN KEY (order_id) REFERENCES Orders(order_id),
  CONSTRAINT fk_ol_product FOREIGN KEY (product_id) REFERENCES Products(product_id)
);

-- PAYMENTS
CREATE TABLE IF NOT EXISTS Payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  order_id INT NOT NULL,
  payment_method ENUM('Cash','Card') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,
  payment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pay_order FOREIGN KEY (order_id) REFERENCES Orders(order_id)
);

-- BASIC SEED DATA
INSERT INTO Users (username, password_hash, role)
VALUES ('admin', '$2b$10$9nTvpEvn4F9rmpmLBdXG0ePBvHbq5lZfbYVIOpNskWtexz8pDkUE6', 'Admin')
ON DUPLICATE KEY UPDATE username = username;
/*
Password for admin above is: admin123
( bcrypt hash – no need to change unless you want to )
*/

INSERT INTO Suppliers(name,email) VALUES ('Main Supplier','supplier@example.com')
ON DUPLICATE KEY UPDATE name=name;

INSERT INTO Categories(name) VALUES ('Footwear'),('Gym Equipment'),('Clothing')
ON DUPLICATE KEY UPDATE name=name;

INSERT INTO Brands(name) VALUES ('Nike'),('Adidas'),('ProFit')
ON DUPLICATE KEY UPDATE name=name;

-- Example products
INSERT INTO Products(category_id, brand_id, supplier_id, name, unit_price, quantity_on_hand)
VALUES
(1,1,1,'Running Shoes',59.99,40),
(2,3,1,'Yoga Mat',20.00,100)
ON DUPLICATE KEY UPDATE name=name;
