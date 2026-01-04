-- Database Schema for Expense Tracker App

-- Create database
CREATE DATABASE IF NOT EXISTS expense_tracker_db;
USE expense_tracker_db;

-- Table for users (if needed for future authentication)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Table for categories
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('INCOME', 'EXPENSE') NOT NULL,
    icon VARCHAR(50) DEFAULT NULL, -- Optional icon for category
    color VARCHAR(7) DEFAULT '#000000', -- Optional color for category
    is_default BOOLEAN DEFAULT FALSE, -- Whether this is a default category
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table for transactions
CREATE TABLE transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id INT,
    user_id INT,
    date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    notes TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table for budgets
CREATE TABLE budgets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    user_id INT,
    amount DECIMAL(10, 2) NOT NULL,
    month VARCHAR(7) NOT NULL, -- Format: YYYY-MM
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Table for recurring transactions (for future features)
CREATE TABLE recurring_transactions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    type ENUM('INCOME', 'EXPENSE') NOT NULL,
    category_id INT,
    user_id INT,
    frequency ENUM('DAILY', 'WEEKLY', 'MONTHLY', 'YEARLY') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert default categories
INSERT INTO categories (name, type, is_default) VALUES
('Makanan', 'EXPENSE', TRUE),
('Transportasi', 'EXPENSE', TRUE),
('Hiburan', 'EXPENSE', TRUE),
('Kesehatan', 'EXPENSE', TRUE),
('Pendidikan', 'EXPENSE', TRUE),
('Belanja', 'EXPENSE', TRUE),
('Lainnya', 'EXPENSE', TRUE),
('Gaji', 'INCOME', TRUE),
('Bonus', 'INCOME', TRUE),
('Investasi', 'INCOME', TRUE),
('Lainnya', 'INCOME', TRUE);

-- Insert some default transactions
INSERT INTO transactions (title, amount, type, category_id, date) VALUES
('Gaji Bulan Ini', 5000000, 'INCOME',
    (SELECT id FROM categories WHERE name = 'Gaji' AND type = 'INCOME'), NOW()),
('Makan Siang', 25000, 'EXPENSE',
    (SELECT id FROM categories WHERE name = 'Makanan' AND type = 'EXPENSE'), NOW()),
('Transportasi', 15000, 'EXPENSE',
    (SELECT id FROM categories WHERE name = 'Transportasi' AND type = 'EXPENSE'), NOW());

-- Insert some default budgets
INSERT INTO budgets (category_id, amount, month) VALUES
((SELECT id FROM categories WHERE name = 'Makanan' AND type = 'EXPENSE'), 1000000, '2026-01'),
((SELECT id FROM categories WHERE name = 'Transportasi' AND type = 'EXPENSE'), 500000, '2026-01'),
((SELECT id FROM categories WHERE name = 'Hiburan' AND type = 'EXPENSE'), 300000, '2026-01');

-- Create indexes for better performance
CREATE INDEX idx_transactions_date ON transactions(date);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_category ON transactions(category_id);
CREATE INDEX idx_budgets_month ON budgets(month);
CREATE INDEX idx_budgets_category ON budgets(category_id);