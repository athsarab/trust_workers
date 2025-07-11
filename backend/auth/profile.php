<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../includes/auth_middleware.php';

// Only allow GET method
if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Validate authentication
$user_data = requireAuth();

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Get user profile
    $query = "SELECT id, name, email, phone, user_type, job_category, experience, province, created_at 
              FROM users WHERE id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_data->user_id);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        sendResponse(true, "Profile retrieved successfully.", array("user" => $user));
    } else {
        sendResponse(false, "User not found.", null, 404);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
