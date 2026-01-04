<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database configuration
include_once 'config.php';

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Create connection
$conn = getConnection();

// Function to get or create category ID
function getOrCreateCategoryId($conn, $categoryName, $type) {
    $categoryName = $conn->real_escape_string($categoryName);
    $type = $conn->real_escape_string($type);

    // Check if category exists
    $sql = "SELECT id FROM categories WHERE name = '$categoryName' AND type = '$type'";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        return $row['id'];
    } else {
        // Create new category
        $sql = "INSERT INTO categories (name, type, is_default) VALUES ('$categoryName', '$type', FALSE)";
        if ($conn->query($sql) === TRUE) {
            return $conn->insert_id;
        } else {
            return null;
        }
    }
}

// Function to get category name by ID
function getCategoryNameById($conn, $categoryId) {
    $categoryId = intval($categoryId);
    $sql = "SELECT name FROM categories WHERE id = $categoryId";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        $row = $result->fetch_assoc();
        return $row['name'];
    }
    return 'Lainnya';
}

// Handle GET request (Read all transactions)
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $sql = "SELECT t.*, c.name as category FROM transactions t LEFT JOIN categories c ON t.category_id = c.id ORDER BY t.date DESC";
    $result = $conn->query($sql);

    $transactions = array();

    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            // Replace category_id with category name for compatibility with Flutter app
            $transaction = $row;
            $transaction['category'] = $row['category'] ?? 'Lainnya';
            unset($transaction['category_id']); // Remove category_id to maintain compatibility
            $transactions[] = $transaction;
        }
    }

    echo json_encode($transactions);
}

$conn->close();
?>