# 🔧 DEBUG GUIDE - OTP Tidak Terkirim & Timer Tidak Muncul

## ⚠️ Masalah yang Dilaporkan

1. ❌ Email tidak terkirim / kode OTP tidak ada
2. ❌ Timer tidak muncul di dialog

---

## 🔍 DEBUG STEP-BY-STEP

### STEP 1: Test Backend Langsung (PALING PENTING!)

#### Method A: Gunakan Test HTML

1. **Buka file**: `test_otp_backend.html` (yang baru saya buat)
2. **Klik kanan** → Open with → Browser (Chrome/Firefox)
3. **Klik tombol** "Test Request OTP"
4. **Lihat hasilnya**:

**✅ Jika Berhasil:**
```
Response Status: 200
Response: {
  "success": true,
  "debug_otp": "123456",
  ...
}
```

**❌ Jika Gagal:**
```
Response Status: 404/500
atau
Error: Failed to fetch
```

#### Method B: Gunakan PowerShell

```powershell
# Test Request OTP
$body = @{
    user_id = 1
    new_email = "test@example.com"
} | ConvertTo-Json

Invoke-WebRequest -Uri "http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp" -Method POST -Body $body -ContentType "application/json" -UseBasicParsing | Select-Object StatusCode, Content
```

**Expected Output:**
```
StatusCode Content
---------- -------
       200 {"success":true,"debug_otp":"123456",...}
```

---

### STEP 2: Cek Kondisi Backend

#### 2.1 Apakah File Backend Sudah Ada?

**Cek di folder backend Anda:**
```
monitoring_api/
├── index.php           ← Harus ada handler OTP di sini
└── ...
```

**Cara cek:**
```powershell
# List isi folder
Get-ChildItem "C:\xampp\htdocs\monitoring_api\" -Name

# Cari handler OTP di file
Select-String -Path "C:\xampp\htdocs\monitoring_api\index.php" -Pattern "request-email-otp"
```

**Jika TIDAK ada**:
→ Backend belum di-implement!
→ Copy code dari `backend_complete_otp.php` ke `index.php`

#### 2.2 Apakah XAMPP Running?

**Test:**
```powershell
# Test Apache
curl http://localhost

# Test monitoring_api
curl http://localhost/monitoring_api/index.php
```

**Jika error "Connection refused"**:
→ XAMPP Apache belum running
→ Buka XAMPP Control Panel → Start Apache & MySQL

#### 2.3 Cek Error Log

**Buka file log:**
```
C:\xampp\apache\logs\error.log
```

**Lihat error terakhir** (scroll ke bawah):
- Parse error? → Syntax error di PHP
- Database error? → Connection gagal
- Undefined function? → Function belum ada

---

### STEP 3: Debug Frontend

#### 3.1 Cek Console Output

Saat run app, console harus menampilkan log detail.

**Run app dengan:**
```powershell
cd "c:\Tuturu\File alvan\PENS\KP\monitoring"
flutter run -v
```

**Saat klik "Verifikasi Email", harus muncul:**
```
=== REQUEST OTP ===
User ID: 1
New Email: your.email@example.com
=== API: Request Email Change OTP ===
URL: http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp
Response Status: 200
Response Body: {"success":true,"debug_otp":"123456"}
```

**Jika Response Status bukan 200:**
- 404 → Backend endpoint tidak ditemukan
- 500 → Error di backend PHP
- No response → Apache tidak running

#### 3.2 Cek Dialog Muncul

**Setelah response sukses, dialog harus muncul dengan:**
- ✓ Input field OTP
- ✓ Timer countdown (60, 59, 58, ...)
- ✓ Debug OTP ditampilkan (jika ada di response)

**Jika dialog TIDAK muncul:**
```dart
// Cek apakah ada error di console
// Flutter exception atau BuildContext error
```

#### 3.3 Cek Timer Widget

Timer ada di widget `_OtpDialog`. Cek di console:
```
flutter: Timer started: 60 seconds
flutter: Remaining: 59
flutter: Remaining: 58
...
```

**Jika tidak ada log timer:**
→ Widget tidak ter-render dengan benar
→ Atau ada error saat build

---

### STEP 4: Kemungkinan Penyebab & Solusi

#### ❌ Masalah 1: Backend Belum Implement

**Cek:**
```powershell
curl http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp
```

**Jika Response 404 atau blank:**

**SOLUSI:**
1. Buka: `backend_complete_otp.php`
2. Copy SEMUA isinya
3. Paste ke file backend:
   - Jika pakai `index.php` → paste di dalam file
   - Atau buat file `otp_handler.php` → include di index.php

**Contoh Include:**
```php
<?php
// di index.php
require_once 'otp_handler.php';
?>
```

#### ❌ Masalah 2: Database Connection Error

**Test Connection:**
```php
<?php
// Test database
$conn = new mysqli('localhost', 'root', '', 'monitoring');
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully";
?>
```

**SOLUSI:**
- Cek username/password MySQL
- Cek nama database benar
- Pastikan MySQL running di XAMPP

#### ❌ Masalah 3: Table Belum Ada

Backend saya sudah auto-create table, tapi cek manual:

```sql
-- Run di phpMyAdmin
SHOW TABLES LIKE 'otp_tokens';

-- Jika tidak ada, create manual:
CREATE TABLE otp_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT FALSE
);
```

#### ❌ Masalah 4: CORS Error (Jika Run di Web)

**Jika ada error CORS di console:**

**SOLUSI - Tambah header di backend:**
```php
<?php
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST, GET, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');
?>
```

#### ❌ Masalah 5: Timer Tidak Render

**Debug Widget:**

Edit file `edit_profile.dart`, tambah log di `_OtpDialogState`:

```dart
@override
void initState() {
  super.initState();
  print('OTP Dialog initialized'); // ← Tambah ini
  _startTimer();
}

void _startTimer() {
  print('Starting timer: $_remainingSeconds seconds'); // ← Tambah ini
  setState(() {
    _remainingSeconds = 60;
    _canResend = false;
  });

  _timer?.cancel();
  _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
    print('Timer tick: $_remainingSeconds'); // ← Tambah ini
    if (_remainingSeconds > 0) {
      setState(() {
        _remainingSeconds--;
      });
    } else {
      setState(() {
        _canResend = true;
      });
      timer.cancel();
    }
  });
}
```

**Run ulang dan cek console - harus ada:**
```
OTP Dialog initialized
Starting timer: 60 seconds
Timer tick: 60
Timer tick: 59
Timer tick: 58
...
```

---

## 🎯 QUICK FIX CHECKLIST

```
□ XAMPP Apache running
□ XAMPP MySQL running
□ Backend file exists dengan handler OTP
□ Test backend dengan test_otp_backend.html → berhasil?
□ Database connection OK
□ Table otp_tokens exists (atau auto-created)
□ Flutter app running
□ Console shows detail logs saat klik verifikasi
□ Response status 200 dari backend
□ Dialog muncul setelah response success
□ Timer countdown visible di dialog
```

---

## 💡 SOLUSI TERCEPAT

### Jika Backend Belum Ada SAMA SEKALI:

1. **Download/Copy backend_complete_otp.php**
2. **Rename ke**: `monitoring_api/otp_handler.php`
3. **Edit index.php**, tambah di awal:**
   ```php
   <?php
   require_once 'otp_handler.php';
   ?>
   ```
4. **Restart Apache** di XAMPP
5. **Test dengan**: `test_otp_backend.html`

### Jika Backend Sudah Ada Tapi Tidak Kerja:

1. **Cek error.log**: `C:\xampp\apache\logs\error.log`
2. **Fix error** yang muncul
3. **Test ulang**

### Jika Email Tidak Terkirim (tapi OTP generate):

**INI NORMAL!** Backend dalam testing mode.

- OTP di-generate ✓
- OTP di-simpan di database ✓
- OTP dikembalikan di response (`debug_otp`) ✓
- Email TIDAK dikirim (testing mode) ⚠️

**Untuk kirim real email:**
1. Buka `backend_complete_otp.php`
2. Function `sendOtpEmail()`
3. Comment line: `return true;`
4. Uncomment METHOD 2 (PHPMailer) atau METHOD 3
5. Configure SMTP

---

## 📞 Jika Masih Gagal

**Kirim ke saya:**

1. **Screenshot/Copy output** dari `test_otp_backend.html`
2. **Console log** Flutter (saat klik verifikasi)
3. **Error log** dari `C:\xampp\apache\logs\error.log` (10 baris terakhir)
4. **Screenshot** dialog (jika muncul)

**Command untuk ambil error log:**
```powershell
Get-Content "C:\xampp\apache\logs\error.log" -Tail 20
```

---

**Next Action:** Coba buka `test_otp_backend.html` di browser dan test!

Hasil test dari HTML tersebut akan sangat membantu debug masalahnya. 🔍
