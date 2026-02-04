-- ============================================
-- OTP TOKENS TABLE SCHEMA
-- For Email Verification Feature
-- ============================================

-- Drop table if exists (be careful in production!)
-- DROP TABLE IF EXISTS otp_tokens;

-- Create OTP tokens table
CREATE TABLE IF NOT EXISTS otp_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    email VARCHAR(255) NOT NULL,
    otp VARCHAR(6) NOT NULL,
    expires_at DATETIME NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used BOOLEAN DEFAULT FALSE,
    
    -- Indexes for performance
    INDEX idx_user_email (user_id, email),
    INDEX idx_expires (expires_at),
    INDEX idx_used (used),
    
    -- Foreign key (optional - uncomment if you have users table)
    -- FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    
    UNIQUE KEY unique_user_email_active (user_id, email, used)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Sample Data for Testing (Optional)
-- ============================================

-- Insert a test OTP (expires in 10 minutes from now)
-- INSERT INTO otp_tokens (user_id, email, otp, expires_at, used)
-- VALUES (
--     1, 
--     'test@example.com', 
--     '123456', 
--     DATE_ADD(NOW(), INTERVAL 10 MINUTE),
--     FALSE
-- );

-- ============================================
-- Useful Queries for Maintenance
-- ============================================

-- View all active (unused, not expired) OTPs
-- SELECT * FROM otp_tokens 
-- WHERE used = FALSE 
--   AND expires_at > NOW()
-- ORDER BY created_at DESC;

-- Clean up expired OTPs (run periodically)
-- DELETE FROM otp_tokens 
-- WHERE expires_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);

-- Clean up used OTPs older than 24 hours
-- DELETE FROM otp_tokens 
-- WHERE used = TRUE 
--   AND created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);

-- Count OTPs by status
-- SELECT 
--     used,
--     COUNT(*) as count,
--     COUNT(CASE WHEN expires_at > NOW() THEN 1 END) as active_count,
--     COUNT(CASE WHEN expires_at <= NOW() THEN 1 END) as expired_count
-- FROM otp_tokens
-- GROUP BY used;

-- ============================================
-- NOTES
-- ============================================

/**
 * Table Structure Explanation:
 * 
 * - id: Auto-increment primary key
 * - user_id: ID of the user requesting email change
 * - email: The new email address to verify
 * - otp: 6-digit verification code
 * - expires_at: When the OTP expires (typically 10 minutes)
 * - created_at: When the OTP was generated
 * - used: Whether the OTP has been used (prevents reuse)
 * 
 * Security Features:
 * - OTP expires after set time (10 minutes recommended)
 * - Used OTPs cannot be reused
 * - One active OTP per user/email combination
 * - Indexed for fast lookups
 * 
 * Maintenance:
 * - Regularly clean expired OTPs to keep table small
 * - Monitor OTP usage patterns
 * - Set up automatic cleanup with cron job
 */

-- ============================================
-- CRON JOB for Cleanup (Optional)
-- ============================================

/**
 * Add this to your cron jobs to auto-clean expired OTPs:
 * 
 * Run every hour:
 * 0 * * * * mysql -u username -p'password' database_name -e "DELETE FROM otp_tokens WHERE expires_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);"
 * 
 * Or create a stored procedure:
 */

-- DELIMITER //
-- CREATE PROCEDURE cleanup_expired_otps()
-- BEGIN
--     DELETE FROM otp_tokens 
--     WHERE expires_at < DATE_SUB(NOW(), INTERVAL 1 HOUR);
--     
--     DELETE FROM otp_tokens 
--     WHERE used = TRUE 
--       AND created_at < DATE_SUB(NOW(), INTERVAL 24 HOUR);
-- END //
-- DELIMITER ;

-- Then call it periodically:
-- CALL cleanup_expired_otps();

-- ============================================
-- VERIFICATION
-- ============================================

-- After running this script, verify the table was created:
-- DESCRIBE otp_tokens;

-- Check indexes:
-- SHOW INDEX FROM otp_tokens;
