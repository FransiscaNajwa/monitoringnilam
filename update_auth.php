<?php
// Script untuk update auth.php dengan email sending

$authFile = 'C:\xampp\htdocs\monitoring_api\auth.php';
$content = file_get_contents($authFile);

// 1. Replace the requestEmailChangeOtp execution part
$oldCode = "    if (\$stmt->execute()) {
        // In production, send email here
        // For demo, return OTP
        sendResponse(true, 'OTP sent to new email', ['debug_otp' => \$otp]);
    } else {
        sendResponse(false, 'Failed to generate OTP: ' . \$conn->error);
    }";

$newCode = "    if (\$stmt->execute()) {
        // Send email with OTP
        \$emailSent = sendOtpEmail(\$newEmail, \$otp);
        
        if (\$emailSent) {
            sendResponse(true, 'OTP sent to new email', ['debug_otp' => \$otp]);
        } else {
            // Email failed but OTP generated, return with debug
            sendResponse(true, 'OTP generated (email failed)', ['debug_otp' => \$otp]);
        }
    } else {
        sendResponse(false, 'Failed to generate OTP: ' . \$conn->error);
    }";

$content = str_replace($oldCode, $newCode, $content);

// 2. Add sendOtpEmail function before closing ?>
$emailFunction = "
function sendOtpEmail(\$email, \$otp) {
    require_once __DIR__ . '/PHPMailer/src/Exception.php';
    require_once __DIR__ . '/PHPMailer/src/PHPMailer.php';
    require_once __DIR__ . '/PHPMailer/src/SMTP.php';
    
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;
    
    \$mail = new PHPMailer(true);
    
    try {
        // ===== GMAIL SMTP SETTINGS =====
        \$mail->isSMTP();
        \$mail->Host = 'smtp.gmail.com';
        \$mail->SMTPAuth = true;
        \$mail->Username = 'YOUR_GMAIL@gmail.com';  // ← GANTI dengan email Gmail Anda
        \$mail->Password = 'YOUR_APP_PASSWORD';      // ← GANTI dengan App Password 16 digit
        \$mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        \$mail->Port = 587;
        \$mail->CharSet = 'UTF-8';
        
        // ===== EMAIL CONTENT =====
        \$mail->setFrom('YOUR_GMAIL@gmail.com', 'Terminal Nilam');
        \$mail->addAddress(\$email);
        \$mail->isHTML(true);
        \$mail->Subject = 'Verifikasi Email - Kode OTP';
        \$mail->Body = \"
            <!DOCTYPE html>
            <html>
            <head>
                <meta charset='UTF-8'>
                <style>
                    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
                    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
                    .header { background: #1976D2; color: white; padding: 20px; text-align: center; }
                    .content { background: #f5f5f5; padding: 30px; }
                    .otp-box { background: white; border: 2px dashed #1976D2; padding: 20px; text-align: center; margin: 20px 0; }
                    .otp-code { color: #1976D2; font-size: 36px; font-weight: bold; letter-spacing: 8px; }
                    .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
                </style>
            </head>
            <body>
                <div class='container'>
                    <div class='header'>
                        <h1>Terminal Nilam</h1>
                        <p>Monitoring System</p>
                    </div>
                    <div class='content'>
                        <h2>Verifikasi Email Anda</h2>
                        <p>Anda telah meminta untuk mengubah email Anda. Silakan gunakan kode OTP berikut:</p>
                        <div class='otp-box'>
                            <p style='margin: 0; font-size: 14px; color: #666;'>Kode OTP Anda:</p>
                            <div class='otp-code'>{\$otp}</div>
                        </div>
                        <p><strong>⏰ Kode ini berlaku selama 15 menit.</strong></p>
                        <p>Jika Anda tidak meminta perubahan email ini, abaikan email ini atau hubungi administrator.</p>
                    </div>
                    <div class='footer'>
                        <p>© 2024 Terminal Nilam. All rights reserved.</p>
                        <p>Email ini dikirim secara otomatis, mohon tidak membalas.</p>
                    </div>
                </div>
            </body>
            </html>
        \";
        
        \$mail->send();
        error_log('OTP email sent successfully to: ' . \$email);
        return true;
        
    } catch (Exception \$e) {
        error_log('Failed to send OTP email: ' . \$mail->ErrorInfo);
        return false;
    }
}
";

// Insert before closing ?>
$content = str_replace('?>', $emailFunction . "\n?>", $content);

// Save updated file
file_put_contents($authFile, $content);

echo "✅ auth.php berhasil diupdate!\n\n";
echo "⚠️  LANGKAH SELANJUTNYA:\n";
echo "1. Buka file: C:\\xampp\\htdocs\\monitoring_api\\auth.php\n";
echo "2. Cari: 'YOUR_GMAIL@gmail.com' (ada 2 tempat)\n";
echo "3. Ganti dengan email Gmail Anda\n";
echo "4. Cari: 'YOUR_APP_PASSWORD'\n";
echo "5. Ganti dengan App Password Gmail (16 digit)\n\n";
echo "📧 Cara dapat App Password:\n";
echo "   1. Login Gmail → https://myaccount.google.com/security\n";
echo "   2. Aktifkan 2-Step Verification\n";
echo "   3. Buka: https://myaccount.google.com/apppasswords\n";
echo "   4. Buat password baru → Copy 16 digit\n\n";
?>
