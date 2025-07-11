<?php
// Test database connection
header('Content-Type: application/json');

try {
    require_once 'config/database.php';
    
    $database = new Database();
    $db = $database->getConnection();
    
    if ($db) {
        // Test query to check if tables exist
        $query = "SHOW TABLES";
        $stmt = $db->prepare($query);
        $stmt->execute();
        $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
        
        echo json_encode([
            'success' => true,
            'message' => 'Database connection successful',
            'tables_found' => $tables,
            'table_count' => count($tables)
        ], JSON_PRETTY_PRINT);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to connect to database'
        ], JSON_PRETTY_PRINT);
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => 'Database error: ' . $e->getMessage()
    ], JSON_PRETTY_PRINT);
}
?>
