<?php
// Simple JWT implementation without external dependencies

class JWTHandler {
    private $secret_key = "your-super-secret-jwt-key-change-this-in-production-2024";
    private $issuer = "trust-workers-app";
    private $audience = "trust-workers-users";
    private $issued_at;
    private $expiration_time;

    public function __construct() {
        $this->issued_at = time();
        $this->expiration_time = $this->issued_at + (24 * 60 * 60); // 24 hours
    }

    // Generate JWT token (using simple implementation)
    public function generateToken($user_id, $email) {
        return $this->generateSimpleToken($user_id, $email);
    }

    // Validate JWT token (using simple implementation)
    public function validateToken($token) {
        return $this->validateSimpleToken($token);
    }

    // Simple JWT implementation without external library
    public function generateSimpleToken($user_id, $email) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);
        $payload = json_encode([
            'user_id' => $user_id,
            'email' => $email,
            'exp' => $this->expiration_time,
            'iat' => $this->issued_at,
            'iss' => $this->issuer,
            'aud' => $this->audience
        ]);
        
        $base64Header = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
        $base64Payload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));
        
        $signature = hash_hmac('sha256', $base64Header . "." . $base64Payload, $this->secret_key, true);
        $base64Signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
        
        return $base64Header . "." . $base64Payload . "." . $base64Signature;
    }

    // Validate simple JWT token
    public function validateSimpleToken($token) {
        try {
            $parts = explode('.', $token);
            if (count($parts) !== 3) {
                return false;
            }

            list($header, $payload, $signature) = $parts;
            
            $valid_signature = hash_hmac('sha256', $header . "." . $payload, $this->secret_key, true);
            $valid_signature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($valid_signature));
            
            if (!hash_equals($signature, $valid_signature)) {
                return false;
            }

            $payload_data = json_decode(base64_decode(str_replace(['-', '_'], ['+', '/'], $payload)), true);
            
            if (!$payload_data || $payload_data['exp'] < time()) {
                return false;
            }

            // Return object with same structure as Firebase JWT library
            return (object) [
                'user_id' => $payload_data['user_id'],
                'email' => $payload_data['email']
            ];
        } catch (Exception $e) {
            return false;
        }
    }
}
?>
