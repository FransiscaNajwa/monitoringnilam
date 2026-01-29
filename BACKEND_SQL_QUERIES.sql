-- ==================== TOWER/NETWORK QUERIES ====================
-- Queries untuk update backend PHP agar return updated_at field

-- 1. Get All Towers (endpoint=network&action=all)
-- Update query di network.php action 'all'
SELECT 
    id,
    tower_id,
    tower_number,
    location,
    ip_address,
    device_count,
    status,
    traffic,
    uptime,
    container_yard,
    created_at,
    updated_at
FROM towers
ORDER BY tower_number ASC;

-- 2. Get Towers by Container Yard (endpoint=network&action=by-yard&container_yard=CY1)
-- Update query di network.php action 'by-yard'
SELECT 
    id,
    tower_id,
    tower_number,
    location,
    ip_address,
    device_count,
    status,
    traffic,
    uptime,
    container_yard,
    created_at,
    updated_at
FROM towers
WHERE container_yard = :container_yard
ORDER BY tower_number ASC;

-- 3. Get Tower by ID (endpoint=network&action=by-id&tower_id=1)
-- Update query di network.php action 'by-id'
SELECT 
    id,
    tower_id,
    tower_number,
    location,
    ip_address,
    device_count,
    status,
    traffic,
    uptime,
    container_yard,
    created_at,
    updated_at
FROM towers
WHERE id = :id
LIMIT 1;

-- ==================== NOTES ====================
-- Pastikan di backend PHP network.php:
-- 1. Tambahkan updated_at di SELECT clause untuk semua queries
-- 2. Gunakan parameter binding (:container_yard, :id) untuk security
-- 3. Return JSON response dengan updated_at field
-- 
-- Contoh response yang benar:
-- {
--   "success": true,
--   "data": [
--     {
--       "id": "5",
--       "tower_id": "T-CY1-07",
--       "tower_number": "7",
--       "location": "Container Yard 1",
--       "ip_address": "10.2.71.60",
--       "device_count": "1",
--       "status": "down",
--       "traffic": "0 Mbps",
--       "uptime": "0%",
--       "container_yard": "CY1",
--       "created_at": "2026-01-22 07:53:27",
--       "updated_at": "2026-01-28 13:35:09"    <-- PENTING: Harus ada field ini
--     }
--   ]
-- }
