<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../includes/auth_middleware.php';

// Only allow DELETE method
if ($_SERVER['REQUEST_METHOD'] !== 'DELETE') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Validate authentication
$user_data = requireAuth();

// Get job ID from query parameter
$job_id = isset($_GET['id']) ? $_GET['id'] : '';

if (empty($job_id)) {
    sendResponse(false, "Job ID parameter is required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Check if job exists and belongs to current user
    $check_query = "SELECT id FROM job_posts WHERE id = :job_id AND posted_by = :user_id";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(":job_id", $job_id);
    $check_stmt->bindParam(":user_id", $user_data->user_id);
    $check_stmt->execute();

    if ($check_stmt->rowCount() == 0) {
        sendResponse(false, "Job not found or access denied.", null, 404);
    }

    // Soft delete (set is_active to false)
    $query = "UPDATE job_posts SET is_active = 0, updated_at = CURRENT_TIMESTAMP WHERE id = :job_id";
    $stmt = $db->prepare($query);
    $stmt->bindParam(":job_id", $job_id);

    if ($stmt->execute()) {
        sendResponse(true, "Job deleted successfully.");
    } else {
        sendResponse(false, "Delete failed.", null, 500);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
