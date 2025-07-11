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

    // Search workers by name, job category, or province
    $query = "SELECT id, name, email, phone, user_type, job_category, experience, province, created_at 
              FROM users 
              WHERE user_type = 'worker' AND (
                  name LIKE :search OR 
                  job_category LIKE :search OR 
                  province LIKE :search OR
                  experience LIKE :search
              )
              ORDER BY created_at DESC";
    
    $search_param = "%" . $search_query . "%";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":search", $search_param);
    $stmt->execute();

    $workers = array();
    while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
        $workers[] = $row;
    }

    sendResponse(true, "Search completed.", array("workers" => $workers));

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
