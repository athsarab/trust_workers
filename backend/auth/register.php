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
if (empty($data->name) || empty($data->email) || empty($data->password) || empty($data->phone) || empty($data->user_type)) {
    sendResponse(false, "Incomplete data. Please fill all required fields.", null, 400);
}

// Validate email format
if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
    sendResponse(false, "Invalid email format.", null, 400);
}

// Validate user type
if (!in_array($data->user_type, ['normal', 'worker'])) {
    sendResponse(false, "Invalid user type.", null, 400);
}

try {
    // Database connection
    $database = new Database();
    $db = $database->getConnection();

    // Check if email already exists
    $check_query = "SELECT id FROM users WHERE email = :email";
    $check_stmt = $db->prepare($check_query);
    $check_stmt->bindParam(":email", $data->email);
    $check_stmt->execute();

    if ($check_stmt->rowCount() > 0) {
        sendResponse(false, "Email already exists.", null, 409);
    }

    // Hash password
    $hashed_password = password_hash($data->password, PASSWORD_DEFAULT);

    // Insert user
    $query = "INSERT INTO users (name, email, password, phone, user_type, job_category, experience, province) 
              VALUES (:name, :email, :password, :phone, :user_type, :job_category, :experience, :province)";
    
    $stmt = $db->prepare($query);
    
    // Prepare variables for binding (required for bindParam)
    $job_category = isset($data->job_category) ? $data->job_category : null;
    $experience = isset($data->experience) ? $data->experience : null;
    $province = isset($data->province) ? $data->province : null;
    
    // Bind values
    $stmt->bindParam(":name", $data->name);
    $stmt->bindParam(":email", $data->email);
    $stmt->bindParam(":password", $hashed_password);
    $stmt->bindParam(":phone", $data->phone);
    $stmt->bindParam(":user_type", $data->user_type);
    $stmt->bindParam(":job_category", $job_category);
    $stmt->bindParam(":experience", $experience);
    $stmt->bindParam(":province", $province);

    if ($stmt->execute()) {
        // Get the created user
        $user_id = $db->lastInsertId();
        
        // Generate JWT token
        $jwt_handler = new JWTHandler();
        $token = $jwt_handler->generateSimpleToken($user_id, $data->email);

        // Get user data to return
        $user_query = "SELECT id, name, email, phone, user_type, job_category, experience, province, created_at FROM users WHERE id = :user_id";
        $user_stmt = $db->prepare($user_query);
        $user_stmt->bindParam(":user_id", $user_id);
        $user_stmt->execute();
        $user = $user_stmt->fetch(PDO::FETCH_ASSOC);

        sendResponse(true, "User registered successfully.", array(
            "token" => $token,
            "user" => $user
        ), 201);
    } else {
        sendResponse(false, "Registration failed.", null, 500);
    }

} catch (PDOException $exception) {
    sendResponse(false, "Database error: " . $exception->getMessage(), null, 500);
}
?>
