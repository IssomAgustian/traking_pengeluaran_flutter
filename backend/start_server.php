<?php
// Simple PHP development server script
// Run this with: php start_server.php

$port = 8000;
$host = 'localhost';

echo "Starting PHP development server on http://$host:$port\n";
echo "Press Ctrl+C to stop the server\n\n";

// Command to start PHP built-in server
$command = "php -S $host:$port -t .";

// Execute the command
system($command);
?>