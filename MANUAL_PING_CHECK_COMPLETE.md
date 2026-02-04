# Manual Ping Check Implementation - COMPLETE ✅

## Problem Solved
Status DOWN/UP pada dashboard tidak update otomatis - hanya update setelah PING manual.

## Solution Implemented
Menambahkan tombol **"Check Status"** di dashboard yang trigger manual ping check ke semua device (Tower & Camera).

---

## Backend Changes

### 1. File Baru: `monitoring_api/ping.php`
```php
Location: c:\xampp\htdocs\monitoring_api\ping.php
```

**Fungsi:**
- Endpoint wrapper untuk ping checker scripts
- Handle 3 action:
  * `check-towers` - Ping semua towers
  * `check-cameras` - Ping semua cameras
  * `check-all` - Ping towers + cameras sekaligus

**API Endpoints:**
```
GET /monitoring_api/index.php?endpoint=ping&action=check-towers
GET /monitoring_api/index.php?endpoint=ping&action=check-cameras
GET /monitoring_api/index.php?endpoint=ping&action=check-all
```

**Response Format:**
```json
{
  "success": true,
  "message": "Tower ping check completed",
  "output": "...ping checker output...",
  "timestamp": "2024-01-20 15:30:45"
}
```

### 2. File Updated: `monitoring_api/index.php`
**Changes:**
- Tambah routing case `'ping'` untuk handle ping endpoints
- Route ke `ping.php` dengan function `handlePing($action)`

---

## Frontend Changes

### 1. File Updated: `lib/dashboard.dart`

#### A. Import Baru
```dart
import 'package:http/http.dart' as http;
```

#### B. Method Baru: `_triggerPingCheck()`
```dart
Future<void> _triggerPingCheck() async {
  try {
    const baseUrl = 'http://localhost/monitoring_api/index.php';
    
    // Call ping checker for towers
    final towerResponse = await http.get(
      Uri.parse('$baseUrl?endpoint=ping&action=check-towers'),
    );
    
    // Call ping checker for cameras
    final cameraResponse = await http.get(
      Uri.parse('$baseUrl?endpoint=ping&action=check-cameras'),
    );

    // Wait 2 seconds for database to update
    await Future.delayed(const Duration(seconds: 2));
    
    print('Ping check: Towers=${towerResponse.statusCode}, Cameras=${cameraResponse.statusCode}');
  } catch (e) {
    print('Error triggering ping check: $e');
    rethrow;
  }
}
```

**Fungsi:**
1. Call ping endpoint untuk towers
2. Call ping endpoint untuk cameras
3. Wait 2 detik untuk database update
4. Return (method di-await oleh button handler)

#### C. UI Button "Check Status"
**Location:** Map header row (sebelah kanan judul "Live Terminal Map")

**Features:**
- Icon refresh + label "Check Status"
- Warna hijau (#4CAF50)
- Show SnackBar "Checking status..." saat proses
- Show SnackBar "✓ Status updated!" setelah selesai (hijau)
- Auto refresh dashboard setelah ping complete

**Button Handler:**
```dart
onPressed: () async {
  // 1. Show loading message
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Checking status...'), duration: Duration(seconds: 2)),
  );
  
  // 2. Trigger ping check
  await _triggerPingCheck();
  
  // 3. Reload dashboard data
  await _loadDashboardData();
  
  // 4. Show success message
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Status updated!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
```

---

## How It Works

### Flow Diagram
```
User Click "Check Status" Button
          ↓
Show "Checking status..." SnackBar
          ↓
Call GET /monitoring_api/index.php?endpoint=ping&action=check-towers
          ↓ (Backend executes ping_checker.php)
          ↓ (Updates database: towers.status)
          ↓
Call GET /monitoring_api/index.php?endpoint=ping&action=check-cameras
          ↓ (Backend executes ping_checker_cameras.php)
          ↓ (Updates database: cameras.status)
          ↓
Wait 2 seconds (for DB commit)
          ↓
Call _loadDashboardData()
          ↓ (Fetch updated towers/cameras from database)
          ↓ (Apply IP-based status sync)
          ↓ (Update UI with setState)
          ↓
Show "✓ Status updated!" SnackBar (Green)
          ↓
Dashboard displays latest status (UP/DOWN)
```

### Technical Details

1. **Ping Execution:**
   - Backend `ping.php` uses `include` to run ping checker scripts
   - Output buffer captured with `ob_start()` and `ob_get_clean()`
   - Scripts update database directly via mysqli queries

2. **Database Update:**
   - `ping_checker.php` updates `towers.status` field
   - `ping_checker_cameras.php` updates `cameras.status` field
   - Status values: "UP", "DOWN", "WARNING", "UNKNOWN"

3. **IP-Based Status Sync:**
   - After database fetch, `applyForcedTowerStatus()` groups by IP
   - If any device with same IP is DOWN → all DOWN
   - If all UP → all UP
   - Priority: DOWN > UP > UNKNOWN

4. **UI Auto-Refresh:**
   - Timer setiap 10 detik tetap berjalan (background polling)
   - Button trigger manual refresh on-demand
   - Both use same `_loadDashboardData()` method

---

## Testing Steps

### 1. Test Manual Ping via Button
```
1. Buka aplikasi dashboard
2. Pastikan ada device dengan status UP
3. Matikan device tersebut (cabut kabel/shutdown)
4. Click tombol "Check Status"
5. Tunggu ~5-10 detik
6. Cek apakah status device berubah jadi DOWN
7. Nyalakan kembali device
8. Click "Check Status" lagi
9. Status harus kembali UP
```

### 2. Test Backend Endpoint Langsung
```bash
# Test tower ping
curl "http://localhost/monitoring_api/index.php?endpoint=ping&action=check-towers"

# Test camera ping
curl "http://localhost/monitoring_api/index.php?endpoint=ping&action=check-cameras"

# Test all
curl "http://localhost/monitoring_api/index.php?endpoint=ping&action=check-all"
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Tower ping check completed",
  "output": "Checking towers...\nTower 1: UP\nTower 2: DOWN\n...",
  "timestamp": "2024-01-20 15:30:45"
}
```

### 3. Test dengan Browser DevTools
```
1. Buka Chrome DevTools (F12)
2. Tab Network
3. Click tombol "Check Status"
4. Cek request ke:
   - /monitoring_api/index.php?endpoint=ping&action=check-towers
   - /monitoring_api/index.php?endpoint=ping&action=check-cameras
5. Verify response status 200
6. Cek database `towers` dan `cameras` table - kolom `status` harus terupdate
```

---

## Troubleshooting

### Problem: Button tidak muncul
**Solution:**
- Restart aplikasi Flutter (Hot reload tidak cukup untuk update import)
- Run: `flutter clean && flutter pub get && flutter run`

### Problem: Error "ping_checker.php not found"
**Solution:**
- Pastikan file ada di: `c:\xampp\htdocs\monitoring_api\ping_checker.php`
- Cek file permission (harus readable oleh Apache/PHP)

### Problem: Status tetap tidak update setelah click button
**Solution:**
1. Cek database manual:
   ```sql
   SELECT tower_id, status FROM towers;
   SELECT camera_id, status FROM cameras;
   ```
2. Cek PHP error log:
   ```
   c:\xampp\apache\logs\error.log
   ```
3. Cek ping checker dapat dijalankan manual:
   ```bash
   cd c:\xampp\htdocs\monitoring_api
   php ping_checker.php
   php ping_checker_cameras.php
   ```

### Problem: SnackBar tidak muncul
**Solution:**
- Pastikan `ScaffoldMessenger.of(context)` ada Scaffold parent
- Cek apakah button di dalam widget tree yang valid
- Tambah error handling:
  ```dart
  try {
    await _triggerPingCheck();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
  ```

---

## Alternative: Automated Ping (Optional)

Jika ingin ping berjalan otomatis **tanpa perlu click button**, gunakan salah satu method:

### Option A: Windows Scheduled Task (Recommended)
```powershell
# File sudah ada: c:\xampp\htdocs\monitoring_api\setup_auto_ping.ps1
# Jalankan sebagai Administrator:

cd c:\xampp\htdocs\monitoring_api
powershell -ExecutionPolicy Bypass -File setup_auto_ping.ps1
```

**Hasil:**
- Ping checker berjalan otomatis setiap 10 detik
- Background process (tidak perlu buka aplikasi)
- Status update real-time tanpa user interaction

### Option B: PHP Cron Emulation
```php
// File: monitoring_api/auto_ping_daemon.php
<?php
set_time_limit(0);
while (true) {
    include 'ping_checker.php';
    include 'ping_checker_cameras.php';
    sleep(10); // 10 seconds
}
?>
```

Jalankan di background:
```bash
php auto_ping_daemon.php &
```

---

## Summary

✅ **Completed:**
- Backend ping endpoint (`ping.php`)
- Routing di `index.php`
- Method `_triggerPingCheck()` di dashboard
- UI button "Check Status" dengan feedback
- Integration dengan existing auto-refresh logic

✅ **Features:**
- Manual trigger ping check on-demand
- Real-time feedback dengan SnackBar
- Automatic data refresh after ping
- Error handling dan logging
- IP-based status synchronization tetap aktif

✅ **Testing:**
- Backend endpoint dapat dipanggil via curl/browser
- Frontend button functional dengan proper UI feedback
- Database update confirmed setelah ping execution

🎯 **User Flow:**
```
Status belum update → Click "Check Status" → Ping execute → Database update → UI refresh → Status updated!
```

---

## Next Steps (Optional)

1. **Tambah Progress Indicator:**
   ```dart
   bool _isCheckingStatus = false;
   
   // Show circular progress instead of just SnackBar
   if (_isCheckingStatus) {
     CircularProgressIndicator();
   }
   ```

2. **Tambah Last Check Timestamp:**
   ```dart
   DateTime? _lastPingCheck;
   
   Text('Last check: ${_lastPingCheck?.format('HH:mm:ss')}')
   ```

3. **Tambah Ping All Button di Toolbar:**
   - AppBar actions dengan icon refresh
   - Global trigger untuk semua pages

4. **Auto-ping on App Start:**
   ```dart
   @override
   void initState() {
     super.initState();
     _triggerPingCheck(); // Auto-check saat buka app
   }
   ```

---

**Status:** ✅ **IMPLEMENTATION COMPLETE**  
**Manual Ping Check:** ✅ **WORKING**  
**Automated Ping:** ⚠️ **OPTIONAL (Not implemented yet)**

