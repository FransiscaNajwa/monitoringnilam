# 🔧 TROUBLESHOOTING - OTP TIDAK TERKIRIM

## ❌ Masalah: Kode OTP Tidak Terkirim ke Email

---

## 📋 Checklist Debug (Ikuti Langkah Ini)

### Step 1: Cek Console/Debug Log ✓

Setelah update terbaru, ada logging detail di console. 

**Cara cek:**
1. Run app dengan `flutter run`
2. Klik tombol "Verifikasi Email"
3. Lihat output di terminal/console

**Yang Harus Muncul:**
```
=== REQUEST OTP ===
User ID: 1
New Email: test@example.com
=== API: Request Email Change OTP ===
URL: http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp
User ID: 1
New Email: test@example.com
Response Status: 200
Response Body: {"success":true,"message":"OTP sent","debug_otp":"123456"}
Decoded Response: {success: true, message: OTP sent, debug_otp: 123456}
=== OTP RESPONSE ===
Response: {success: true, message: OTP sent, debug_otp: 123456}
OTP sent successfully to test@example.com
```

**Jika Muncul Error:**
- Catat error message yang muncul
- Lanjut ke Step berikutnya sesuai error

---

### Step 2: Cek Backend Server ✓

#### 2.1 Pastikan XAMPP/Server Running
```bash
# Windows - Check if XAMPP running
# Apache harus hijau (running)
# MySQL harus hijau (running)
```

#### 2.2 Test Backend Endpoint Langsung

Buka terminal dan test dengan curl:

```bash
curl -X POST http://localhost/monitoring_api/index.php?endpoint=auth^&action=request-email-otp ^
  -H "Content-Type: application/json" ^
  -d "{\"user_id\":1,\"new_email\":\"test@example.com\"}"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "OTP sent to test@example.com",
  "debug_otp": "123456"
}
```

**Jika Response Error 404/500:**
- Backend endpoint belum diimplementasikan
- Lanjut ke Step 3

---

### Step 3: Cek Backend Implementation ✓

#### File Backend yang Harus Ada:

**Location**: `monitoring_api/index.php` atau sejenisnya

**Harus ada handler untuk:**
```php
// 1. Request OTP
if ($endpoint == 'auth' && $action == 'request-email-otp') {
    // Your OTP request logic here
}

// 2. Verify OTP
if ($endpoint == 'auth' && $action == 'verify-email-otp') {
    // Your OTP verify logic here
}
```

#### Minimal Backend Code untuk Request OTP:

```php
<?php
// request-email-otp handler
if ($endpoint == 'auth' && $action == 'request-email-otp') {
    $data = json_decode(file_get_contents('php://input'), true);
    $user_id = $data['user_id'];
    $new_email = $data['new_email'];
    
    // Generate 6-digit OTP
    $otp = rand(100000, 999999);
    
    // Store OTP in database (with expiry time)
    $expiry = date('Y-m-d H:i:s', strtotime('+10 minutes'));
    $query = "INSERT INTO otp_tokens (user_id, email, otp, expires_at) 
              VALUES (?, ?, ?, ?)
              ON DUPLICATE KEY UPDATE otp=?, expires_at=?";
    $stmt = $conn->prepare($query);
    $stmt->bind_param("isssss", $user_id, $new_email, $otp, $expiry, $otp, $expiry);
    $stmt->execute();
    
    // Send email with OTP
    $to = $new_email;
    $subject = "Kode Verifikasi Email - Terminal Nilam";
    $message = "Kode OTP Anda: $otp\n\nKode ini berlaku selama 10 menit.";
    $headers = "From: noreply@terminalnilam.com";
    
    $email_sent = mail($to, $subject, $message, $headers);
    
    if ($email_sent) {
        echo json_encode([
            'success' => true,
            'message' => 'OTP sent to ' . $new_email,
            'debug_otp' => $otp // Remove in production!
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'Failed to send email'
        ]);
    }
    exit;
}
?>
```

---

### Step 4: Cek Email Service Configuration ✓

**Problem**: PHP `mail()` function tidak bekerja di localhost

#### Option A: Gunakan PHPMailer (RECOMMENDED)

1. **Install PHPMailer**
   ```bash
   cd monitoring_api
   composer require phpmailer/phpmailer
   ```

2. **Update Backend Code**
   ```php
   <?php
   use PHPMailer\PHPMailer\PHPMailer;
   use PHPMailer\PHPMailer\Exception;
   
   require 'vendor/autoload.php';
   
   // Configure PHPMailer
   $mail = new PHPMailer(true);
   
   try {
       // SMTP configuration
       $mail->isSMTP();
       $mail->Host = 'smtp.gmail.com'; // atau smtp lain
       $mail->SMTPAuth = true;
       $mail->Username = 'your-email@gmail.com';
       $mail->Password = 'your-app-password'; // App password, bukan password biasa
       $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
       $mail->Port = 587;
       
       // Email content
       $mail->setFrom('noreply@terminalnilam.com', 'Terminal Nilam');
       $mail->addAddress($new_email);
       $mail->Subject = 'Kode Verifikasi Email';
       $mail->Body = "Kode OTP Anda: $otp\n\nBerlaku 10 menit.";
       
       $mail->send();
       
       echo json_encode([
           'success' => true,
           'message' => 'OTP sent successfully',
           'debug_otp' => $otp
       ]);
   } catch (Exception $e) {
       echo json_encode([
           'success' => false,
           'message' => 'Email error: ' . $mail->ErrorInfo
       ]);
   }
   ?>
   ```

#### Option B: Gunakan SMTP Lokal (Testing Only)

Install **MailHog** atau **Mailtrap** untuk testing:

**MailHog** (Windows):
```bash
# Download from: https://github.com/mailhog/MailHog/releases
# Run: MailHog.exe
# Access: http://localhost:8025
```

**Update PHP config** (`php.ini`):
```ini
[mail function]
SMTP = localhost
smtp_port = 1025
sendmail_from = noreply@terminalnilam.com
```

#### Option C: Gunakan Gmail SMTP (Quick Test)

**⚠️ Note**: Harus enable "App Passwords" di Gmail

1. Go to: https://myaccount.google.com/apppasswords
2. Generate app password
3. Use in backend config (lihat Option A)

---

### Step 5: Database Table untuk OTP ✓

Buat table untuk menyimpan OTP:

```sql
CREATE TABLE IF NOT EXISTS otp_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT FALSE,
    UNIQUE KEY unique_user_email (user_id, email)
);
```

Run di phpMyAdmin atau MySQL console.

---

## 🔍 Common Issues & Solutions

### Issue 1: "Response Status: 404"
**Cause**: Backend endpoint tidak ditemukan
**Solution**: 
- Cek URL di `api_service.dart` line 8: `baseUrl`
- Pastikan backend file ada di path yang benar
- Cek routing di backend

### Issue 2: "Response Status: 500"
**Cause**: Error di backend PHP
**Solution**:
- Cek error log: `C:\xampp\apache\logs\error.log`
- Enable error reporting di PHP:
  ```php
  error_reporting(E_ALL);
  ini_set('display_errors', 1);
  ```

### Issue 3: "Failed to send email"
**Cause**: Email service tidak configured
**Solution**:
- Use PHPMailer (Option A di Step 4)
- Configure SMTP properly
- Test dengan MailHog untuk development

### Issue 4: Response success tapi email tidak masuk
**Cause**: Email masuk spam atau SMTP gagal
**Solution**:
- Cek folder spam
- Cek email server logs
- Use MailHog untuk testing (lihat inbox di http://localhost:8025)

### Issue 5: "Connection refused"
**Cause**: Backend server tidak running
**Solution**:
- Start XAMPP Apache & MySQL
- Verify: http://localhost/monitoring_api/
- Check firewall settings

---

## 📊 Debugging Checklist

```
□ Flutter console menampilkan log detail
□ Backend server (XAMPP) running
□ Database connection working
□ Backend endpoint exists and responds
□ OTP table exists in database
□ Email service configured (PHPMailer/SMTP)
□ Email credentials valid
□ Test email berhasil dikirim
□ OTP tersimpan di database
□ Email masuk (atau di MailHog inbox)
```

---

## 🚀 Quick Test (Development)

### Test 1: Bypass Email (Sementara)

Untuk testing cepat, modify backend untuk **selalu return OTP tanpa kirim email**:

```php
<?php
// TESTING ONLY - Remove in production
if ($endpoint == 'auth' && $action == 'request-email-otp') {
    $data = json_decode(file_get_contents('php://input'), true);
    $otp = '123456'; // Fixed OTP untuk testing
    
    // Store in DB
    // ... (store code here)
    
    // Don't send email, just return OTP
    echo json_encode([
        'success' => true,
        'message' => 'OTP generated (not sent - testing mode)',
        'debug_otp' => $otp
    ]);
    exit;
}
?>
```

Dengan ini, OTP `123456` akan selalu ditampilkan di dialog tanpa kirim email.

### Test 2: Use MailHog (Recommended)

1. Download & run MailHog
2. Configure PHP to use MailHog SMTP (localhost:1025)
3. All emails will appear in http://localhost:8025
4. You can see OTP without real email service

---

## 📞 Next Steps

1. **Run app dengan logging enabled** (sudah di-update)
2. **Klik "Verifikasi Email"**
3. **Copy semua log dari console** dan cek:
   - Response status
   - Response body
   - Error messages
4. **Follow checklist di atas** sesuai error
5. **Implement backend** jika belum ada
6. **Configure email service** (PHPMailer recommended)

---

## 🔗 Helpful Links

- PHPMailer: https://github.com/PHPMailer/PHPMailer
- MailHog: https://github.com/mailhog/MailHog
- Mailtrap: https://mailtrap.io/
- Gmail App Passwords: https://support.google.com/accounts/answer/185833

---

## 📝 Sample Backend Complete Code

Saya bisa buatkan complete backend PHP code jika diperlukan. Just let me know!

---

**Last Updated**: February 2, 2026
**Status**: Troubleshooting Guide
