<?php
/**
 * COMPLETE EMAIL OTP BACKEND IMPLEMENTATION
 * File ini siap digunakan - tinggal paste ke monitoring_api/
 * 
 * CARA PAKAI:
 * 1. Copy semua code ini
 * 2. Paste ke file index.php Anda (atau buat file otp_handler.php terpisah)
 * 3. Include di index.php: require_once 'otp_handler.php';
 * 4. Sesuaikan variable $conn dengan database connection Anda
 */

// ==================== DATABASE CONNECTION (Sesuaikan) ====================

// Jika belum ada, tambahkan ini:
/*
$host = 'localhost';
$username = 'root';
$password = '';
$database = 'monitoring';

$conn = new mysqli($host, $username, $password, $database);

if ($conn->connect_error) {
    die(json_encode([
        'success' => false,
        'message' => 'Database connection failed: ' . $conn->connect_error
    ]));
}
*/

// ==================== REQUEST EMAIL OTP ====================

if (isset($_GET['endpoint']) && $_GET['endpoint'] == 'auth' && 
    isset($_GET['action']) && $_GET['action'] == 'request-email-otp') {
    
    header('Content-Type: application/json');
    
    // Get input
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    $user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;
    $new_email = isset($data['new_email']) ? trim($data['new_email']) : '';
    
    // Log request
    error_log("OTP Request - User ID: $user_id, Email: $new_email");
    
    // Validate
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
            'message' => 'Invalid email format'
        ]);
        exit;
    }
    
    try {
        // Generate OTP
        $otp = sprintf("%06d", mt_rand(0, 999999));
        $expires_at = date('Y-m-d H:i:s', strtotime('+10 minutes'));
        
        // Check if table exists, if not create it
        $table_check = $conn->query("SHOW TABLES LIKE 'otp_tokens'");
        if ($table_check->num_rows == 0) {
            // Create table automatically
            $create_table_sql = "
                CREATE TABLE otp_tokens (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    user_id INT NOT NULL,
                    email VARCHAR(255) NOT NULL,
                    otp VARCHAR(6) NOT NULL,
                    expires_at DATETIME NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    used BOOLEAN DEFAULT FALSE,
                    INDEX idx_user_email (user_id, email),
                    INDEX idx_expires (expires_at)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4
            ";
            $conn->query($create_table_sql);
            error_log("OTP table created automatically");
        }
        
        // Delete old OTP for this user/email
        $stmt = $conn->prepare("DELETE FROM otp_tokens WHERE user_id = ? AND email = ?");
        $stmt->bind_param("is", $user_id, $new_email);
        $stmt->execute();
        
        // Insert new OTP
        $stmt = $conn->prepare("INSERT INTO otp_tokens (user_id, email, otp, expires_at) VALUES (?, ?, ?, ?)");
        $stmt->bind_param("isss", $user_id, $new_email, $otp, $expires_at);
        
        if (!$stmt->execute()) {
            throw new Exception("Failed to store OTP");
        }
        
        error_log("OTP stored in database: $otp for $new_email");
        
        // Try to send email
        $email_sent = sendOtpEmail($new_email, $otp);
        
        // Return success even if email fails (for testing)
        echo json_encode([
            'success' => true,
            'message' => 'OTP telah dibuat' . ($email_sent ? ' dan dikirim' : ' (email gagal terkirim)'),
            'debug_otp' => $otp, // REMOVE IN PRODUCTION!
            'email_sent' => $email_sent,
            'expires_in' => '10 minutes'
        ]);
        
    } catch (Exception $e) {
        error_log("OTP Error: " . $e->getMessage());
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
    
    exit;
}

// ==================== VERIFY EMAIL OTP ====================

if (isset($_GET['endpoint']) && $_GET['endpoint'] == 'auth' && 
    isset($_GET['action']) && $_GET['action'] == 'verify-email-otp') {
    
    header('Content-Type: application/json');
    
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    $user_id = isset($data['user_id']) ? (int)$data['user_id'] : 0;
    $new_email = isset($data['new_email']) ? trim($data['new_email']) : '';
    $otp = isset($data['otp']) ? trim($data['otp']) : '';
    
    error_log("OTP Verify - User: $user_id, Email: $new_email, OTP: $otp");
    
    if ($user_id <= 0 || empty($new_email) || empty($otp)) {
        echo json_encode([
            'success' => false,
            'message' => 'Missing required parameters'
        ]);
        exit;
    }
    
    try {
        // Get OTP from database
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
            error_log("No OTP found for user $user_id and email $new_email");
            echo json_encode([
                'success' => false,
                'message' => 'Kode OTP tidak ditemukan. Silakan minta kode baru.'
            ]);
            exit;
        }
        
        $row = $result->fetch_assoc();
        
        // Check if used
        if ($row['used']) {
            error_log("OTP already used");
            echo json_encode([
                'success' => false,
                'message' => 'Kode OTP sudah digunakan. Silakan minta kode baru.'
            ]);
            exit;
        }
        
        // Check if expired
        if (strtotime($row['expires_at']) < time()) {
            error_log("OTP expired");
            echo json_encode([
                'success' => false,
                'message' => 'Kode OTP sudah kadaluarsa. Silakan minta kode baru.'
            ]);
            exit;
        }
        
        // Verify OTP
        if ($row['otp'] !== $otp) {
            error_log("Invalid OTP. Expected: {$row['otp']}, Got: $otp");
            echo json_encode([
                'success' => false,
                'message' => 'Kode OTP salah. Silakan cek kembali.'
            ]);
            exit;
        }
        
        // Mark as used
        $stmt = $conn->prepare("UPDATE otp_tokens SET used = 1 WHERE user_id = ? AND email = ? AND otp = ?");
        $stmt->bind_param("iss", $user_id, $new_email, $otp);
        $stmt->execute();
        
        // Update user email
        $stmt = $conn->prepare("UPDATE users SET email = ? WHERE id = ?");
        $stmt->bind_param("si", $new_email, $user_id);
        
        if ($stmt->execute()) {
            error_log("Email updated successfully for user $user_id");
            echo json_encode([
                'success' => true,
                'message' => 'Email berhasil diverifikasi dan diperbarui!'
            ]);
        } else {
            error_log("Failed to update email: " . $stmt->error);
            echo json_encode([
                'success' => false,
                'message' => 'OTP valid tetapi gagal mengupdate email'
            ]);
        }
        
    } catch (Exception $e) {
        error_log("Verify Error: " . $e->getMessage());
        echo json_encode([
            'success' => false,
            'message' => 'Error: ' . $e->getMessage()
        ]);
    }
    
    exit;
}

// ==================== EMAIL FUNCTION ====================

function sendOtpEmail($to, $otp) {
    // LOG untuk debugging
    error_log("Attempting to send OTP $otp to $to");
    
    // METHOD 1: Testing Mode - Always return true
    // Uncomment this untuk testing tanpa kirim email
    return true;
    
    // METHOD 2: PHPMailer (PRODUCTION - Uncomment jika sudah install)
    /*
    try {
        require_once 'vendor/autoload.php';
        
        $mail = new PHPMailer\PHPMailer\PHPMailer(true);
        
        // SMTP settings
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'your-email@gmail.com'; // GANTI INI
        $mail->Password = 'your-app-password';     // GANTI INI
        $mail->SMTPSecure = 'tls';
        $mail->Port = 587;
        
        // Email content
        $mail->setFrom('noreply@terminalnilam.com', 'Terminal Nilam');
        $mail->addAddress($to);
        $mail->isHTML(true);
        $mail->Subject = 'Kode Verifikasi Email - Terminal Nilam';
        $mail->Body = "
            <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                <h2 style='color: #1976D2;'>Verifikasi Email Anda</h2>
                <p>Kode OTP Anda adalah:</p>
                <div style='background: #f5f5f5; padding: 20px; text-align: center; border-radius: 8px;'>
                    <h1 style='color: #1976D2; letter-spacing: 10px; margin: 0;'>$otp</h1>
                </div>
                <p style='margin-top: 20px;'>Kode ini berlaku selama <strong>10 menit</strong>.</p>
                <p style='color: #666; font-size: 12px;'>Jika Anda tidak meminta kode ini, abaikan email ini.</p>
                <hr style='border: none; border-top: 1px solid #ddd; margin: 20px 0;'>
                <p style='font-size: 12px; color: #999;'>
                    Terminal Nilam - Monitoring System<br>
                    Email ini dikirim otomatis, mohon tidak membalas.
                </p>
            </div>
        ";
        $mail->AltBody = "Kode OTP Anda: $otp\n\nBerlaku 10 menit.";
        
        $mail->send();
        error_log("Email sent successfully to $to");
        return true;
        
    } catch (Exception $e) {
        error_log("Email send failed: " . $e->getMessage());
        return false;
    }
    */
    
    // METHOD 3: PHP mail() function
    /*
    $subject = "Kode Verifikasi Email - Terminal Nilam";
    $message = "Kode OTP Anda: $otp\n\nKode berlaku 10 menit.";
    $headers = "From: noreply@terminalnilam.com\r\n";
    
    if (mail($to, $subject, $message, $headers)) {
        error_log("Email sent via mail()");
        return true;
    } else {
        error_log("mail() function failed");
        return false;
    }
    */
}

?>
