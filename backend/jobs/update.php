<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../includes/auth_middleware.php';

// Only allow PUT method
if ($_SERVER['REQUEST_METHOD'] !== 'PUT') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Validate authentication
$user_data = requireAuth();

// Get job ID from query parameter
$job_id = isset($_GET['id']) ? $_GET['id'] : '';

if (empty($job_id)) {
    sendResponse(false, "Job ID parameter is required.", null, 400);
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

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

    // Build update query dynamically
    $update_fields = array();
    $params = array();

    if (isset($data->title)) {
        $update_fields[] = "title = :title";
        $params[':title'] = $data->title;
    }
    if (isset($data->job_type)) {
        $update_fields[] = "job_type = :job_type";
        $params[':job_type'] = $data->job_type;
    }
    if (isset($data->category)) {
        $update_fields[] = "category = :category";
        $params[':category'] = $data->category;
    }
    if (isset($data->district)) {
        $update_fields[] = "district = :district";
        $params[':district'] = $data->district;
    }
    if (isset($data->description)) {
        $update_fields[] = "description = :description";
        $params[':description'] = $data->description;
    }
    if (isset($data->contact_phone)) {
        $update_fields[] = "contact_phone = :contact_phone";
        $params[':contact_phone'] = $data->contact_phone;
    }
    if (isset($data->is_active)) {
        $update_fields[] = "is_active = :is_active";
        $params[':is_active'] = $data->is_active;
    }

    if (empty($update_fields)) {
        sendResponse(false, "No fields to update.", null, 400);
    }

    $update_fields[] = "updated_at = CURRENT_TIMESTAMP";
    $params[':job_id'] = $job_id;

    $query = "UPDATE job_posts SET " . implode(", ", $update_fields) . " WHERE id = :job_id";
    $stmt = $db->prepare($query);

    foreach ($params as $key => $value) {
        $stmt->bindValue($key, $value);
    }

    if ($stmt->execute()) {
        // Get updated job
        $job_query = "SELECT j.*, u.name as poster_name 
                      FROM job_posts j 
                      JOIN users u ON j.posted_by = u.id 
                      WHERE j.id = :job_id";
        $job_stmt = $db->prepare($job_query);
        $job_stmt->bindParam(":job_id", $job_id);
        $job_stmt->execute();
        $job = $job_stmt->fetch(PDO::FETCH_ASSOC);

        sendResponse(true, "Job updated successfully.", array("job" => $job));
    } else {
        sendResponse(false, "Update failed.", null, 500);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
