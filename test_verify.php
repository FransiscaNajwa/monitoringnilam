<?php
$conn = new mysqli('localhost', 'root', '', 'monitoring_api');

$userId = 1;
$otp = "660420";

echo "Testing OTP verification query:\n";
echo "User ID: $userId\n";
echo "OTP: $otp\n\n";

$stmt = $conn->prepare("SELECT id FROM user WHERE id = ? AND otp_code = ? AND otp_expiry > NOW()");
$stmt->bind_param("is", $userId, $otp);
$stmt->execute();
$result = $stmt->get_result();

echo "Query result rows: " . $result->num_rows . "\n";

if ($result->num_rows > 0) {
    echo "✅ OTP VALID!\n";
} else {
    echo "❌ OTP INVALID atau EXPIRED\n\n";
    
    // Debug - cek tanpa waktu
    $stmt2 = $conn->prepare("SELECT id, otp_code, otp_expiry FROM user WHERE id = ? AND otp_code = ?");
    $stmt2->bind_param("is", $userId, $otp);
    $stmt2->execute();
    $result2 = $stmt2->get_result();
    
    if ($result2->num_rows > 0) {
        $row = $result2->fetch_assoc();
        echo "OTP cocok tapi expired!\n";
        echo "OTP Expiry: " . $row['otp_expiry'] . "\n";
        echo "Current Time: " . date('Y-m-d H:i:s') . "\n";
    } else {
        echo "OTP tidak cocok di database\n";
    }
}

$conn->close();
?>
