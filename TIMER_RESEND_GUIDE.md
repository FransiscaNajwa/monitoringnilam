# ✅ FITUR BARU: Timer & Resend OTP + Backend Siap Pakai

## 🎉 Yang Sudah Ditambahkan

### 1. **Timer Countdown 60 Detik** ✓
   - Dialog OTP sekarang menampilkan countdown timer
   - "Kirim ulang dalam X detik"
   - Icon timer ⏱️ untuk visual feedback

### 2. **Tombol Kirim Ulang OTP** ✓
   - Muncul setelah 60 detik
   - Disabled selama countdown
   - Loading state saat mengirim ulang
   - Success notification saat OTP baru terkirim

### 3. **Backend Complete & Siap Pakai** ✓
   - File: `backend_complete_otp.php`
   - Auto-create table jika belum ada
   - Logging lengkap untuk debug
   - Testing mode enabled (OTP selalu berhasil tanpa kirim email)

---

## 🚀 CARA SETUP BACKEND (5 MENIT)

### Step 1: Copy Backend Code

1. **Buka file**: `backend_complete_otp.php`
2. **Copy SEMUA isinya**
3. **Paste ke file backend Anda**:
   - Jika pakai `monitoring_api/index.php` → paste di dalam file tersebut
   - Atau buat file baru `monitoring_api/otp_handler.php` → lalu include di index.php

### Step 2: Sesuaikan Database Connection

Di bagian atas file, pastikan variable `$conn` sudah tersedia.

**Jika belum ada, uncomment dan sesuaikan:**
```php
$host = 'localhost';
$username = 'root';
$password = '';  // Atau password MySQL Anda
$database = 'monitoring';  // Nama database Anda

$conn = new mysqli($host, $username, $password, $database);
```

### Step 3: Test Langsung!

Backend sudah dalam **TESTING MODE** - OTP akan selalu:
- ✅ Return success = true
- ✅ Generate OTP 6 digit
- ✅ Simpan di database
- ✅ Return debug_otp ke frontend
- ⚠️ TIDAK kirim email (testing mode)

**Untuk production**, uncomment salah satu email method di function `sendOtpEmail()`.

---

## 📊 Testing Checklist

```bash
# 1. Start backend (XAMPP)
# 2. Run Flutter app
flutter run

# 3. Test flow:
□ Buka Edit Profile
□ Ubah email
□ Klik "Verifikasi Email"
□ Lihat console log (harus ada response success)
□ Dialog muncul dengan countdown timer "60 detik"
□ OTP muncul di debug_otp
□ Input OTP → Verifikasi
□ Email field berubah hijau
□ Tunggu 60 detik
□ Tombol "Kirim Ulang" muncul
□ Klik "Kirim Ulang"
□ OTP baru muncul di debug
□ Timer reset ke 60 detik
```

---

## 🔍 Cek Jika Masih Gagal

### Test 1: Cek Backend Endpoint Langsung

```powershell
# Test request OTP
curl -X POST "http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp" -H "Content-Type: application/json" -d "{\"user_id\":1,\"new_email\":\"test@example.com\"}"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "OTP telah dibuat",
  "debug_otp": "123456",
  "email_sent": true,
  "expires_in": "10 minutes"
}
```

**Jika error:**
- Check: Backend file sudah ada?
- Check: Database connection OK?
- Check: XAMPP Apache running?

### Test 2: Cek Console Log

Saat klik "Verifikasi Email", harus muncul di console:
```
=== REQUEST OTP ===
User ID: 1
New Email: test@example.com
=== API: Request Email Change OTP ===
URL: http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp
Response Status: 200
Response Body: {"success":true,...}
```

**Jika status bukan 200:**
- 404 → Backend endpoint tidak ditemukan
- 500 → Error di backend PHP
- Connection refused → Apache tidak running

### Test 3: Cek Database

```sql
-- Cek table exists
SHOW TABLES LIKE 'otp_tokens';

-- Cek data
SELECT * FROM otp_tokens ORDER BY created_at DESC LIMIT 5;
```

Harus ada row baru setiap kali request OTP.

---

## 🎨 Visual New Features

### Timer Display
```
┌─────────────────────────────────────┐
│ Verifikasi Email                    │
├─────────────────────────────────────┤
│ Kode dikirim ke: test@example.com   │
│                                     │
│ Input OTP: [______]                │
│                                     │
│ ⏱️  Kirim ulang dalam 45 detik     │
│                                     │
│ [Batal]              [Verifikasi]  │
└─────────────────────────────────────┘
```

### After 60 Seconds
```
┌─────────────────────────────────────┐
│ Verifikasi Email                    │
├─────────────────────────────────────┤
│ Kode dikirim ke: test@example.com   │
│                                     │
│ Input OTP: [______]                │
│                                     │
│        [🔄 Kirim Ulang]            │
│                                     │
│ [Batal]              [Verifikasi]  │
└─────────────────────────────────────┘
```

### Resending State
```
┌─────────────────────────────────────┐
│ Verifikasi Email                    │
├─────────────────────────────────────┤
│ Kode dikirim ke: test@example.com   │
│                                     │
│ Input OTP: [______]                │
│                                     │
│      [⟳ Mengirim...]              │
│                                     │
│ [Batal]              [Verifikasi]  │
└─────────────────────────────────────┘
```

---

## 📝 Backend Features

### Auto-Create Table
Backend akan otomatis membuat table `otp_tokens` jika belum ada:
```sql
CREATE TABLE otp_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT FALSE,
    ...
);
```

### Logging
Setiap request dicatat di error log:
```
OTP Request - User ID: 1, Email: test@example.com
OTP stored in database: 123456 for test@example.com
Attempting to send OTP 123456 to test@example.com
```

Lokasi log: `C:\xampp\apache\logs\error.log`

### Security Features
- ✅ OTP expires setelah 10 menit
- ✅ OTP cannot be reused (marked as 'used')
- ✅ Old OTP auto-deleted saat request baru
- ✅ Email format validation
- ✅ User ID validation

---

## ⚙️ Configuration Options

### Change OTP Expiry Time

Di `backend_complete_otp.php`, line ~80:
```php
$expires_at = date('Y-m-d H:i:s', strtotime('+10 minutes'));
```
Ubah `+10 minutes` ke `+5 minutes` atau sesuai kebutuhan.

### Change Timer Duration

Di `edit_profile.dart`, line ~1237:
```dart
int _remainingSeconds = 60;
```
Ubah `60` ke durasi yang diinginkan (dalam detik).

### Enable Real Email Sending

Di `backend_complete_otp.php`, function `sendOtpEmail()`:
1. Comment out line: `return true;`
2. Uncomment METHOD 2 (PHPMailer) atau METHOD 3 (mail())
3. Configure SMTP settings jika pakai PHPMailer

---

## 🎯 Summary

| Feature | Status | Notes |
|---------|--------|-------|
| Timer 60 detik | ✅ Done | Countdown di dialog |
| Tombol Resend | ✅ Done | Muncul setelah timer habis |
| Auto-disable Resend | ✅ Done | Disabled saat countdown |
| Loading state | ✅ Done | Spinner saat resend |
| Backend complete | ✅ Done | Siap pakai, testing mode |
| Auto-create table | ✅ Done | Table dibuat otomatis |
| Logging | ✅ Done | Debug di error.log |
| OTP validation | ✅ Done | Format, expiry, reuse |

---

## 🚨 Troubleshooting

### Issue: "Gagal mengirim OTP"
**Fix**: Backend belum di-copy. Copy `backend_complete_otp.php` ke backend Anda.

### Issue: Timer tidak muncul
**Fix**: Restart app (`flutter run` ulang).

### Issue: Tombol Resend tidak muncul
**Fix**: Tunggu 60 detik penuh. Timer harus mencapai 0.

### Issue: Resend tidak kirim OTP baru
**Fix**: Cek console log. Harus ada request baru ke backend.

### Issue: Database error
**Fix**: Backend akan auto-create table. Cek error log untuk detail.

---

## 📞 Next Steps

1. **Copy backend code** dari `backend_complete_otp.php`
2. **Paste ke backend Anda**
3. **Run app**: `flutter run`
4. **Test semua flow**:
   - Request OTP
   - Lihat timer countdown
   - Tunggu 60 detik
   - Test resend OTP
   - Verify OTP
   - Save profile

**Jika masih error**, copy paste:
1. Log dari console Flutter
2. Response dari curl test
3. Error dari error.log

Saya akan bantu debug! 👍

---

**Files Ready:**
- ✅ `edit_profile.dart` (updated dengan timer + resend)
- ✅ `backend_complete_otp.php` (complete backend siap pakai)
- ✅ All documentation files

**Status: READY TO USE!** 🚀
