<?php
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, OPTIONS");
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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['id']) && isset($input['title']) && isset($input['amount']) && isset($input['type']) && isset($input['category'])) {
        $id = intval($input['id']);
        $title = $conn->real_escape_string($input['title']);
        $amount = floatval($input['amount']);
        $type = $conn->real_escape_string($input['type']);
        $category = $conn->real_escape_string($input['category']);
        $date = isset($input['date']) ? $conn->real_escape_string($input['date']) : date('Y-m-d H:i:s');
        
        // Get or create category ID
        $categoryId = getOrCreateCategoryId($conn, $category, $type);
        if ($categoryId === null) {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error creating category: " . $conn->error));
            exit();
        }
        
        $sql = "UPDATE transactions SET title='$title', amount=$amount, type='$type', category_id=$categoryId, date='$date' WHERE id=$id";
        
        if ($conn->query($sql) === TRUE) {
            if ($conn->affected_rows > 0) {
                echo json_encode(array("success" => true, "message" => "Transaction updated successfully"));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "Transaction not found"));
            }
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