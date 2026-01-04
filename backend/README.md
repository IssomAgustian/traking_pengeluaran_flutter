# Expense Tracker Backend API

This is the backend API for the Expense Tracker Flutter application.

## Requirements

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Web server (Apache/Nginx) with PHP support

## Setup Instructions

### 1. Database Setup

1. Create a MySQL database:
   ```sql
   CREATE DATABASE expense_tracker_db;
   ```

2. Import the database schema:
   ```sql
   USE expense_tracker_db;
   SOURCE database_schema.sql;
   ```

### 2. Configuration

1. Update the database credentials in `config.php`:
   ```php
   define('DB_HOST', 'localhost');
   define('DB_USER', 'your_db_username');
   define('DB_PASS', 'your_db_password');
   define('DB_NAME', 'expense_tracker_db');
   ```

### 3. API Endpoints

#### Transactions API
- `GET /read.php` - Get all transactions
- `POST /create.php` - Create a new transaction
- `POST /update.php` - Update an existing transaction
- `POST /delete.php` - Delete a transaction

#### Budgets API
- `GET /budgets/read.php` - Get all budgets
- `GET /budgets/read_by_month.php?month=YYYY-MM` - Get budgets for a specific month
- `POST /budgets/create.php` - Create a new budget
- `POST /budgets/update.php` - Update an existing budget
- `POST /budgets/delete.php` - Delete a budget

### 4. Running the API

Place all files in your web server's document root (e.g., htdocs for XAMPP) and access via:
```
http://localhost/expense_tracker_backend/
```

## API Request/Response Format

### Transaction Object
```json
{
  "id": 1,
  "title": "Gaji Bulan Ini",
  "amount": 5000000,
  "type": "INCOME",
  "category": "Gaji",
  "date": "2026-01-04 10:30:00"
}
```

### Budget Object
```json
{
  "id": 1,
  "category": "Makanan",
  "amount": 1000000,
  "month": "2026-01",
  "created_at": "2026-01-04 10:30:00"
}
```

## CORS Configuration

The API allows requests from any origin. For production, you should restrict this to your application's domain only.