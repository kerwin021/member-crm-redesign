-- IS 微智会员 SCRM MySQL bootstrap
-- Run this file as a MySQL administrator before 01_schema.sql when you use an existing MySQL service.
-- Replace CHANGE_ME passwords before running in production.

CREATE DATABASE IF NOT EXISTS member_crm
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'member_crm_app'@'%' IDENTIFIED BY 'CHANGE_ME_APP_PASSWORD';
CREATE USER IF NOT EXISTS 'member_crm_readonly'@'%' IDENTIFIED BY 'CHANGE_ME_READONLY_PASSWORD';

GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, ALTER, INDEX, REFERENCES
  ON member_crm.* TO 'member_crm_app'@'%';

GRANT SELECT
  ON member_crm.* TO 'member_crm_readonly'@'%';

FLUSH PRIVILEGES;
