# ⚡ SETUP EMAIL OTP - INSTRUKSI FINAL

## ✅ Yang Sudah Dilakukan

1. ✅ PHPMailer sudah didownload ke: `C:\xampp\htdocs\monitoring_api\PHPMailer`
2. ✅ Backup auth.php dibuat: `auth.php.backup`
3. ✅ Fungsi sendOtpEmail sudah disiapkan

---

## 🔧 LANGKAH TERAKHIR (Manual Edit)

### 1. Buka File auth.php

```powershell
notepad C:\xampp\htdocs\monitoring_api\auth.php
```

### 2. Cari Baris Ini (sekitar line 296-299):

```php
    if ($stmt->execute()) {
        // In production, send email here
        // For demo, return OTP
        sendResponse(true, 'OTP sent to new email', ['debug_otp' => $otp]);
    } else {
        sendResponse(false, 'Failed to generate OTP: ' . $conn->error);
    }
```

### 3. GANTI dengan:

```php
    if ($stmt->execute()) {
        // Send email with OTP
        $emailSent = sendOtpEmail($newEmail, $otp);
        
        if ($emailSent) {
            sendResponse(true, 'OTP sent to new email', ['debug_otp' => $otp]);
        } else {
            // Email failed but OTP generated, return with debug
            sendResponse(true, 'OTP generated (email failed)', ['debug_otp' => $otp]);
        }
    } else {
        sendResponse(false, 'Failed to generate OTP: ' . $conn->error);
    }
```

### 4. Scroll ke PALING BAWAH file (sebelum `?>`)

Tambahkan fungsi ini:

```php

function sendOtpEmail($email, $otp) {
    require_once __DIR__ . '/PHPMailer/src/Exception.php';
    require_once __DIR__ . '/PHPMailer/src/PHPMailer.php';
    require_once __DIR__ . '/PHPMailer/src/SMTP.php';
    
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;
    
    $mail = new PHPMailer(true);
    
    try {
        // ===== GMAIL SMTP SETTINGS =====
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'YOUR_GMAIL@gmail.com';  // ← GANTI dengan email Gmail Anda
        $mail->Password = 'YOUR_APP_PASSWORD';      // ← GANTI dengan App Password 16 digit
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;
        $mail->CharSet = 'UTF-8';
        
        // ===== EMAIL CONTENT =====
        $mail->setFrom('YOUR_GMAIL@gmail.com', 'Terminal Nilam');
        $mail->addAddress($email);
        $mail->isHTML(true);
        $mail->Subject = 'Verifikasi Email - Kode OTP';
        $mail->Body = "
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
                            <div class='otp-code'>{$otp}</div>
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
        ";
        
        $mail->send();
        error_log('OTP email sent successfully to: ' . $email);
        return true;
        
    } catch (Exception $e) {
        error_log('Failed to send OTP email: ' . $mail->ErrorInfo);
        return false;
    }
}
```

### 5. GANTI Email & Password Gmail

Di fungsi `sendOtpEmail`, ganti **2 tempat**:

```php
$mail->Username = 'emailkamu@gmail.com';  // ← Email Gmail Anda
$mail->Password = 'abcdefghijklmnop';     // ← App Password 16 digit
```

Dan:

```php
$mail->setFrom('emailkamu@gmail.com', 'Terminal Nilam');
```

### 6. Save file (Ctrl+S)

---

## 📧 Cara Dapat Gmail App Password

1. **Login Gmail** → https://myaccount.google.com/security
2. **Aktifkan 2-Step Verification** (jika belum aktif)
3. **Buka:** https://myaccount.google.com/apppasswords
4. **Buat password:**
   - App: Mail
   - Device: Other → ketik "PHP Mailer"
5. **Copy 16 digit password** (contoh: `abcd efgh ijkl mnop`)
6. **Hapus spasi** → paste ke auth.php: `abcdefghijklmnop`

---

## 🧪 Test Email

Setelah edit:

```powershell
# Test dari PowerShell
$body = @{
    user_id = 1
    new_email = "emailtujuan@example.com"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing | Select-Object StatusCode, Content
```

**Atau test dari Flutter app:**
1. Edit Profile
2. Ubah email
3. Klik Verifikasi Email
4. **Cek inbox email** → OTP harus masuk!

---

## ❌ Troubleshooting

### Error: "SMTP connect() failed"
- Cek username/password Gmail benar
- Pastikan pakai App Password, bukan password Gmail biasa
- Cek 2-Step Verification sudah aktif

### Error: "Could not authenticate"
- App Password salah, generate ulang
- Hapus semua spasi dari App Password

### Email tidak masuk
- Cek folder Spam
- Cek error di: `C:\xampp\apache\logs\error.log`
- Pastikan PHPMailer folder ada

### Success tapi email tidak terkirim
- Debug: Cek response di Flutter console
- Cek `debug_otp` masih muncul (backup jika email gagal)

---

## 📝 Files Reference

- Auth file: `C:\xampp\htdocs\monitoring_api\auth.php`
- Backup: `C:\xampp\htdocs\monitoring_api\auth.php.backup`
- PHPMailer: `C:\xampp\htdocs\monitoring_api\PHPMailer`
- Fungsi template: `C:\xampp\htdocs\monitoring_api\email_function.txt`

---

**Setelah setup, OTP akan dikirim ke email real! 🚀**
