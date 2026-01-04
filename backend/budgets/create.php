<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['category']) && isset($input['amount']) && isset($input['month'])) {
        $category = $conn->real_escape_string($input['category']);
        $amount = floatval($input['amount']);
        $month = $conn->real_escape_string($input['month']);
        $type = 'EXPENSE'; // Budgets are typically for expenses
        $created_at = isset($input['created_at']) ? $conn->real_escape_string($input['created_at']) : date('Y-m-d H:i:s');
        
        // Get or create category ID
        $categoryId = getOrCreateCategoryId($conn, $category, $type);
        if ($categoryId === null) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error creating category: " . $conn->error));
            exit();
        }
        
        $sql = "INSERT INTO budgets (category_id, amount, month, created_at) VALUES ($categoryId, $amount, '$month', '$created_at')";
        
        if ($conn->query($sql) === TRUE) {
            echo json_encode(array("success" => true, "message" => "Budget created successfully", "id" => $conn->insert_id));
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error: " . $conn->error));
        }
    } else {
        http_response_code(400);
        echo json_encode(array("success" => false, "message" => "Missing required fields"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method not allowed"));
}

$conn->close();
?>