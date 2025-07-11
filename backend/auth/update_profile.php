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

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->name) || empty($data->phone)) {
    sendResponse(false, "Name and phone are required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Update user profile
    $query = "UPDATE users SET 
              name = :name, 
              phone = :phone, 
              job_category = :job_category, 
              experience = :experience, 
              province = :province,
              updated_at = CURRENT_TIMESTAMP
              WHERE id = :user_id";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":name", $data->name);
    $stmt->bindParam(":phone", $data->phone);
    $stmt->bindParam(":job_category", isset($data->job_category) ? $data->job_category : null);
    $stmt->bindParam(":experience", isset($data->experience) ? $data->experience : null);
    $stmt->bindParam(":province", isset($data->province) ? $data->province : null);
    $stmt->bindParam(":user_id", $user_data->user_id);

    if ($stmt->execute()) {
        // Get updated user data
        $user_query = "SELECT id, name, email, phone, user_type, job_category, experience, province, created_at 
                       FROM users WHERE id = :user_id";
        $user_stmt = $db->prepare($user_query);
        $user_stmt->bindParam(":user_id", $user_data->user_id);
        $user_stmt->execute();
        $user = $user_stmt->fetch(PDO::FETCH_ASSOC);

        sendResponse(true, "Profile updated successfully.", array("user" => $user));
    } else {
        sendResponse(false, "Update failed.", null, 500);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
