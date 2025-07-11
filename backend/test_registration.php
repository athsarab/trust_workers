<?php
// Test script for registration endpoint
header('Content-Type: application/json');

$test_user = [
    'name' => 'Test User',
    'email' => 'test@example.com',
    'password' => 'password123',
    'phone' => '+1234567890',
    'user_type' => 'normal'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost/trust_workers_api/auth/register.php');
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($test_user));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$http_code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo json_encode([
    'http_code' => $http_code,
    'response' => json_decode($response, true),
    'raw_response' => $response
], JSON_PRETTY_PRINT);
?>
