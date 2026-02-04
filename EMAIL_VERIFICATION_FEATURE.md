# Fitur Verifikasi Email dengan OTP

## Deskripsi Fitur
Fitur ini mengimplementasikan verifikasi email dengan One-Time Password (OTP) sebelum pengguna dapat mengubah email mereka di halaman Edit Profile.

## Alur Kerja

### 1. **Pengisian Email Baru**
   - User memasukkan email baru di kolom Email
   - Sistem otomatis mendeteksi perubahan email dibandingkan email saat ini
   - Jika email berubah, tombol "Verifikasi" akan tampil di sebelah kolom email

### 2. **Mengirim Kode OTP**
   - User mengklik tombol "Verifikasi Email" (ikon security)
   - Sistem melakukan validasi format email
   - Jika valid, sistem mengirim kode OTP ke email baru
   - Dialog popup muncul untuk input kode OTP

### 3. **Memasukkan Kode OTP**
   - User menerima email dengan kode OTP 6 digit
   - User memasukkan kode OTP di dialog popup
   - Tombol "Verifikasi" di dialog untuk submit OTP

### 4. **Verifikasi Berhasil**
   - Jika OTP benar, email ditandai sebagai terverifikasi
   - Tombol verifikasi berubah warna menjadi hijau dengan ikon check
   - Pesan sukses ditampilkan
   - User dapat menyimpan perubahan profil

### 5. **Menyimpan Profil**
   - User mengklik "Simpan Perubahan"
   - Sistem melakukan pengecekan:
     - Jika email sama dengan email saat ini: bisa disimpan langsung
     - Jika email berbeda: harus sudah terverifikasi terlebih dahulu
   - Profile update berhasil dan data tersimpan di database

## Komponen UI

### Email Field dengan Verifikasi
- Kolom input email (dapat disunting kapan saja)
- Tombol verifikasi yang muncul saat email berubah
- Status indicator (warna border, ikon check)
- Pesan informasi atau peringatan di bawah field

### Dialog OTP Verification
- Menampilkan email tujuan pengiriman OTP
- Input field untuk 6 digit kode OTP
- Tombol Batal untuk membatalkan verifikasi
- Tombol Verifikasi untuk submit OTP
- Fitur demo: menampilkan OTP untuk testing (bisa dimatikan di production)

## State Variables

```dart
bool _emailVerified = false;        // Status verifikasi email
bool _otpSent = false;              // Status OTP sudah dikirim
String _emailInVerification = '';   // Email yang sedang diverifikasi
String _currentEmail = '';          // Email saat ini dari database
bool _emailChanged = false;         // Flag perubahan email
```

## Methods Utama

### `_handleEmailVerification()`
- Validasi format email
- Deteksi jika email sama dengan email saat ini
- Request OTP ke server
- Show OTP input dialog

### `_showOtpInputDialog(String newEmail, String? debugOtp)`
- Menampilkan dialog input OTP
- Validasi input 6 digit
- Handle submit OTP

### `_verifyOtpAndMarkEmail(String email, String otp)`
- Verifikasi OTP ke server
- Update state jika verifikasi berhasil
- Show success/error message

### `_saveChanges()`
- Check apakah email sudah terverifikasi jika ada perubahan
- Prevent save jika email berubah tapi belum terverifikasi
- Call `_performUpdate()` untuk save data

## Endpoint API yang Digunakan

### Request OTP
```
POST /monitoring_api/index.php?endpoint=auth&action=request-email-otp
Body: {
  user_id: int,
  new_email: string
}
Response: {
  success: bool,
  message: string,
  debug_otp?: string  // untuk testing
}
```

### Verify OTP
```
POST /monitoring_api/index.php?endpoint=auth&action=verify-email-otp
Body: {
  user_id: int,
  new_email: string,
  otp: string
}
Response: {
  success: bool,
  message: string
}
```

## Keamanan

- OTP dikirim via email ke alamat tujuan
- OTP hanya valid untuk durasi tertentu (ditentukan di backend)
- Validasi format email sebelum request OTP
- Validasi input OTP harus 6 digit
- Email hanya bisa diubah jika sudah terverifikasi

## Testing

### Scenario 1: Email Baru Valid
1. Ubah email ke alamat baru yang valid
2. Klik tombol "Verifikasi Email"
3. Input kode OTP yang diterima (atau gunakan debug OTP)
4. Klik "Verifikasi"
5. Email ditandai terverifikasi (warna hijau)
6. Simpan perubahan profil

### Scenario 2: Email Tidak Berubah
1. Tidak mengubah field email
2. Langsung klik "Simpan Perubahan"
3. Profil disimpan tanpa perlu verifikasi

### Scenario 3: Email Format Invalid
1. Ubah email dengan format tidak valid
2. Klik tombol "Verifikasi Email"
3. Sistem menampilkan pesan error "Format email tidak valid"

### Scenario 4: OTP Salah
1. Input kode OTP yang salah
2. Klik "Verifikasi"
3. Sistem menampilkan pesan error dari server

## Notes

- Debug OTP ditampilkan di dialog untuk memudahkan testing
- Di production, fitur debug ini bisa dimatikan dengan menghapus check `if (debugOtp != null)`
- Pastikan backend sudah mengimplementasikan endpoint OTP dengan benar
- Email verification state di-reset jika user mengubah email lagi
