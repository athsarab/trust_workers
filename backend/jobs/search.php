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

// Get search query from query parameter
$search_query = isset($_GET['q']) ? $_GET['q'] : '';

if (empty($search_query)) {
    sendResponse(false, "Search query parameter 'q' is required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Search in title, description, and category
    $query = "SELECT j.*, u.name as poster_name 
              FROM job_posts j 
              JOIN users u ON j.posted_by = u.id 
              WHERE j.is_active = 1 AND (
                  j.title LIKE :search OR 
                  j.description LIKE :search OR 
                  j.category LIKE :search OR
                  j.district LIKE :search
              )
              ORDER BY j.created_at DESC";
    
    $search_param = "%" . $search_query . "%";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":search", $search_param);
    $stmt->execute();

    $jobs = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $jobs[] = $row;
    }

    sendResponse(true, "Search completed.", array("jobs" => $jobs));

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
