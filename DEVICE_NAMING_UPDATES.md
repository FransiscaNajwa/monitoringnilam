# Device Naming Updates - Dynamic Device Name Implementation

## Summary
Telah mengimplementasikan fitur dynamic device name yang berubah secara otomatis saat user memilih tipe device di form "Add Device".

## Files Created/Modified

### 1. NEW FILE: `lib/models/mmt_model.dart`
**Purpose**: Database model untuk device tipe MMT (Mine Management Technology)
**Structure**: Matches Tower model structure untuk konsistensi database
**Fields**:
- `id` (int) - Primary key
- `mmtId` (String) - Unique identifier dari database (field: mmt_id)
- `location` (String) - Lokasi device
- `ipAddress` (String) - IP address device (field: ip_address)
- `status` (String) - Status device
- `type` (String) - Tipe MMT
- `containerYard` (String) - Container yard (field: container_yard)
- `createdAt` (String) - Timestamp pembuatan
- `updatedAt` (String) - Timestamp update

**Methods**:
- `fromJson()` - Parse dari JSON response backend
- `toJson()` - Convert ke JSON untuk API

### 2. MODIFIED: `lib/add_device.dart`
**Changes**:
1. **TextEditingController Integration**
   - Replaced `initialValue` dengan `TextEditingController` untuk dynamic updates
   - Added `_deviceNameController` untuk device name field
   - Added `_ipAddressController` untuk IP address field
   - Implemented `initState()` dan `dispose()` untuk lifecycle management

2. **Dynamic Device Name Updates**
   - Saat dropdown "Tipe Device" berubah, controller text otomatis update
   - Contoh nama berubah: Tower-01 → Cam-01 → MMT-01
   - User tetap bisa mengedit nama secara manual (tidak forced)

3. **Code Changes**:
   ```dart
   // Before:
   initialValue: _getDeviceNameExample(_selectedDeviceType),
   
   // After:
   controller: _deviceNameController,
   ```

4. **OnChanged Logic**:
   - Dropdown update trigger setState
   - Controller text auto-update dengan `_getDeviceNameExample(newValue)`
   - Hint text tetap menampilkan contoh berdasarkan device type

5. **Submit Form Update**:
   - Using `_deviceNameController.text` instead of `_deviceName`
   - Using `_ipAddressController.text` instead of `_ipAddress`

## Device Naming Convention

### Current Examples (Placeholder)
- **Tower**: `Tower-01`
- **CCTV**: `Cam-01`
- **MMT**: `MMT-01`

### Database Integration
Naming convention harus disesuaikan dengan database yang ada:
- **Tower**: Check existing tower_id format dari API response (e.g., TWR01, T001, Tower-01)
- **CCTV**: Check existing camera_id format dari API response (e.g., CAM01, C001, Cam-01)
- **MMT**: Define mmt_id format based on business requirements

### Next Steps to Finalize
1. Verifikasi exact naming format dari existing database:
   ```dart
   // Check Tower naming
   print(towerList.first.towerId); // Output: T-001 or TWR01 or Tower-001?
   
   // Check Camera naming
   print(cameraList.first.cameraId); // Output: C-001 or CAM01 or Cam-001?
   ```

2. Update `_getDeviceNameExample()` method dengan format yang benar:
   ```dart
   String _getDeviceNameExample(String deviceType) {
     switch (deviceType) {
       case 'Tower':
         return 'T-001'; // or correct format
       case 'CCTV':
         return 'C-001'; // or correct format
       case 'MMT':
         return 'M-001'; // define format
       default:
         return '';
     }
   }
   ```

## User Flow (Updated)

1. **User opens Add Device Form** 
   - Default device type: "Tower"
   - Name field shows: "Tower-01" (example)

2. **User selects different device type** (e.g., CCTV)
   - Name field example updates automatically: "Cam-01"
   - User can edit the name if needed

3. **User can edit device name**
   - User tetap dapat mengubah default name sesuai kebutuhan
   - Contoh: Change "Cam-01" → "Cam-Entrance-Main"

4. **User submits form**
   - Device disimpan dengan nama yang user input
   - Type, coordinates, IP address disimpan ke SharedPreferences
   - Device marker muncul di map

## Technical Details

### Controller Management
- Controllers initialized in `initState()` with default value
- Controllers disposed in `dispose()` untuk prevent memory leak
- Controllers rebuild Form when device type changes

### State Management
- `setState(() { _selectedDeviceType = newValue; })` triggers rebuild
- Rebuild updates hint text dan controller value
- Form validation tetap bekerja normal

### Backward Compatibility
- Existing device storage tetap kompatibel
- Device display di dashboard tidak berubah
- Map markers tetap menampilkan dengan icon dan warna yang benar

## Testing Checklist
- [ ] Device type dropdown works
- [ ] Device name field updates when type changes
- [ ] User can edit device name manually
- [ ] IP Address validation works
- [ ] Location dropdown works
- [ ] Form submission successful
- [ ] Device saved to SharedPreferences
- [ ] Device appears on map
- [ ] Device marker color matches type
- [ ] Device marker icon matches type
- [ ] Verify database naming conventions match

## Files Status
✅ `lib/models/mmt_model.dart` - Created
✅ `lib/add_device.dart` - Updated with dynamic naming
✅ `lib/models/device_model.dart` - No changes needed (storage format okay)
✅ `lib/services/device_storage_service.dart` - No changes needed
✅ `lib/dashboard.dart` - No changes needed (display logic okay)

## Next Phase
1. Finalize database naming conventions
2. Update `_getDeviceNameExample()` if needed
3. Create backend integration for MMT device insertion
4. Test device creation workflow end-to-end
