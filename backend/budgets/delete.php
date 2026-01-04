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

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['id'])) {
        $id = intval($input['id']);
        
        $sql = "DELETE FROM budgets WHERE id=$id";
        
        if ($conn->query($sql) === TRUE) {
            if ($conn->affected_rows > 0) {
                echo json_encode(array("success" => true, "message" => "Budget deleted successfully"));
            } else {
                http_response_code(404);
                echo json_encode(array("success" => false, "message" => "Budget not found"));
            }
        } else {
            http_response_code(500);
            echo json_encode(array("success" => false, "message" => "Error: " . $conn->error));
        }
    } else {
        http_response_code(400);
        echo json_encode(array("success" => false, "message" => "Missing ID"));
    }
} else {
    http_response_code(405);
    echo json_encode(array("success" => false, "message" => "Method not allowed"));
}

$conn->close();
?>