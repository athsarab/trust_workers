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

    // Get job posts by category
    $query = "SELECT j.*, u.name as poster_name 
              FROM job_posts j 
              JOIN users u ON j.posted_by = u.id 
              WHERE j.is_active = 1 AND j.category = :category 
              ORDER BY j.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":category", $category);
    $stmt->execute();

    $jobs = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $jobs[] = $row;
    }

    sendResponse(true, "Jobs retrieved successfully.", array("jobs" => $jobs));

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
