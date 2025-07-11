<?php
require_once '../config/jwt.php';

function authenticateRequest() {
    // Get headers - handle different PHP versions and environments
    $headers = [];
    if (function_exists('getallheaders')) {
        $headers = getallheaders();
    } else {
        // Fallback for environments where getallheaders() doesn't exist
        foreach ($_SERVER as $name => $value) {
            if (substr($name, 0, 5) == 'HTTP_') {
                $headers[str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
            }
        }
    }
    
    // Check for Authorization header (case insensitive)
    $auth_header = null;
    foreach ($headers as $key => $value) {
        if (strtolower($key) === 'authorization') {
            $auth_header = $value;
            break;
        }
    }
    
    if (!$auth_header) {
        return false;
    }
    
    // Extract token from "Bearer token" format
    if (strpos($auth_header, 'Bearer ') === 0) {
        $token = substr($auth_header, 7); // Remove "Bearer " prefix
    } else {
        $token = $auth_header; // Use as-is if no Bearer prefix
    }
    
    if (empty($token)) {
        return false;
    }
    
    $jwt_handler = new JWTHandler();
    $decoded = $jwt_handler->validateToken($token);
    
    if ($decoded === false) {
        return false;
    }
    
    return $decoded;
}

function requireAuth() {
    $user_data = authenticateRequest();
    
    if ($user_data === false) {
        http_response_code(401);
        echo json_encode(array(
            "success" => false,
            "message" => "Access denied. Invalid or missing token."
        ));
        exit();
    }
    
    return $user_data;
}

function sendResponse($success, $message, $data = null, $http_code = 200) {
    http_response_code($http_code);
    $response = array(
        "success" => $success,
        "message" => $message
    );
    
    if ($data !== null) {
        if (is_array($data)) {
            foreach ($data as $key => $value) {
                $response[$key] = $value;
            }
        } else {
            $response['data'] = $data;
        }
    }
    
    echo json_encode($response);
    exit();
}
?>
