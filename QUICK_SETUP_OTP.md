# 🚀 QUICK SETUP - OTP EMAIL CONFIGURATION

## ⚡ Setup dalam 10 Menit

Ikuti langkah ini untuk membuat OTP email bekerja:

---

## Step 1: Database Setup (2 menit) ✓

### 1.1 Create OTP Table

1. Buka **phpMyAdmin**: http://localhost/phpmyadmin
2. Pilih database `monitoring` (atau sesuai nama database Anda)
3. Klik tab **SQL**
4. Copy paste semua isi dari file: `otp_tokens_schema.sql`
5. Klik **Go**

**Atau via command line:**
```bash
mysql -u root -p monitoring < otp_tokens_schema.sql
```

### 1.2 Verify Table Created

Run query ini di phpMyAdmin:
```sql
DESCRIBE otp_tokens;
```

Harus muncul struktur table dengan kolom: id, user_id, email, otp, expires_at, created_at, used.

---

## Step 2: Backend Implementation (5 menit) ✓

### 2.1 Option A: Copy-Paste Lengkap

1. Buka file backend: `monitoring_api/index.php`
2. Copy semua isi dari `backend_sample_otp.php`
3. Paste ke dalam file `index.php` (sebelum closing `?>` atau di posisi yang tepat)
4. Save file

### 2.2 Option B: Manual Implementation

Jika sudah punya struktur backend sendiri, ambil 2 handler dari `backend_sample_otp.php`:
- Handler untuk `request-email-otp`
- Handler untuk `verify-email-otp`

Dan function `sendOtpEmail()`.

---

## Step 3: Email Configuration (3 menit) ✓

Pilih salah satu metode:

### 🎯 Method 1: Testing Mode (TERMUDAH)

Edit function `sendOtpEmail()` di backend:

```php
function sendOtpEmail($to, $otp) {
    // For testing - just log and return true
    error_log("OTP for $to: $otp");
    return true; // Always success
}
```

**Pro**: Langsung bisa test tanpa setup email
**Con**: Email tidak benar-benar terkirim (lihat OTP di debug_otp)

### 🎯 Method 2: PHPMailer + Gmail (PRODUCTION)

#### 2.1 Install PHPMailer

```bash
cd monitoring_api
composer require phpmailer/phpmailer
```

#### 2.2 Generate Gmail App Password

1. Buka: https://myaccount.google.com/security
2. Enable **2-Step Verification** (jika belum)
3. Buka: https://myaccount.google.com/apppasswords
4. Create app password untuk "Mail"
5. Copy password yang di-generate (16 karakter)

#### 2.3 Configure Backend

Edit function `sendOtpEmail()` di `backend_sample_otp.php`:

```php
$mail->Host = 'smtp.gmail.com';
$mail->Username = 'youremail@gmail.com'; // ← Ganti
$mail->Password = 'your-16-char-app-password'; // ← Ganti
```

Uncomment semua code PHPMailer di function `sendOtpEmail()`.

### 🎯 Method 3: MailHog (RECOMMENDED FOR DEV)

#### 3.1 Download MailHog

Windows: https://github.com/mailhog/MailHog/releases
- Download `MailHog_windows_amd64.exe`
- Rename to `MailHog.exe`

#### 3.2 Run MailHog

```bash
./MailHog.exe
```

Opens at: http://localhost:8025

#### 3.3 Configure PHP

Edit `php.ini` (usually at `C:\xampp\php\php.ini`):

```ini
[mail function]
SMTP = localhost
smtp_port = 1025
sendmail_from = noreply@terminalnilam.com
```

Restart Apache.

#### 3.4 Use PHP mail()

Uncomment METHOD 2 di `sendOtpEmail()` function.

---

## Step 4: Test (1 menit) ✓

### 4.1 Start Services

```bash
# Start XAMPP (Apache + MySQL)
# If using MailHog: run MailHog.exe
```

### 4.2 Run Flutter App

```bash
flutter run
```

### 4.3 Test Feature

1. Login ke app
2. Buka Edit Profile
3. Ubah email ke `test@example.com`
4. Klik tombol "Verifikasi Email"
5. **Lihat console/terminal** - harus ada log:
   ```
   === REQUEST OTP ===
   User ID: 1
   New Email: test@example.com
   === API: Request Email Change OTP ===
   Response Status: 200
   OTP sent successfully
   ```
6. **Dialog muncul** dengan input OTP
7. **Cek email:**
   - Testing Mode: Lihat `debug_otp` di dialog
   - MailHog: Buka http://localhost:8025
   - Gmail: Cek inbox email
8. **Input OTP** dan klik Verifikasi
9. **Email field berubah hijau** ✓
10. **Klik "Simpan Perubahan"** → Berhasil!

---

## 📊 Verification Checklist

```
□ Database table otp_tokens created
□ Backend handlers added (request-email-otp, verify-email-otp)
□ Email function configured
□ XAMPP Apache & MySQL running
□ (If MailHog) MailHog running
□ Flutter app running
□ Console shows detailed logs
□ API responds with 200
□ OTP generated and stored in DB
□ Email received (or visible in MailHog/debug)
□ OTP verification works
□ Email field turns green after verify
□ Profile save succeeds with new email
```

---

## 🔍 Quick Debug

### Check 1: Database
```sql
SELECT * FROM otp_tokens ORDER BY created_at DESC LIMIT 5;
```
Harus ada row dengan OTP baru setelah klik verifikasi.

### Check 2: Backend Log
```
C:\xampp\apache\logs\error.log
```
Lihat error jika ada.

### Check 3: Network
```bash
curl -X POST http://localhost/monitoring_api/index.php?endpoint=auth^&action=request-email-otp ^
  -H "Content-Type: application/json" ^
  -d "{\"user_id\":1,\"new_email\":\"test@example.com\"}"
```
Harus return JSON success.

---

## ⚙️ Configuration Summary

### Frontend (Already Done)
```dart
// lib/services/api_service.dart
static const String baseUrl = 'http://localhost/monitoring_api/index.php';
```

### Backend Options

| Method | Setup Time | Email Sent? | Best For |
|--------|-----------|-------------|----------|
| Testing Mode | 30 sec | ❌ No | Quick test |
| MailHog | 5 min | ✓ Local | Development |
| PHPMailer + Gmail | 10 min | ✓ Real | Production |

---

## 🎯 Recommended Path

**For Development/Testing:**
1. Use **MailHog** (Method 3)
2. See all emails at http://localhost:8025
3. Fast & easy to debug

**For Production:**
1. Use **PHPMailer + Gmail** (Method 2)
2. Or use transactional email service (SendGrid, Mailgun)
3. Reliable & professional

---

## 📞 Having Issues?

1. **Read**: `OTP_TROUBLESHOOTING.md`
2. **Check**: Console logs (detailed logging enabled)
3. **Verify**: Each step in checklist above
4. **Test**: Backend endpoint directly with curl

---

## 📚 Files Reference

```
📁 monitoring/
├── 📄 otp_tokens_schema.sql          ← Step 1: Run this
├── 📄 backend_sample_otp.php         ← Step 2: Copy this
├── 📄 QUICK_SETUP_OTP.md            ← This file
└── 📄 OTP_TROUBLESHOOTING.md        ← If issues
```

---

**Time Required**: ~10 minutes
**Difficulty**: Easy
**Status**: Ready to implement

Good luck! 🚀
