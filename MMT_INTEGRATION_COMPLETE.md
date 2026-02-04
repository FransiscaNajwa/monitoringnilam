# MMT (Mine Management Technology) Integration Complete

## Status: ✅ READY FOR DEPLOYMENT

### Files Created/Modified

#### 1. **Database Layer**
- ✅ `insert_mmts.sql` - SQL schema + sample data for MMT table
  - Table: `mmts`
  - Fields: id, mmt_id, location, ip_address, status, type, container_yard, created_at, updated_at
  - Sample Data: 9 units (3 per container yard)

#### 2. **Backend (PHP API)**
- ✅ `mmt.php` - REST API endpoints for MMT
  - **Endpoints:**
    - `?endpoint=mmt&action=all` → Get all MMTs
    - `?endpoint=mmt&action=by-yard&container_yard=CY1` → Get MMTs by container yard
    - `?endpoint=mmt&action=by-id&mmt_id=1` → Get MMT by ID
    - `?endpoint=mmt&action=stats` → Get MMT statistics
    - `?endpoint=mmt&action=update-status` (POST) → Update MMT status

#### 3. **Frontend - Dart Model**
- ✅ `lib/models/mmt_model.dart` - MMT data model
  - fromJson() factory for API parsing
  - toJson() method for serialization
  - Matches Tower model structure

#### 4. **Frontend - API Service**
- ✅ `lib/services/api_service.dart` - Added 5 MMT methods:
  - `getAllMMTs()` - Fetch all MMTs
  - `getMMTsByContainerYard(String)` - Filter by container yard
  - `getMMTById(int)` - Get single MMT
  - `getMMTStats()` - Get statistics
  - `updateMMTStatus(String, String)` - Update status (POST)

#### 5. **Frontend - Form**
- ✅ `lib/add_device.dart` - MMT device type integration
  - Device type dropdown includes "MMT" option
  - Dynamic naming: `MMT-01`
  - IP Address field support
  - Location selection from tower points

---

## Deployment Steps

### Step 1: Create Database Table
```bash
# Method 1: Direct MySQL
mysql -u root -p monitoring < insert_mmts.sql

# Method 2: phpMyAdmin
1. Go to phpMyAdmin
2. Select database 'monitoring'
3. Click SQL tab
4. Copy-paste content of insert_mmts.sql
5. Click Go
```

### Step 2: Deploy PHP Endpoint
```bash
# Copy mmt.php to backend directory
cp mmt.php /path/to/monitoring_api/

# Or manually copy to monitoring_api/ folder
# File should be at: monitoring_api/mmt.php
```

### Step 3: Verify Endpoints
```bash
# Test in browser or terminal
curl "http://localhost/monitoring_api/index.php?endpoint=mmt&action=all"

# Expected response:
{
  "success": true,
  "data": [
    {
      "id": "1",
      "mmt_id": "MMT-CY1-01",
      "location": "Container Yard 1",
      "ip_address": "10.1.71.10",
      "status": "UP",
      "type": "Mine Monitor",
      "container_yard": "CY1",
      "created_at": "2026-01-22 07:53:27",
      "updated_at": "2026-01-22 07:53:27"
    },
    ...
  ],
  "count": 9
}
```

### Step 4: Test Flutter Integration
- Rebuild Flutter app: `flutter pub get && flutter run`
- Test Add Device page: Select "MMT" type
- Verify device name example updates to "MMT-01"

---

## API Usage Examples

### Get All MMTs
```
GET http://localhost/monitoring_api/index.php?endpoint=mmt&action=all
```

### Get MMTs by Container Yard
```
GET http://localhost/monitoring_api/index.php?endpoint=mmt&action=by-yard&container_yard=CY2
```

### Get Single MMT
```
GET http://localhost/monitoring_api/index.php?endpoint=mmt&action=by-id&mmt_id=1
```

### Get MMT Statistics
```
GET http://localhost/monitoring_api/index.php?endpoint=mmt&action=stats
Response:
{
  "success": true,
  "data": {
    "total": 9,
    "up": 9,
    "down": 0,
    "by_container_yard": {
      "CY1": 3,
      "CY2": 3,
      "CY3": 3
    }
  }
}
```

### Update MMT Status (POST)
```
POST http://localhost/monitoring_api/index.php?endpoint=mmt&action=update-status
Content-Type: application/json

Body:
{
  "mmt_id": "MMT-CY1-01",
  "status": "DOWN"
}

Response:
{
  "success": true,
  "message": "MMT status updated successfully",
  "mmt_id": "MMT-CY1-01",
  "new_status": "DOWN"
}
```

---

## MMT Data Model

```dart
class MMT {
  final int id;                    // Auto-increment
  final String mmtId;              // Unique: MMT-CY1-01
  final String location;           // Container Yard 1
  final String ipAddress;          // 10.1.71.10
  final String status;             // UP/DOWN/Unknown
  final String type;               // Mine Monitor
  final String containerYard;      // CY1, CY2, CY3
  final String createdAt;          // Timestamp
  final String updatedAt;          // Timestamp
}
```

---

## Current MMT Data

### Container Yard 1 (CY1)
| MMT ID | IP Address | Status | Type |
|--------|-----------|--------|------|
| MMT-CY1-01 | 10.1.71.10 | UP | Mine Monitor |
| MMT-CY1-02 | 10.1.71.11 | UP | Mine Monitor |
| MMT-CY1-03 | 10.1.71.12 | UP | Mine Monitor |

### Container Yard 2 (CY2)
| MMT ID | IP Address | Status | Type |
|--------|-----------|--------|------|
| MMT-CY2-01 | 10.2.71.10 | UP | Mine Monitor |
| MMT-CY2-02 | 10.2.71.11 | UP | Mine Monitor |
| MMT-CY2-03 | 10.2.71.12 | UP | Mine Monitor |

### Container Yard 3 (CY3)
| MMT ID | IP Address | Status | Type |
|--------|-----------|--------|------|
| MMT-CY3-01 | 10.3.71.10 | UP | Mine Monitor |
| MMT-CY3-02 | 10.3.71.11 | UP | Mine Monitor |
| MMT-CY3-03 | 10.3.71.12 | UP | Mine Monitor |

---

## Integration Checklist

- [x] MMT database table created
- [x] Sample data inserted (9 units)
- [x] PHP API endpoints implemented
- [x] Dart model created
- [x] API service methods added
- [x] Form support for MMT device type
- [x] Dynamic naming for MMT (MMT-01)
- [ ] MMT page/view in Flutter (optional)
- [ ] MMT markers on map (optional)
- [ ] MMT ping checker script (optional)
- [ ] Realtime status monitoring (optional)

---

## Optional: Next Steps

### 1. Create MMT Monitoring Page
Similar to `network.dart`, `cctv.dart` - dedicated page for viewing all MMTs

### 2. Add MMT Markers to Map
Update `dashboard.dart` to display MMT markers with orange color

### 3. Implement Ping Checker for MMT
Create `ping_checker_mmts.php` to monitor MMT availability

### 4. Add MMT to Alerts System
Generate alerts when MMT status changes to DOWN

### 5. Database Backup
```sql
-- Backup MMT table
mysqldump -u root -p monitoring mmts > mmts_backup.sql
```

---

## Troubleshooting

### Issue: "Endpoint mmt not found"
- Solution: Ensure `mmt.php` is in `monitoring_api/` directory
- Check: File should be accessible at `http://localhost/monitoring_api/mmt.php`

### Issue: Database connection error
- Check MySQL is running
- Verify database name is 'monitoring'
- Check credentials in mmt.php

### Issue: Empty MMT data
- Run `insert_mmts.sql` to populate test data
- Verify table structure with: `DESCRIBE mmts;`

### Issue: CORS or connection refused
- Ensure Apache/PHP server is running
- Check API base URL in `api_service.dart`

---

## Naming Conventions

**MMT ID Format:** `MMT-CY{1|2|3}-{01-99}`

Example:
- `MMT-CY1-01` - First MMT in Container Yard 1
- `MMT-CY2-05` - Fifth MMT in Container Yard 2
- `MMT-CY3-10` - Tenth MMT in Container Yard 3

---

## Files Summary

| File | Type | Location | Status |
|------|------|----------|--------|
| insert_mmts.sql | SQL | Root | ✅ Created |
| mmt.php | PHP API | Root (copy to monitoring_api/) | ✅ Created |
| mmt_model.dart | Dart Model | lib/models/ | ✅ Created |
| api_service.dart | Dart Service | lib/services/ | ✅ Updated |
| add_device.dart | Dart Form | lib/ | ✅ Updated |

---

## Support

For issues or questions about MMT integration:
1. Check database: `SELECT * FROM mmts;`
2. Test API: `curl http://localhost/monitoring_api/index.php?endpoint=mmt&action=all`
3. Check Flutter logs: `flutter logs`
4. Verify network connectivity

---

*Last Updated: 2026-02-03*
*Status: Ready for Production*
