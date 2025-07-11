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

// Get category from query parameter
$category = isset($_GET['category']) ? $_GET['category'] : '';

if (empty($category)) {
    sendResponse(false, "Category parameter is required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Get workers by category
    $query = "SELECT id, name, email, phone, user_type, job_category, experience, province, created_at 
              FROM users 
              WHERE user_type = 'worker' AND job_category = :category 
              ORDER BY created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":category", $category);
    $stmt->execute();

    $workers = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $workers[] = $row;
    }

    sendResponse(true, "Workers retrieved successfully.", array("workers" => $workers));

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
