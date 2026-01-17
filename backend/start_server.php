<?php
// Simple PHP development server script
// Run this with: php start_server.php

$port = 8000;
$host = '0.0.0.0';

echo "Starting PHP development server on http://$host:$port\n";
echo "Use your LAN IP (e.g. http://192.168.1.10:$port) from devices\n";
echo "Press Ctrl+C to stop the server\n\n";

// Command to start PHP built-in server
$command = "php -S $host:$port -t .";

// Execute the command
system($command);
?>
