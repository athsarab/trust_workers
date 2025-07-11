<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../includes/auth_middleware.php';

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->email)) {
    sendResponse(false, "Email is required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Check if email exists
    $query = "SELECT id, email FROM users WHERE email = :email";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":email", $data->email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        // In a real application, you would:
        // 1. Generate a unique reset token
        // 2. Store it in the database with expiration
        // 3. Send an email with reset link
        
        // For this demo, we'll just return success
        sendResponse(true, "Password reset instructions have been sent to your email.");
    } else {
        sendResponse(false, "Email not found.", null, 404);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
