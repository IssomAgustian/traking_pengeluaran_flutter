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

// Handle GET request (Read all categories)
if ($_SERVER['REQUEST_METHOD'] == 'GET') {
    $sql = "SELECT * FROM categories ORDER BY type, name";
    $result = $conn->query($sql);
    
    $categories = array();
    
    if ($result->num_rows > 0) {
        while($row = $result->fetch_assoc()) {
            $categories[] = $row;
        }
    }
    
    echo json_encode($categories);
}

// Handle POST request (Create new category)
elseif ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['name']) && isset($input['type'])) {
        $name = $conn->real_escape_string($input['name']);
        $type = $conn->real_escape_string($input['type']);
        $icon = isset($input['icon']) ? $conn->real_escape_string($input['icon']) : null;
        $color = isset($input['color']) ? $conn->real_escape_string($input['color']) : '#000000';
        
        // Check if category already exists
        $sql = "SELECT id FROM categories WHERE name = '$name' AND type = '$type'";
        $result = $conn->query($sql);
        
        if ($result->num_rows > 0) {
            http_response_code(409); // Conflict - category already exists
            echo json_encode(array("success" => false, "message" => "Category already exists"));
        } else {
            $sql = "INSERT INTO categories (name, type, icon, color, is_default) VALUES ('$name', '$type', '$icon', '$color', FALSE)";
            
            if ($conn->query($sql) === TRUE) {
                echo json_encode(array("success" => true, "message" => "Category created successfully", "id" => $conn->insert_id));
            } else {
                http_response_code(500);
                echo json_encode(array("success" => false, "message" => "Error: " . $conn->error));
            }
        }
    } else {
        http_response_code(400);
        echo json_encode(array("success" => false, "message" => "Missing required fields"));
    }
}

$conn->close();
?>