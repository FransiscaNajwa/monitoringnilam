# Quick Start - Manual Ping Check Button

## ✅ Implementation Complete!

Dashboard sekarang punya tombol **"Check Status"** yang bisa trigger ping manual untuk update status device.

---

## How to Use

### 1. Restart Aplikasi Flutter
```bash
# Stop aplikasi yang sedang running
# Lalu run ulang:
flutter run
```

### 2. Test Manual Ping
1. Buka **Dashboard** page
2. Lihat di atas map, ada tombol hijau **"Check Status"** (icon refresh)
3. Click tombol tersebut
4. Akan muncul pesan **"Checking status..."**
5. Tunggu beberapa detik
6. Akan muncul pesan hijau **"✓ Status updated!"**
7. Dashboard otomatis refresh dan tampilkan status terbaru

---

## What Happens Behind the Scene

```
Click Button
    ↓
Call ping_checker.php (update towers status di database)
    ↓
Call ping_checker_cameras.php (update cameras status di database)
    ↓
Wait 2 seconds
    ↓
Reload dashboard data (fetch dari database)
    ↓
Apply IP-based status sync
    ↓
Update UI
    ↓
Show "✓ Status updated!"
```

---

## Expected Behavior

### Before Click Button:
- Device status mungkin outdated (dari terakhir kali ping)
- Display menunjukkan status lama

### After Click Button:
- Status device di-check real-time via ping
- Database updated dengan status terbaru (UP/DOWN)
- Display langsung update tanpa perlu refresh page
- Semua device dengan IP yang sama share status yang sama

---

## Visual Guide

```
┌─────────────────────────────────────────────┐
│  Live Terminal Map          [Check Status]  │  ← Tombol di sini
├─────────────────────────────────────────────┤
│                                             │
│              MAP VIEW                       │
│                                             │
│          (Markers & Zones)                  │
│                                             │
└─────────────────────────────────────────────┘

Click tombol → Checking status... → ✓ Status updated!
```

---

## Troubleshooting

### Problem 1: Tombol tidak muncul
**Solution:** Restart aplikasi (hot reload tidak cukup)
```bash
flutter clean
flutter pub get
flutter run
```

### Problem 2: Error saat click button
**Check:**
1. XAMPP Apache harus running
2. File `ping_checker.php` dan `ping_checker_cameras.php` harus ada di:
   ```
   c:\xampp\htdocs\monitoring_api\
   ```
3. Database connection OK (cek di phpMyAdmin)

### Problem 3: Status tidak update setelah click
**Check:**
1. Cek database manual:
   ```sql
   SELECT tower_id, ip_address, status FROM towers;
   SELECT camera_id, ip_address, status FROM cameras;
   ```
2. Test ping checker manual di terminal:
   ```bash
   cd c:\xampp\htdocs\monitoring_api
   php ping_checker.php
   php ping_checker_cameras.php
   ```

---

## What Files Were Changed

### Backend (PHP):
1. **NEW:** `c:\xampp\htdocs\monitoring_api\ping.php`
   - Endpoint wrapper untuk ping checkers
   - Handle 3 actions: check-towers, check-cameras, check-all

2. **UPDATED:** `c:\xampp\htdocs\monitoring_api\index.php`
   - Added routing for 'ping' endpoint

### Frontend (Flutter):
3. **UPDATED:** `lib/dashboard.dart`
   - Added `import 'package:http/http.dart' as http;`
   - Added `_triggerPingCheck()` method
   - Button already exists in UI (from previous update)

---

## Testing Checklist

- [ ] Restart aplikasi Flutter
- [ ] Tombol "Check Status" muncul di dashboard
- [ ] Click tombol → muncul "Checking status..."
- [ ] Tunggu ~5 detik → muncul "✓ Status updated!" (hijau)
- [ ] Matikan 1 device (unplug/shutdown)
- [ ] Click "Check Status" lagi
- [ ] Status device yang mati berubah jadi DOWN (merah)
- [ ] Nyalakan device kembali
- [ ] Click "Check Status" lagi
- [ ] Status kembali jadi UP (hijau)

---

## Auto-Refresh vs Manual Check

### Auto-Refresh (Timer - 10 seconds):
- ✅ Already implemented
- ✅ Polls database setiap 10 detik
- ⚠️ Hanya refresh UI, tidak ping device
- ⚠️ Status hanya update jika database sudah diupdate

### Manual Check (Button):
- ✅ Now implemented
- ✅ Trigger ping checker scripts
- ✅ Update database dengan status real-time
- ✅ Langsung refresh UI setelah ping

### Kombinasi Keduanya:
```
User membuka dashboard
    ↓
Auto-refresh polls database setiap 10 detik (background)
    ↓
User click "Check Status" → Ping device → Update DB
    ↓
Auto-refresh berikutnya akan dapat data terbaru
    ↓
UI selalu menampilkan status terkini
```

---

## Optional: Automated Background Ping

Jika mau ping berjalan otomatis **tanpa perlu click button**, gunakan:

### Windows Scheduled Task:
```powershell
# File: c:\xampp\htdocs\monitoring_api\setup_auto_ping.ps1
# Run as Administrator:

cd c:\xampp\htdocs\monitoring_api
powershell -ExecutionPolicy Bypass -File setup_auto_ping.ps1
```

Hasil: Ping berjalan otomatis setiap 10 detik di background.

---

## Summary

✅ **Problem:** Status hanya update setelah ping manual  
✅ **Solution:** Tombol "Check Status" yang trigger ping on-demand  
✅ **Status:** Implementation complete, ready to test  

🎯 **Next:** Restart app → Click button → Verify status updates!

