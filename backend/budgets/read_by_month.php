<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

// Include database configuration
include_once '../config.php';

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

if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    if (isset($_GET['month'])) {
        $month = $conn->real_escape_string($_GET['month']);
        $sql = "SELECT b.*, c.name as category FROM budgets b LEFT JOIN categories c ON b.category_id = c.id WHERE b.month = '$month'";
        $result = $conn->query($sql);
        
        $budgets = array();
        
        if ($result->num_rows > 0) {
            while($row = $result->fetch_assoc()) {
                // Replace category_id with category name for compatibility with Flutter app
                $budget = $row;
                $budget['category'] = $row['category'] ?? 'Lainnya';
                unset($budget['category_id']); // Remove category_id to maintain compatibility
                $budgets[] = $budget;
            }
        }
        
        echo json_encode($budgets);
    } else {
        http_response_code(400);
        echo json_encode(array("success" => false, "message" => "Month parameter is required"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method not allowed"));
}

$conn->close();
?>