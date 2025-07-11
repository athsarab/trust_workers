<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../includes/auth_middleware.php';

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Validate authentication
$user_data = requireAuth();

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->title) || empty($data->job_type) || empty($data->category) || 
    empty($data->district) || empty($data->description) || empty($data->contact_phone)) {
    sendResponse(false, "All fields are required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Insert job post
    $query = "INSERT INTO job_posts (title, job_type, category, district, description, contact_phone, posted_by) 
              VALUES (:title, :job_type, :category, :district, :description, :contact_phone, :posted_by)";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":title", $data->title);
    $stmt->bindParam(":job_type", $data->job_type);
    $stmt->bindParam(":category", $data->category);
    $stmt->bindParam(":district", $data->district);
    $stmt->bindParam(":description", $data->description);
    $stmt->bindParam(":contact_phone", $data->contact_phone);
    $stmt->bindParam(":posted_by", $user_data->user_id);

    if ($stmt->execute()) {
        $job_id = $db->lastInsertId();
        
        // Get the created job
        $job_query = "SELECT j.*, u.name as poster_name 
                      FROM job_posts j 
                      JOIN users u ON j.posted_by = u.id 
                      WHERE j.id = :job_id";
        $job_stmt = $db->prepare($job_query);
        $job_stmt->bindParam(":job_id", $job_id);
        $job_stmt->execute();
        $job = $job_stmt->fetch(PDO::FETCH_ASSOC);

        sendResponse(true, "Job post created successfully.", array("job" => $job), 201);
    } else {
        sendResponse(false, "Failed to create job post.", null, 500);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
