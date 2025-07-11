<?php
require_once '../includes/cors.php';
require_once '../includes/auth_middleware.php';

// Test authentication
header('Content-Type: application/json');

// Debug information
$debug_info = [
    'method' => $_SERVER['REQUEST_METHOD'],
    'headers' => [],
    'auth_result' => null,
    'error' => null
];

// Get all headers for debugging
if (function_exists('getallheaders')) {
    $debug_info['headers'] = getallheaders();
} else {
    foreach ($_SERVER as $name => $value) {
        if (substr($name, 0, 5) == 'HTTP_') {
            $debug_info['headers'][str_replace(' ', '-', ucwords(strtolower(str_replace('_', ' ', substr($name, 5)))))] = $value;
        }
    }
}

try {
    $user_data = authenticateRequest();
    if ($user_data) {
        $debug_info['auth_result'] = 'success';
        $debug_info['user_data'] = $user_data;
        echo json_encode([
            'success' => true,
            'message' => 'Authentication successful',
            'debug' => $debug_info
        ], JSON_PRETTY_PRINT);
    } else {
        $debug_info['auth_result'] = 'failed';
        echo json_encode([
            'success' => false,
            'message' => 'Authentication failed',
            'debug' => $debug_info
        ], JSON_PRETTY_PRINT);
    }
} catch (Exception $e) {
    $debug_info['error'] = $e->getMessage();
    echo json_encode([
        'success' => false,
        'message' => 'Error: ' . $e->getMessage(),
        'debug' => $debug_info
    ], JSON_PRETTY_PRINT);
}
?>
