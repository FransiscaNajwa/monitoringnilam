<?php
/**
 * EMAIL OTP VERIFICATION - BACKEND SAMPLE CODE
 * 
 * Add this to your monitoring_api/index.php or create separate handler
 */

// ==================== OTP REQUEST HANDLER ====================

if ($endpoint == 'auth' && $action == 'request-email-otp') {
    header('Content-Type: application/json');
    
    // Get input data
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    $user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;
    $new_email = isset($data['new_email']) ? trim($data['new_email']) : '';
    
    // Validate input
    if ($user_id <= 0) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid user ID'
        ]);
        exit;
    }
    
    if (empty($new_email) || !filter_var($new_email, FILTER_VALIDATE_EMAIL)) {
        echo json_encode([
            'success' => false,
            'message' => 'Invalid email address'
        ]);
        exit;
    }
    
    // Generate 6-digit OTP
    $otp = sprintf("%06d", mt_rand(0, 999999));
    
    // Set expiry time (10 minutes from now)
    $expires_at = date('Y-m-d H:i:s', strtotime('+10 minutes'));
    
    // Store OTP in database
    try {
        // Delete old OTP for this user/email combination
        $stmt = $conn->prepare("DELETE FROM otp_tokens WHERE user_id = ? AND email = ?");
        $stmt->bind_param("is", $user_id, $new_email);
        $stmt->execute();
        
        // Insert new OTP
        $stmt = $conn->prepare("INSERT INTO otp_tokens (user_id, email, otp, expires_at) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("isss", $user_id, $new_email, $otp, $expires_at);
        
        if (!$stmt->execute()) {
            throw new Exception("Failed to store OTP: " . $stmt->error);
        }
        
        // Send email with OTP
        $email_sent = sendOtpEmail($new_email, $otp);
        
        if ($email_sent) {
            echo json_encode([
                'success' => true,
                'message' => 'OTP has been sent to ' . $new_email,
                'debug_otp' => $otp // REMOVE THIS IN PRODUCTION!
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'Failed to send OTP email. Please check email configuration.'
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
    
    exit;
}

// ==================== OTP VERIFICATION HANDLER ====================

if ($endpoint == 'auth' && $action == 'verify-email-otp') {
    header('Content-Type: application/json');
    
    // Get input data
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    $user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;
    $new_email = isset($data['new_email']) ? trim($data['new_email']) : '';
    $otp = isset($data['otp']) ? trim($data['otp']) : '';
    
    // Validate input
    if ($user_id <= 0 || empty($new_email) || empty($otp)) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required parameters'
        ]);
        exit;
    }
    
    try {
        // Check OTP in database
        $stmt = $conn->prepare("
            SELECT otp, expires_at, used 
            FROM otp_tokens 
            WHERE user_id = ? AND email = ? 
            ORDER BY created_at DESC 
            LIMIT 1
        ");
        $stmt->bind_param("is", $user_id, $new_email);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows == 0) {
            echo json_encode([
                'success' => false,
                'message' => 'No OTP found for this email. Please request a new one.'
            ]);
            exit;
        }
        
        $row = $result->fetch_assoc();
        
        // Check if already used
        if ($row['used']) {
            echo json_encode([
                'success' => false,
                'message' => 'This OTP has already been used. Please request a new one.'
            ]);
            exit;
        }
        
        // Check if expired
        if (strtotime($row['expires_at']) < time()) {
            echo json_encode([
                'success' => false,
                'message' => 'OTP has expired. Please request a new one.'
            ]);
            exit;
        }
        
        // Verify OTP
        if ($row['otp'] !== $otp) {
            echo json_encode([
                'success' => false,
                'message' => 'Invalid OTP. Please check and try again.'
            ]);
            exit;
        }
        
        // OTP is valid - Mark as used
        $stmt = $conn->prepare("UPDATE otp_tokens SET used = 1 WHERE user_id = ? AND email = ? AND otp = ?");
        $stmt->bind_param("iss", $user_id, $new_email, $otp);
        $stmt->execute();
        
        // Update user's email in users table
        $stmt = $conn->prepare("UPDATE users SET email = ? WHERE id = ?");
        $stmt->bind_param("si", $new_email, $user_id);
        
        if ($stmt->execute()) {
            echo json_encode([
                'success' => true,
                'message' => 'Email verified and updated successfully!'
            ]);
        } else {
            echo json_encode([
                'success' => false,
                'message' => 'OTP verified but failed to update email: ' . $stmt->error
            ]);
        }
        
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
    
    exit;
}

// ==================== EMAIL SENDING FUNCTION ====================

/**
 * Send OTP via email
 * 
 * @param string $to Recipient email address
 * @param string $otp OTP code
 * @return bool Success status
 */
function sendOtpEmail($to, $otp) {
    // METHOD 1: Using PHPMailer (RECOMMENDED)
    // Uncomment this if you have PHPMailer installed
    /*
    require_once 'vendor/autoload.php';
    
    $mail = new PHPMailer\PHPMailer\PHPMailer(true);
    
    try {
        // SMTP Configuration
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com'; // Change to your SMTP host
        $mail->SMTPAuth = true;
        $mail->Username = 'your-email@gmail.com'; // Your email
        $mail->Password = 'your-app-password'; // Your app password
        $mail->SMTPSecure = PHPMailer\PHPMailer\PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;
        
        // Email content
        $mail->setFrom('noreply@terminalnilam.com', 'Terminal Nilam Monitoring');
        $mail->addAddress($to);
        $mail->isHTML(true);
        $mail->Subject = 'Kode Verifikasi Email - Terminal Nilam';
        $mail->Body = "
            <html>
            <body style='font-family: Arial, sans-serif;'>
                <h2>Verifikasi Email Anda</h2>
                <p>Kode OTP Anda adalah:</p>
                <h1 style='color: #1976D2; letter-spacing: 5px;'>$otp</h1>
                <p>Kode ini berlaku selama <strong>10 menit</strong>.</p>
                <p>Jika Anda tidak meminta kode ini, abaikan email ini.</p>
                <hr>
                <p style='font-size: 12px; color: #666;'>
                    Terminal Nilam - Monitoring System<br>
                    Email ini dikirim otomatis, mohon tidak membalas.
                </p>
            </body>
            </html>
        ";
        $mail->AltBody = "Kode OTP Anda: $otp\n\nBerlaku selama 10 menit.";
        
        $mail->send();
        return true;
        
    } catch (Exception $e) {
        error_log("Email error: " . $mail->ErrorInfo);
        return false;
    }
    */
    
    // METHOD 2: Using PHP mail() function (Simple but may not work on localhost)
    /*
    $subject = "Kode Verifikasi Email - Terminal Nilam";
    $message = "Kode OTP Anda: $otp\n\nKode ini berlaku selama 10 menit.\n\nJika Anda tidak meminta kode ini, abaikan email ini.";
    $headers = "From: noreply@terminalnilam.com\r\n";
    $headers .= "Reply-To: noreply@terminalnilam.com\r\n";
    $headers .= "X-Mailer: PHP/" . phpversion();
    
    return mail($to, $subject, $message, $headers);
    */
    
    // METHOD 3: For testing - just return true and log
    // REMOVE THIS IN PRODUCTION!
    error_log("OTP for $to: $otp");
    return true; // Always returns true for testing
}

?>
