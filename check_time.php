<?php
$conn = new mysqli('localhost', 'root', '', 'monitoring_api');
$result = $conn->query('SELECT NOW() as mysql_time, CURTIME() as mysql_curtime');
$row = $result->fetch_assoc();
echo "MySQL NOW(): " . $row['mysql_time'] . "\n";
echo "MySQL TIME: " . $row['mysql_curtime'] . "\n";
echo "PHP date(): " . date('Y-m-d H:i:s') . "\n";
echo "PHP time(): " . date('H:i:s') . "\n";

// Cek OTP expiry vs NOW
$result2 = $conn->query("SELECT otp_expiry, NOW() as now, (otp_expiry > NOW()) as is_valid FROM user WHERE id = 1");
$row2 = $result2->fetch_assoc();
echo "\nOTP Expiry: " . $row2['otp_expiry'] . "\n";
echo "MySQL NOW: " . $row2['now'] . "\n";
echo "Is Valid: " . ($row2['is_valid'] ? 'YES' : 'NO') . "\n";
$conn->close();
?>
