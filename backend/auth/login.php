<?php
require_once '../includes/cors.php';
require_once '../config/database.php';
require_once '../config/jwt.php';
require_once '../includes/auth_middleware.php';

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Get posted data
$data = json_decode(file_get_contents("php://input"));

// Validate required fields
if (empty($data->email) || empty($data->password)) {
    sendResponse(false, "Email and password are required.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Find user by email
    $query = "SELECT id, name, email, password, phone, user_type, job_category, experience, province, created_at 
              FROM users WHERE email = :email";
    
    $stmt = $db->prepare($query);
    $stmt->bindParam(":email", $data->email);
    $stmt->execute();

    if ($stmt->rowCount() > 0) {
        $user = $stmt->fetch(PDO::FETCH_ASSOC);
        
        // Verify password
        if (password_verify($data->password, $user['password'])) {
            // Generate JWT token
            $jwt_handler = new JWTHandler();
            $token = $jwt_handler->generateSimpleToken($user['id'], $user['email']);

            // Remove password from user data
            unset($user['password']);

            sendResponse(true, "Login successful.", array(
                "token" => $token,
                "user" => $user
            ));
        } else {
            sendResponse(false, "Invalid password.", null, 401);
        }
    } else {
        sendResponse(false, "User not found.", null, 404);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
