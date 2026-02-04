<?php
$conn = new mysqli('localhost', 'root', '', 'monitoring_api');
$result = $conn->query('SELECT id, username, email, otp_code, otp_expiry FROM user WHERE id = 1');
$row = $result->fetch_assoc();
echo "User ID: " . $row['id'] . "\n";
echo "Username: " . $row['username'] . "\n";
echo "Current Email: " . $row['email'] . "\n";
echo "OTP Code: " . $row['otp_code'] . "\n";
echo "OTP Expiry: " . $row['otp_expiry'] . "\n";
echo "Current Time: " . date('Y-m-d H:i:s') . "\n";
$conn->close();
?>
