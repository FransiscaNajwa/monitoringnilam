# DETAIL PERUBAHAN CODE - EMAIL VERIFICATION FEATURE

## 📋 Overview Perubahan

File yang dimodifikasi: **lib/edit_profile.dart**
- Total baris ditambahkan: ~350 lines
- Struktur file: Tetap sama, hanya ada penambahan methods dan state variables

## 1️⃣ STATE VARIABLES (Lines 26-31)

### Ditambahkan:
```dart
// Email verification state
bool _emailVerified = false;
bool _otpSent = false;
String _emailInVerification = '';
String _currentEmail = '';
bool _emailChanged = false;
```

**Penjelasan:**
- `_emailVerified`: Track apakah email saat ini terverifikasi
- `_otpSent`: Track apakah OTP sudah dikirim
- `_emailInVerification`: Simpan email yang sedang dalam proses verifikasi
- `_currentEmail`: Simpan email asli saat load user data (untuk perbandingan)
- `_emailChanged`: Flag untuk tracking perubahan email

## 2️⃣ _loadUserData() METHOD (Lines 47-66)

### Perubahan:
```dart
Future<void> _loadUserData() async {
  final userData = await AuthHelper.getUserData();
  setState(() {
    _userId = int.tryParse(userData['user_id'] ?? '');
    _nameController.text = userData['fullname'] ?? '';
    _usernameController.text = userData['username'] ?? '';
    _emailController.text = userData['email'] ?? '';
    _phoneController.text = userData['phone'] ?? '';
    _locationController.text = userData['location'] ?? '';
    _divisionController.text = userData['division']?.isNotEmpty == true
        ? userData['division']!
        : (userData['role'] ?? '');
    
    // ✅ ADDED: Set current email untuk comparison
    _currentEmail = userData['email'] ?? '';
    _emailVerified = true; // Current email sudah verified
  });
}
```

**Perubahan:**
- Tambah 2 baris di akhir untuk set `_currentEmail` dan `_emailVerified`
- Ini memastikan email asli dianggap sudah terverifikasi

## 3️⃣ NEW METHOD: _handleEmailVerification() (Lines 75-142)

### Fungsi:
Ditrigger saat user klik tombol "Verifikasi Email"

### Logika:
1. Ambil email dari text controller
2. Validasi format email
3. Cek jika email sama dengan email saat ini → mark as verified, return
4. Request OTP ke API
5. Update state dan show dialog input OTP

### Key Code:
```dart
// Validasi format
if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(newEmail)) {
  // Show error
}

// Check if same as current
if (newEmail == _currentEmail) {
  setState(() {
    _emailVerified = true;
    _emailInVerification = newEmail;
  });
  return;
}

// Request OTP
final response = await apiService.requestEmailChangeOtp(_userId!, newEmail);
```

## 4️⃣ NEW METHOD: _showOtpInputDialog() (Lines 144-266)

### Fungsi:
Menampilkan dialog untuk input kode OTP

### Widget Hierarchy:
```
AlertDialog
├── title: "Verifikasi Email"
├── content: Column
│   ├── Text: "Kode verifikasi telah dikirim ke:"
│   ├── Container with email display
│   ├── Text: "Silakan masukkan kode OTP:"
│   ├── TextField: untuk input 6 digit OTP
│   └── [Optional] Debug OTP display
└── actions: [Batal, Verifikasi]
```

### Key Features:
- TextFormField dengan maxLength 6 digit
- Display debug OTP untuk testing (bisa diremove di production)
- Validasi input 6 digit sebelum submit
- Tombol batal untuk reset state

## 5️⃣ NEW METHOD: _verifyOtpAndMarkEmail() (Lines 268-323)

### Fungsi:
Verifikasi OTP ke server dan update state

### Logika:
1. Show loading state
2. Call API endpoint `verifyEmailChangeOtp()`
3. Jika success: update state, mark email as verified, show success message
4. Jika fail: show error message
5. Jika exception: show error message

### Key Code:
```dart
setState(() {
  _emailVerified = true;
  _emailInVerification = email;
  _otpSent = false;
  _isLoading = false;
});
```

## 6️⃣ UPDATED METHOD: _saveChanges() (Lines 325-352)

### Perubahan:
```dart
void _saveChanges() async {
  if (_formKey.currentState!.validate()) {
    // ... existing validation ...

    // ✅ ADDED: Check if email changed
    final newEmail = _emailController.text.trim();

    if (newEmail != _currentEmail) {
      // Email changed, need verification
      if (!_emailVerified || _emailInVerification != newEmail) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan verifikasi email terlebih dahulu...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }

    _performUpdate();
  }
}
```

**Perubahan:**
- Remove old `_showOtpDialog()` call
- Tambah validasi: jika email berubah, harus sudah terverifikasi
- Jika belum terverifikasi, show warning dan return (tidak proceed ke save)

## 7️⃣ NEW METHOD: _buildEmailFieldWithVerification() (Lines 906-1065)

### Fungsi:
Build email input field dengan tombol verifikasi di sebelahnya

### Widget Hierarchy:
```
Column
├── Text: "Email"
├── Row
│   ├── Expanded: TextFormField
│   └── Padding + SizedBox: Tombol Verifikasi
├── [Optional] Warning message (jika perlu verifikasi)
└── [Optional] Success message (jika sudah verified)
```

### Key Features:

#### 1. Email TextFormField
```dart
TextFormField(
  controller: _emailController,
  onChanged: (value) {
    // Reset verification jika email berubah lagi
    if (value.trim() != _emailInVerification) {
      setState(() {
        _emailVerified = false;
        _otpSent = false;
      });
    }
  },
  decoration: InputDecoration(
    suffixIcon: isVerified ? Icon(Icons.check_circle) : null,
    // Border color change based on state
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: isVerified ? Colors.green : Color(0xFF1976D2),
        width: 1.5,
      ),
    ),
  ),
)
```

#### 2. Verification Button
```dart
ElevatedButton(
  onPressed: _isLoading ? null : _handleEmailVerification,
  style: ElevatedButton.styleFrom(
    backgroundColor: isVerified ? Colors.green : Color(0xFF1976D2),
  ),
  child: _isLoading
      ? CircularProgressIndicator(...)
      : (isVerified ? Icon(Icons.check) : Icon(Icons.security)),
)
```

**Button States:**
- Default (perlu verifikasi): Blue with security icon
- Loading: Blue with loading spinner
- Verified: Green with check icon

#### 3. Helper Messages
```dart
// Warning message (saat email berubah tapi belum verified)
if (isEmailChanged && !isVerified)
  Row(
    children: [
      Icon(Icons.info_outline, color: Colors.orange),
      Text('Klik tombol Verifikasi untuk mengirim kode OTP...', 
           style: TextStyle(color: Colors.orange)),
    ],
  )

// Success message (saat email sudah verified)
if (isVerified)
  Row(
    children: [
      Icon(Icons.check_circle, color: Colors.green),
      Text('Email berhasil diverifikasi!', 
           style: TextStyle(color: Colors.green)),
    ],
  )
```

### Logic Flow di Widget:
```dart
final newEmail = _emailController.text.trim();
final isEmailChanged = newEmail != _currentEmail;
final isVerificationNeeded = isEmailChanged && !_emailVerified;
final isVerified = isEmailChanged && _emailVerified && _emailInVerification == newEmail;
```

## 8️⃣ UPDATED: _buildContent() (Line ~804)

### Perubahan:
```dart
// ❌ REMOVED (lines 810-832):
_buildTextField(
  'Email',
  _emailController,
  Icons.email,
  validator: (...),
),

// ✅ REPLACED WITH:
_buildEmailFieldWithVerification(),
```

**Alasan:** Email field sekarang menggunakan widget custom yang lebih complex dengan tombol verifikasi.

## ✨ API Integration

### Existing Methods (sudah ada di api_service.dart):
```dart
// Request OTP
Future<Map<String, dynamic>> requestEmailChangeOtp(
  int userId, 
  String newEmail
)

// Verify OTP
Future<Map<String, dynamic>> verifyEmailChangeOtp(
  int userId, 
  String newEmail, 
  String otp
)
```

### Request Format:
```
POST /monitoring_api/index.php?endpoint=auth&action=request-email-otp
{
  "user_id": 1,
  "new_email": "user.new@email.com"
}

Response:
{
  "success": true/false,
  "message": "...",
  "debug_otp": "123456"  // optional, untuk testing
}
```

```
POST /monitoring_api/index.php?endpoint=auth&action=verify-email-otp
{
  "user_id": 1,
  "new_email": "user.new@email.com",
  "otp": "123456"
}

Response:
{
  "success": true/false,
  "message": "..."
}
```

## 🔄 State Flow Diagram

```
Initial Load
  ↓
_loadUserData() → _currentEmail = user@old.com, _emailVerified = true
  ↓
User ubah email input
  ↓
onChanged() trigger → if email != _currentEmail: _emailVerified = false
  ↓
User klik tombol Verifikasi
  ↓
_handleEmailVerification()
  ├─ validasi format
  ├─ check if same as current
  ├─ request OTP
  └─ show dialog input OTP
      ↓
User input OTP dan klik Verifikasi
  ↓
_verifyOtpAndMarkEmail()
  ├─ call API verify
  └─ if success: _emailVerified = true, _emailInVerification = newEmail
      ↓
Email field berubah warna hijau
  ↓
User klik "Simpan Perubahan"
  ↓
_saveChanges()
  ├─ validate form
  ├─ check if email changed
  ├─ if changed: validate _emailVerified == true
  └─ if valid: call _performUpdate()
```

## 📊 Variable State Matrix

| Scenario | _emailVerified | _otpSent | _emailInVerification | _currentEmail |
|----------|---|---|---|---|
| Initial | true | false | "" | "user@old.com" |
| Email changed | false | false | "" | "user@old.com" |
| OTP sent | false | true | "user@new.com" | "user@old.com" |
| OTP verified | true | false | "user@new.com" | "user@old.com" |
| Email changed again | false | false | "" | "user@old.com" |
| Email reverted | true | false | "" | "user@old.com" |

## 🎯 Key Implementation Details

1. **Validation Flow:**
   - Client-side: Format email, 6 digit OTP
   - Server-side: OTP expiry, validity check

2. **State Management:**
   - All states tracked via setState()
   - Clear reset logic saat email berubah

3. **UX Improvements:**
   - Real-time feedback (border color, button state)
   - Clear helper messages
   - Loading indicators
   - Error handling dengan user-friendly messages

4. **Security:**
   - OTP sent via email ke target address
   - OTP verification required before save
   - No plaintext OTP storage
   - State reset on email change

5. **Debugging:**
   - Debug OTP displayed di dialog (untuk testing)
   - Console logs di console (bisa di-remove)
   - Demo message yang jelas

---

**Notes untuk Developer:**
- Untuk production, remove `if (response['debug_otp'] != null)` block
- Pastikan backend implement rate limiting untuk OTP request
- Consider adding resend OTP button jika OTP expired
- Can add countdown timer untuk OTP validity
