# ✅ TESTING CHECKLIST - EMAIL VERIFICATION FEATURE

## Pre-Test Setup
- [ ] Backend server berjalan (XAMPP/API)
- [ ] Database migration sudah done
- [ ] Email service/SMTP configured
- [ ] Api endpoints `/auth&action=request-email-otp` dan `/auth&action=verify-email-otp` tersedia

## 🧪 Functional Testing

### Test 1: Email Tidak Berubah (No Verification Needed)
- [ ] Login ke aplikasi
- [ ] Buka Edit Profile
- [ ] Lihat email field sudah terisi dengan email lama
- [ ] Jangan ubah email
- [ ] Langsung klik "Simpan Perubahan"
- **Expected:** Profile save berhasil, tidak perlu verifikasi

### Test 2: Email Berubah - Happy Path
- [ ] Login ke aplikasi
- [ ] Buka Edit Profile
- [ ] Ubah email ke alamat baru yang valid (misal: `test.new@example.com`)
- [ ] Verifikasi tombol "Verifikasi Email" muncul dengan ikon security
- [ ] Klik tombol "Verifikasi Email"
- [ ] Loading indicator tampil dan hilang
- [ ] Dialog "Verifikasi Email" muncul menampilkan alamat email tujuan
- [ ] Copy kode OTP dari email atau dari debug message di dialog
- [ ] Masukkan kode OTP ke input field (6 digit)
- [ ] Klik tombol "Verifikasi"
- [ ] Dialog tutup otomatis
- [ ] Email field border berubah hijau
- [ ] Ikon check circle muncul di sebelah email
- [ ] Success message: "Email berhasil diverifikasi!"
- [ ] Klik "Simpan Perubahan"
- **Expected:** Profile save berhasil dengan email baru

### Test 3: Try Save Without Verification
- [ ] Login dan buka Edit Profile
- [ ] Ubah email ke alamat baru
- [ ] Jangan klik tombol verifikasi
- [ ] Langsung klik "Simpan Perubahan"
- **Expected:** Error message: "Silakan verifikasi email terlebih dahulu..."
- [ ] Tombol "Simpan Perubahan" disabled, tidak bisa jalan
- [ ] Profile tidak tersimpan

### Test 4: Email Format Validation
- [ ] Ubah email ke format invalid (misal: `invalid-email` atau `test@`)
- [ ] Klik tombol "Verifikasi Email"
- **Expected:** Error message: "Format email tidak valid"
- [ ] Dialog OTP tidak muncul

### Test 5: Empty Email Validation
- [ ] Clear email field (kosong)
- [ ] Klik tombol "Verifikasi Email"
- **Expected:** Error message: "Email tidak boleh kosong"
- [ ] Dialog OTP tidak muncul

### Test 6: Email Sama Dengan Current (No Verification Needed)
- [ ] Load current email
- [ ] Clear field dan type sama dengan email saat ini
- [ ] Klik tombol "Verifikasi Email"
- **Expected:** Success message: "Email sama dengan email saat ini. Tidak perlu verifikasi."
- [ ] Email marked as verified (border green, check icon)
- [ ] Bisa langsung save tanpa input OTP

### Test 7: OTP Validation - Empty OTP
- [ ] Ubah email ke yang baru
- [ ] Klik "Verifikasi Email"
- [ ] Dialog muncul, jangan input OTP
- [ ] Klik tombol "Verifikasi"
- **Expected:** Error message: "Silakan masukkan kode OTP 6 digit"
- [ ] Dialog tidak tutup

### Test 8: OTP Validation - Less Than 6 Digits
- [ ] Ubah email ke yang baru
- [ ] Klik "Verifikasi Email"
- [ ] Dialog muncul, input OTP hanya 3 digit (misal: `123`)
- [ ] Klik tombol "Verifikasi"
- **Expected:** Error message: "Silakan masukkan kode OTP 6 digit"
- [ ] Dialog tidak tutup

### Test 9: OTP Validation - Wrong OTP
- [ ] Ubah email ke yang baru
- [ ] Klik "Verifikasi Email"
- [ ] Dialog muncul
- [ ] Input OTP yang salah (misal: `999999`)
- [ ] Klik tombol "Verifikasi"
- [ ] Dialog tutup
- **Expected:** Error message: "Verifikasi OTP gagal. Silakan coba lagi." atau sesuai backend response
- [ ] Email field tetap tidak verified (border tetap biru)

### Test 10: OTP Timeout/Expired
- [ ] Ubah email ke yang baru
- [ ] Klik "Verifikasi Email"
- [ ] Tunggu hingga OTP expired (jika ada timeout)
- [ ] Input OTP yang expired
- [ ] Klik "Verifikasi"
- **Expected:** Error message dari backend tentang OTP expired
- [ ] Dialog tutup

### Test 11: Change Email Again (Reset Verification)
- [ ] Ubah email ke `test1@example.com`
- [ ] Verifikasi dan berhasil (border green)
- [ ] Ubah email ke `test2@example.com`
- [ ] Verifikasi state reset (border biru kembali, check icon hilang)
- [ ] Warning message muncul lagi: "Klik tombol Verifikasi..."
- **Expected:** State properly reset untuk email baru

### Test 12: Revert Email to Current
- [ ] Ubah email ke `test@example.com`
- [ ] Clear dan revert kembali ke email asli
- [ ] Tombol verifikasi hilang
- [ ] Bisa langsung save
- **Expected:** Profile save berhasil tanpa verifikasi

### Test 13: Cancel OTP Dialog
- [ ] Ubah email ke yang baru
- [ ] Klik "Verifikasi Email"
- [ ] Dialog muncul
- [ ] Klik tombol "Batal"
- [ ] Dialog tutup
- **Expected:** Email field tetap tidak verified, warning message muncul
- [ ] State properly reset

### Test 14: Loading States
- [ ] Verifikasi loading indicator tampil saat mengirim OTP
- [ ] Verifikasi loading indicator tampil saat verifikasi OTP
- [ ] Tombol tidak bisa di-klik saat loading
- [ ] Loading indicator hilang setelah selesai

### Test 15: Multiple Field Changes with Email Verification
- [ ] Ubah nama, username, email, phone, dll
- [ ] Email belum terverifikasi
- [ ] Klik "Simpan Perubahan"
- **Expected:** Hanya error untuk email verification, field lain tidak error
- [ ] Verifikasi email terlebih dahulu
- [ ] Klik "Simpan Perubahan" lagi
- [ ] All fields save berhasil

## 🎨 UI/UX Testing

### Test 16: Visual States - Email Not Changed
- [ ] Border color: Blue (#1976D2)
- [ ] Button: Not visible
- [ ] Icon: Only email icon
- [ ] Helper text: Not visible

### Test 17: Visual States - Email Changed (Unverified)
- [ ] Border color: Blue (#1976D2)
- [ ] Button: Visible, blue, with security icon
- [ ] Icon: Email icon + check icon hidden
- [ ] Helper text: Orange warning message visible
- [ ] Spacing: Consistent dengan field lain

### Test 18: Visual States - Email Verified
- [ ] Border color: Green (#4CAF50)
- [ ] Button: Green, with check icon
- [ ] Icon: Email icon + green check circle
- [ ] Helper text: Green success message visible
- [ ] Visual consistency: Check mark clear dan obvious

### Test 19: Dialog Layout - Mobile
- [ ] Dialog readable di mobile screen
- [ ] Input field tidak ter-crop
- [ ] Tombol accessible
- [ ] Text wrapping proper
- [ ] Font size readable

### Test 20: Dialog Layout - Desktop
- [ ] Dialog centered di screen
- [ ] Max width constraint respected
- [ ] Spacing konsisten
- [ ] All elements visible

### Test 21: Responsive Design
- [ ] Test di berbagai screen size
- [ ] Button position/size adjust properly
- [ ] Text tidak overflow
- [ ] Icons visible di semua size

## 🔐 Security Testing

### Test 22: OTP Delivery
- [ ] OTP dikirim ke email yang correct
- [ ] Jangan ada OTP di URL/logs/network tab
- [ ] OTP tidak visible di plaintext di storage

### Test 23: Session Security
- [ ] Verifikasi di one user session
- [ ] Logout dan login ulang
- [ ] State properly reset
- [ ] Can't use old verification token

### Test 24: CSRF/XSS
- [ ] No suspicious characters di email field dapat disimpan
- [ ] Injection attempt di OTP field properly escaped
- [ ] Backend validate input

### Test 25: SQL Injection Prevention
- [ ] Email dengan character special (misal: `a'b@test.com`)
- [ ] OTP dengan character special
- [ ] Backend properly escape query

## 📱 Cross-Browser Testing

### Test 26: Chrome
- [ ] All features work
- [ ] UI render properly
- [ ] No console errors

### Test 27: Firefox
- [ ] All features work
- [ ] UI render properly
- [ ] No console errors

### Test 28: Safari
- [ ] All features work
- [ ] UI render properly
- [ ] No console errors

### Test 29: Edge
- [ ] All features work
- [ ] UI render properly
- [ ] No console errors

## 🐛 Error Handling

### Test 30: Network Error During OTP Request
- [ ] Disconnect internet
- [ ] Klik "Verifikasi Email"
- **Expected:** Error message, proper handling, not crash

### Test 31: Network Error During OTP Verify
- [ ] Request OTP successfully
- [ ] Disconnect internet
- [ ] Input OTP dan klik Verifikasi
- **Expected:** Error message, dialog stays open or close gracefully

### Test 32: Server Error Response
- [ ] Backend returns error (misal: 500, 400)
- [ ] Aplikasi show error message
- [ ] No crash
- [ ] User dapat retry

### Test 33: Invalid Response Format
- [ ] Backend returns invalid JSON
- [ ] Aplikasi handle dengan graceful
- [ ] Show generic error message
- [ ] No crash

## 📊 Performance Testing

### Test 34: Load Time
- [ ] Edit Profile page load < 2 seconds
- [ ] Tombol verifikasi appear instantly
- [ ] Dialog muncul < 1 second

### Test 35: OTP Request Response Time
- [ ] Request OTP respond < 3 seconds
- [ ] No freezing UI saat request
- [ ] Loading indicator smooth

### Test 36: Memory Leak
- [ ] Open/close dialog multiple times
- [ ] Memory tidak meningkat drastis
- [ ] No performance degradation

## ✅ Final Verification

- [ ] All test cases passed
- [ ] No critical bugs
- [ ] No console errors/warnings
- [ ] No memory leaks
- [ ] Performance acceptable
- [ ] UX smooth dan intuitive
- [ ] Error messages helpful
- [ ] Code formatted properly
- [ ] No unused variables/imports

## 📝 Sign-Off

| Item | Status | Notes |
|------|--------|-------|
| Feature Complete | ✅ | All features implemented |
| Testing Complete | ⬜ | Pending |
| QA Approved | ⬜ | Pending |
| Ready for Production | ⬜ | Pending |

---

**Testing Date:** _____________
**Tester Name:** _____________
**Comments:** _____________
