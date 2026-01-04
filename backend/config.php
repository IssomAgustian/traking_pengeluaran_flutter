<?php
// Database Configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');  // Change this to your DB username
define('DB_PASS', '');      // Change this to your DB password
define('DB_NAME', 'expense_tracker_db');

// Create connection
function getConnection() {
    $conn = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    // Check connection
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    // Set charset to UTF-8
    $conn->set_charset("utf8");
    
    return $conn;
}
?>