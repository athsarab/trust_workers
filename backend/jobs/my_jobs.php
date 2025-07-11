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

// Get user_id from query parameter (optional, defaults to current user)
$user_id = isset($_GET['user_id']) ? $_GET['user_id'] : $user_data->user_id;

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Get job posts by user
    $query = "SELECT j.*, u.name as poster_name 
              FROM job_posts j 
              JOIN users u ON j.posted_by = u.id 
              WHERE j.posted_by = :user_id 
              ORDER BY j.created_at DESC";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":user_id", $user_id);
    $stmt->execute();

    $jobs = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $jobs[] = $row;
    }

    sendResponse(true, "User jobs retrieved successfully.", array("jobs" => $jobs));

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
