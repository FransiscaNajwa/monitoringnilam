-- ============================================
-- MMT (MINE MANAGEMENT TECHNOLOGY) TABLE
-- ============================================

-- Drop table if exists (for fresh install)
-- DROP TABLE IF EXISTS mmts;

-- Create MMT table
CREATE TABLE IF NOT EXISTS mmts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mmt_id VARCHAR(50) NOT NULL UNIQUE,
    location VARCHAR(255) NOT NULL,
    ip_address VARCHAR(15) NOT NULL,
    status VARCHAR(20) DEFAULT 'Unknown',
    type VARCHAR(50) DEFAULT 'Standard',
    container_yard VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Indexes for performance
    INDEX idx_mmt_id (mmt_id),
    INDEX idx_container_yard (container_yard),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Sample Data for MMT (Insert into database)
-- ============================================

DELETE FROM mmts;

INSERT INTO mmts (mmt_id, location, ip_address, status, type, container_yard, created_at, updated_at) VALUES
-- CY1 MMT Units
('MMT-CY1-01', 'Container Yard 1', '10.1.71.10', 'UP', 'Mine Monitor', 'CY1', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY1-02', 'Container Yard 1', '10.1.71.11', 'UP', 'Mine Monitor', 'CY1', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY1-03', 'Container Yard 1', '10.1.71.12', 'UP', 'Mine Monitor', 'CY1', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),

-- CY2 MMT Units
('MMT-CY2-01', 'Container Yard 2', '10.2.71.10', 'UP', 'Mine Monitor', 'CY2', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY2-02', 'Container Yard 2', '10.2.71.11', 'UP', 'Mine Monitor', 'CY2', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY2-03', 'Container Yard 2', '10.2.71.12', 'UP', 'Mine Monitor', 'CY2', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),

-- CY3 MMT Units
('MMT-CY3-01', 'Container Yard 3', '10.3.71.10', 'UP', 'Mine Monitor', 'CY3', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY3-02', 'Container Yard 3', '10.3.71.11', 'UP', 'Mine Monitor', 'CY3', '2026-01-22 07:53:27', '2026-01-22 07:53:27'),
('MMT-CY3-03', 'Container Yard 3', '10.3.71.12', 'UP', 'Mine Monitor', 'CY3', '2026-01-22 07:53:27', '2026-01-22 07:53:27');

-- ============================================
-- Verify Data
-- ============================================

SELECT COUNT(*) as total_mmts FROM mmts;
SELECT container_yard, COUNT(*) as count FROM mmts GROUP BY container_yard;
SELECT * FROM mmts ORDER BY mmt_id;
