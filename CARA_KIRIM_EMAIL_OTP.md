# 📧 CARA MENGIRIM EMAIL OTP - 3 PILIHAN

## Status Saat Ini ✅

✅ **Backend sudah berfungsi** - OTP berhasil di-generate  
✅ **Database sudah OK** - Kolom otp_code & otp_expiry ada  
✅ **Response berhasil** - `debug_otp` dikembalikan  

⚠️ **TAPI:** Email **TIDAK dikirim** karena backend dalam **testing mode**

---

## PILIHAN 1: Gunakan Debug OTP (TERCEPAT!) ⚡

**Cara kerja:**
- Backend sudah mengembalikan `debug_otp` di response
- Frontend sudah menampilkan OTP di dialog (kotak orange)
- User tinggal copy-paste OTP dari dialog ke input field

**Cara test:**
1. Buka app Flutter
2. Edit Profile → Ubah email
3. Klik Verifikasi Email
4. **Lihat di dialog**, ada kotak orange: `Demo OTP: 123456`
5. Ketik OTP tersebut ke input field
6. Klik Verifikasi

**✅ KELEBIHAN:** Sudah jalan sekarang, tidak perlu setup email  
**❌ KEKURANGAN:** Tidak kirim email asli (demo mode)

---

## PILIHAN 2: Setup Gmail SMTP (RECOMMENDED) 📧

### Langkah-langkah:

#### 1. Setup Gmail App Password

1. **Login Gmail** (email yang akan dipakai untuk kirim OTP)
2. **Buka:** https://myaccount.google.com/security
3. **Aktifkan 2-Step Verification** (jika belum)
4. **Buka:** https://myaccount.google.com/apppasswords
5. **Buat App Password:**
   - Select app: "Mail"
   - Select device: "Other" → ketik "PHP Mailer"
   - **Copy password 16 digit** yang muncul (contoh: `abcd efgh ijkl mnop`)

#### 2. Install PHPMailer

```powershell
cd C:\xampp\htdocs\monitoring_api
composer require phpmailer/phpmailer
```

**Jika tidak ada Composer:**
1. Download PHPMailer: https://github.com/PHPMailer/PHPMailer/archive/master.zip
2. Extract ke: `C:\xampp\htdocs\monitoring_api\PHPMailer`

#### 3. Update auth.php

**Ganti fungsi `requestEmailChangeOtp()` di file:** `C:\xampp\htdocs\monitoring_api\auth.php`

**Ganti line 296-299** dari:
```php
if ($stmt->execute()) {
    // In production, send email here
    // For demo, return OTP
    sendResponse(true, 'OTP sent to new email', ['debug_otp' => $otp]);
```

**Menjadi:**
```php
if ($stmt->execute()) {
    // Send email with PHPMailer
    $emailSent = sendOtpEmail($newEmail, $otp);
    
    if ($emailSent) {
        sendResponse(true, 'OTP sent to new email', ['debug_otp' => $otp]);
    } else {
        sendResponse(false, 'OTP generated but email failed to send', ['debug_otp' => $otp]);
    }
```

#### 4. Tambahkan Fungsi sendOtpEmail()

**Tambahkan di akhir file `auth.php` sebelum `?>`:**

```php
function sendOtpEmail($email, $otp) {
    // ===== METHOD 1: PHPMailer dengan Composer =====
    require 'vendor/autoload.php';
    
    // ===== METHOD 2: PHPMailer Manual Download (jika tidak pakai composer) =====
    // require 'PHPMailer/src/Exception.php';
    // require 'PHPMailer/src/PHPMailer.php';
    // require 'PHPMailer/src/SMTP.php';
    
    use PHPMailer\PHPMailer\PHPMailer;
    use PHPMailer\PHPMailer\Exception;
    
    $mail = new PHPMailer(true);
    
    try {
        // SMTP settings
        $mail->isSMTP();
        $mail->Host = 'smtp.gmail.com';
        $mail->SMTPAuth = true;
        $mail->Username = 'your-email@gmail.com';  // ← GANTI dengan email Anda
        $mail->Password = 'your-app-password';      // ← GANTI dengan App Password 16 digit
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port = 587;
        
        // Email settings
        $mail->setFrom('your-email@gmail.com', 'Terminal Nilam');
        $mail->addAddress($email);
        $mail->isHTML(true);
        $mail->Subject = 'Verifikasi Email - Kode OTP';
        $mail->Body = "
            <h2>Verifikasi Email Anda</h2>
            <p>Kode OTP Anda adalah:</p>
            <h1 style='color: #1976D2; font-size: 32px; letter-spacing: 5px;'>$otp</h1>
            <p>Kode ini berlaku selama <strong>15 menit</strong>.</p>
            <p>Jika Anda tidak meminta kode ini, abaikan email ini.</p>
            <hr>
            <p style='color: #666; font-size: 12px;'>Terminal Nilam - Monitoring System</p>
        ";
        
        $mail->send();
        return true;
    } catch (Exception $e) {
        error_log("Email error: {$mail->ErrorInfo}");
        return false;
    }
}
```

**JANGAN LUPA GANTI:**
- `your-email@gmail.com` → Email Gmail Anda
- `your-app-password` → App Password 16 digit dari step 1

#### 5. Test

```powershell
# Test dari PowerShell
$body = @{
    user_id = 1
    new_email = "email-tujuan@example.com"  # Email Anda yang akan terima OTP
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing
```

**Cek inbox email-tujuan**, harusnya OTP masuk!

---

## PILIHAN 3: MailHog (Testing Email Tanpa SMTP Real) 🧪

**Kelebihan:** Tidak perlu setup Gmail, bisa lihat email di web browser

### Setup:

1. **Download MailHog:**
   - Windows: https://github.com/mailhog/MailHog/releases/latest
   - Download `MailHog_windows_amd64.exe`
   - Rename ke `mailhog.exe`

2. **Run MailHog:**
   ```powershell
   ./mailhog.exe
   ```
   - SMTP: localhost:1025
   - Web UI: http://localhost:8025

3. **Update auth.php** dengan fungsi ini:

```php
function sendOtpEmail($email, $otp) {
    require 'vendor/autoload.php';
    use PHPMailer\PHPMailer\PHPMailer;
    
    $mail = new PHPMailer(true);
    
    try {
        // MailHog settings (local testing)
        $mail->isSMTP();
        $mail->Host = 'localhost';
        $mail->Port = 1025;
        $mail->SMTPAuth = false;  // MailHog tidak butuh auth
        
        // Email settings
        $mail->setFrom('noreply@terminal-nilam.local', 'Terminal Nilam');
        $mail->addAddress($email);
        $mail->isHTML(true);
        $mail->Subject = 'Verifikasi Email - Kode OTP';
        $mail->Body = "
            <h2>Verifikasi Email Anda</h2>
            <p>Kode OTP Anda adalah:</p>
            <h1 style='color: #1976D2; font-size: 32px;'>$otp</h1>
            <p>Kode berlaku 15 menit.</p>
        ";
        
        $mail->send();
        return true;
    } catch (Exception $e) {
        return false;
    }
}
```

4. **Test**, lalu buka http://localhost:8025 untuk lihat email

---

## REKOMENDASI 💡

| Pilihan | Kapan Pakai | Setup Time |
|---------|-------------|------------|
| **1. Debug OTP** | Development/testing cepat | ✅ 0 menit (sudah jalan) |
| **2. Gmail SMTP** | Production (kirim email real) | ⚡ 10-15 menit |
| **3. MailHog** | Development/testing lokal | 🔧 5-10 menit |

**Untuk sekarang:** Pakai **Debug OTP** (Pilihan 1) - sudah jalan!

**Untuk production:** Setup **Gmail SMTP** (Pilihan 2)

---

## File yang Perlu Diedit

Jika mau kirim email real, kirim ke saya:

📄 **C:\xampp\htdocs\monitoring_api\auth.php** (line 263-333)

Atau saya buatkan file lengkapnya yang sudah ready to use!

---

## Testing Checklist

```
□ Backend response sukses (debug_otp ada)
□ OTP tersimpan di database
□ Dialog muncul dengan timer countdown
□ Debug OTP tampil di kotak orange
□ Input OTP manual → verify → berhasil
□ (Opsional) Email terkirim ke inbox real
```

---

**Mau pakai yang mana?** Kasih tau saya, nanti saya buatkan file lengkapnya! 🚀
