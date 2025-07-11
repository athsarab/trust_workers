<?php
require_once '../includes/cors.php';
require_once '../includes/auth_middleware.php';

// Only allow POST method
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendResponse(false, "Method not allowed", null, 405);
}

// Validate authentication
$user_data = requireAuth();

// In a real application, you might want to invalidate the token in the database
// For this simple implementation, we'll just send a success response
sendResponse(true, "Logout successful.");
?>
