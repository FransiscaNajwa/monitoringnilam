# 🚀 QUICK START GUIDE - EMAIL VERIFICATION FEATURE

## 📦 Yang Sudah Selesai

✅ **Fitur Verifikasi Email dengan OTP sudah fully implemented di `lib/edit_profile.dart`**

Tidak perlu menambah dependency atau library baru - semuanya menggunakan Flutter built-in widgets dan existing API service.

## ⚡ Quick Setup (5 Menit)

### 1. Verify Backend API adalah Ready

Pastikan backend sudah memiliki 2 endpoint ini:

#### ✓ Endpoint 1: Request OTP
```bash
POST http://localhost/monitoring_api/index.php?endpoint=auth&action=request-email-otp
Headers: Content-Type: application/json
Body: {
  "user_id": 1,
  "new_email": "user@newemail.com"
}
Response: {
  "success": true,
  "message": "OTP sent successfully",
  "debug_otp": "123456"  // optional untuk testing
}
```

#### ✓ Endpoint 2: Verify OTP
```bash
POST http://localhost/monitoring_api/index.php?endpoint=auth&action=verify-email-otp
Headers: Content-Type: application/json
Body: {
  "user_id": 1,
  "new_email": "user@newemail.com",
  "otp": "123456"
}
Response: {
  "success": true,
  "message": "Email verified successfully"
}
```

### 2. Update API Base URL (if needed)

File: `lib/services/api_service.dart` (Line 8)
```dart
static const String baseUrl = 'http://localhost/monitoring_api/index.php';
```
*Sesuaikan dengan actual backend URL Anda*

### 3. Test di App

```bash
# Terminal 1: Start backend (XAMPP)
xampp-control (Windows) atau start XAMPP manually

# Terminal 2: Run Flutter app
flutter run
```

### 4. Manual Testing Flow

1. **Open Edit Profile page**
2. **Change email to new one** → Tombol "Verifikasi" muncul
3. **Click verification button** → Dialog input OTP muncul
4. **Input OTP** → Copy dari email atau debug message
5. **Click Verifikasi** → Email marked as verified (green border)
6. **Click Simpan Perubahan** → Profile saved successfully

## 🎯 Key Features at a Glance

| Feature | Status | Where |
|---------|--------|-------|
| Email field dengan tombol verifikasi | ✅ Done | `_buildEmailFieldWithVerification()` |
| OTP request & send | ✅ Done | `_handleEmailVerification()` |
| OTP input dialog | ✅ Done | `_showOtpInputDialog()` |
| OTP verification | ✅ Done | `_verifyOtpAndMarkEmail()` |
| Visual feedback (border color, icons) | ✅ Done | Widget styling |
| Validation & error handling | ✅ Done | Throughout methods |
| State management | ✅ Done | 5 state variables |

## 🔧 Files Changed

```
📁 monitoring/
├── 📄 lib/edit_profile.dart ← ✅ MODIFIED (~350 lines added)
├── 📄 lib/services/api_service.dart ← ✅ ALREADY HAD OTP methods
└── 📄 IMPLEMENTATION_SUMMARY.md ← ℹ️ Documentation
```

## 🎨 UI Overview

### Before (Email tanpa verifikasi)
```
Email
┌─────────────────────────────┐
│ [📧] user@old.com           │
└─────────────────────────────┘
```

### During (Email ubah → button verifikasi muncul)
```
Email
┌──────────────────────┐  ┌─────────┐
│ [📧] user@new.com    │  │ [🔒] Ver│
└──────────────────────┘  └─────────┘
⚠️  Klik tombol untuk verifikasi...
```

### After (Email verified)
```
Email
┌──────────────────────┐  ┌─────────┐
│ [📧] user@new.com [✓]│  │ [✓] Ver │
└──────────────────────┘  └─────────┘
✓ Email berhasil diverifikasi!
```

## 📋 Checklist Implementation

- [x] Add state variables untuk tracking verification
- [x] Add method untuk handle email verification button click
- [x] Add method untuk show OTP input dialog
- [x] Add method untuk verify OTP
- [x] Add method untuk build email field dengan button
- [x] Update save logic untuk require verification jika email berubah
- [x] Add visual feedback (colors, icons, messages)
- [x] Add error handling & validation
- [x] Test untuk memastikan tidak ada error

## ⚙️ Configuration Options

### 1. Debug OTP Display (untuk testing)

File: `lib/edit_profile.dart`, Lines ~220

```dart
if (response['debug_otp'] != null) {
  // Debug OTP ditampilkan di dialog
}
```

**Untuk Production:** Hapus block ini

```dart
// Delete these lines:
if (response['debug_otp'] != null) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Kode OTP (Demo): ${response['debug_otp']}'),
      duration: const Duration(seconds: 10),
    ),
  );
}
```

### 2. OTP Length Validation

File: `lib/edit_profile.dart`, Line ~260

```dart
if (otp.isEmpty || otp.length != 6) {
  // Currently set to 6 digits
}
```

**Ubah ke:** `otp.length != 4` untuk 4 digits, etc.

### 3. Email Validation Regex

File: `lib/edit_profile.dart`, Line ~90

```dart
if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail)) {
  // Current regex adalah basic validation
}
```

**Untuk lebih strict:** 
```dart
if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(newEmail)) {
```

## 🐛 Common Issues & Solutions

### Issue 1: "Gagal mengirim OTP" message
**Solution:** 
- [ ] Check backend server running
- [ ] Check API endpoint URL di `api_service.dart`
- [ ] Verify `/auth&action=request-email-otp` endpoint exists
- [ ] Check network connection

### Issue 2: Dialog tidak muncul
**Solution:**
- [ ] Check `mounted` state
- [ ] Verify context is valid
- [ ] Check error message di console

### Issue 3: OTP verification always fails
**Solution:**
- [ ] Check OTP format (harus 6 digit)
- [ ] Verify backend `/auth&action=verify-email-otp` endpoint
- [ ] Check OTP expiry time di backend
- [ ] Verify email parameter dikirim dengan benar

### Issue 4: Email field tidak reset saat ubah
**Solution:**
- [ ] Ensure `onChanged()` callback di TextFormField di-trigger
- [ ] Check `setState()` properly called

### Issue 5: "Silakan verifikasi email..." tapi sudah klik verify
**Solution:**
- [ ] Check `_emailVerified` state properly set ke `true`
- [ ] Check `_emailInVerification` match dengan email di field
- [ ] Try reload halaman

## 📚 Documentation Files

| File | Purpose |
|------|---------|
| `IMPLEMENTATION_SUMMARY.md` | Overview keseluruhan & checklist |
| `EMAIL_VERIFICATION_FEATURE.md` | Detailed fitur description |
| `UI_UX_FLOW.md` | Visual UI flow & state diagram |
| `CODE_CHANGES_DETAIL.md` | Detailed code changes & logic |
| `TESTING_CHECKLIST.md` | Comprehensive testing checklist |
| `QUICK_START_GUIDE.md` | This file - quick reference |

## 🚨 Important Notes

1. **Backend MUST implement OTP sending** - Currently app calls API endpoint, but backend must actually send email
2. **Email SMTP configuration** - Backend perlu email service configured untuk kirim OTP
3. **Database storage** - Backend harus menyimpan OTP temporary dengan expiry time
4. **Security** - Jangan hardcode password/email credentials di client
5. **Testing mode** - Debug OTP feature aktif untuk testing, harus di-disable production

## ✅ Ready to Deploy Checklist

Before going to production:

- [ ] Backend OTP endpoints fully implemented & tested
- [ ] Email SMTP/service configured
- [ ] Remove debug OTP display from dialog
- [ ] Set proper OTP expiry time (e.g., 5 minutes)
- [ ] Implement rate limiting untuk OTP requests
- [ ] Test dengan real email addresses
- [ ] Test dengan berbagai network conditions
- [ ] Verify security measures implemented
- [ ] Update `baseUrl` ke production server
- [ ] Test error handling di production
- [ ] Monitor OTP delivery success rate

## 🎓 Learning Resources

### State Management
- Lines 26-31: State variables definition
- Lines 325-352: How state changes during save

### Widget Building
- Lines 906-1065: Complete email field widget example
- Lines 144-266: Dialog widget implementation

### API Integration
- Lines 75-142: How to call API methods
- Lines 268-323: How to handle API responses

### UI/UX Patterns
- Color feedback: Lines 950-970 (border colors)
- Visual states: Lines 963-1030 (button & icon states)
- Helper messages: Lines 1040-1065 (informational text)

## 📞 Support

If something's not working:

1. Check `TESTING_CHECKLIST.md` untuk debug steps
2. Review `CODE_CHANGES_DETAIL.md` untuk understand logic
3. Check console output untuk error messages
4. Verify backend endpoints returning correct format

---

**Status**: ✅ Ready to Use  
**Last Updated**: February 2, 2026  
**Version**: 1.0
