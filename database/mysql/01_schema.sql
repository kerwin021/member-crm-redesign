-- IS 微智会员 SCRM MySQL schema
-- Target: MySQL 5.7.44+ / 8.0+, InnoDB, utf8mb4.
-- Run while connected to the target database, for example the Baota database `crm`.

SET NAMES utf8mb4;
SET time_zone = '+08:00';

CREATE TABLE IF NOT EXISTS app_tenants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(120) NOT NULL,
  brand_name VARCHAR(120) NOT NULL DEFAULT '微智',
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  settings_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_app_tenants_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS org_organizations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  parent_id BIGINT UNSIGNED NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(160) NOT NULL,
  org_type VARCHAR(32) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  sort_order INT NOT NULL DEFAULT 0,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_org_organizations_tenant_code (tenant_id, code),
  KEY idx_org_organizations_tenant_parent (tenant_id, parent_id),
  CONSTRAINT fk_org_organizations_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_org_organizations_parent FOREIGN KEY (parent_id) REFERENCES org_organizations (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS org_stores (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  organization_id BIGINT UNSIGNED NULL,
  store_code VARCHAR(64) NOT NULL,
  name VARCHAR(160) NOT NULL,
  city VARCHAR(80) NULL,
  address VARCHAR(255) NULL,
  phone VARCHAR(32) NULL,
  service_status VARCHAR(24) NOT NULL DEFAULT 'open',
  opened_on DATE NULL,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_org_stores_tenant_code (tenant_id, store_code),
  KEY idx_org_stores_tenant_city (tenant_id, city),
  KEY idx_org_stores_org (organization_id),
  CONSTRAINT fk_org_stores_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_org_stores_org FOREIGN KEY (organization_id) REFERENCES org_organizations (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS iam_users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  username VARCHAR(80) NOT NULL,
  display_name VARCHAR(120) NOT NULL,
  email VARCHAR(160) NULL,
  phone VARCHAR(32) NULL,
  password_hash VARCHAR(255) NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  last_login_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_iam_users_tenant_username (tenant_id, username),
  UNIQUE KEY uk_iam_users_tenant_email (tenant_id, email),
  KEY idx_iam_users_tenant_status (tenant_id, status),
  CONSTRAINT fk_iam_users_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS org_employees (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  organization_id BIGINT UNSIGNED NULL,
  store_id BIGINT UNSIGNED NULL,
  employee_no VARCHAR(64) NOT NULL,
  name VARCHAR(120) NOT NULL,
  title VARCHAR(120) NULL,
  employment_status VARCHAR(24) NOT NULL DEFAULT 'active',
  joined_on DATE NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_org_employees_user (user_id),
  UNIQUE KEY uk_org_employees_tenant_no (tenant_id, employee_no),
  KEY idx_org_employees_org (organization_id),
  KEY idx_org_employees_store (store_id),
  CONSTRAINT fk_org_employees_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_org_employees_user FOREIGN KEY (user_id) REFERENCES iam_users (id) ON DELETE SET NULL,
  CONSTRAINT fk_org_employees_org FOREIGN KEY (organization_id) REFERENCES org_organizations (id) ON DELETE SET NULL,
  CONSTRAINT fk_org_employees_store FOREIGN KEY (store_id) REFERENCES org_stores (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS iam_roles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  data_scope VARCHAR(32) NOT NULL DEFAULT 'tenant',
  description TEXT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_iam_roles_tenant_code (tenant_id, code),
  CONSTRAINT fk_iam_roles_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS iam_permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(120) NOT NULL,
  name VARCHAR(120) NOT NULL,
  resource VARCHAR(120) NOT NULL,
  action VARCHAR(80) NOT NULL,
  description TEXT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_iam_permissions_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS iam_role_permissions (
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_iam_role_permissions_role FOREIGN KEY (role_id) REFERENCES iam_roles (id) ON DELETE CASCADE,
  CONSTRAINT fk_iam_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES iam_permissions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS iam_user_roles (
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_iam_user_roles_user FOREIGN KEY (user_id) REFERENCES iam_users (id) ON DELETE CASCADE,
  CONSTRAINT fk_iam_user_roles_role FOREIGN KEY (role_id) REFERENCES iam_roles (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_membership_levels (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(64) NOT NULL,
  name VARCHAR(120) NOT NULL,
  level_rank INT NOT NULL,
  min_growth_value INT NOT NULL DEFAULT 0,
  keep_months INT NOT NULL DEFAULT 12,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  benefits_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_loyalty_levels_tenant_code (tenant_id, code),
  UNIQUE KEY uk_loyalty_levels_tenant_rank (tenant_id, level_rank),
  CONSTRAINT fk_loyalty_levels_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_members (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  member_no VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  phone_hash CHAR(64) NOT NULL,
  phone_mask VARCHAR(32) NOT NULL,
  gender VARCHAR(16) NULL,
  birthday DATE NULL,
  level_id BIGINT UNSIGNED NULL,
  source_channel VARCHAR(80) NOT NULL,
  register_store_id BIGINT UNSIGNED NULL,
  register_at DATETIME(3) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  profile_json JSON NULL,
  last_active_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_crm_members_tenant_no (tenant_id, member_no),
  UNIQUE KEY uk_crm_members_tenant_phone (tenant_id, phone_hash),
  KEY idx_crm_members_tenant_status (tenant_id, status),
  KEY idx_crm_members_tenant_level (tenant_id, level_id),
  KEY idx_crm_members_source (tenant_id, source_channel),
  CONSTRAINT fk_crm_members_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_members_level FOREIGN KEY (level_id) REFERENCES loyalty_membership_levels (id) ON DELETE SET NULL,
  CONSTRAINT fk_crm_members_store FOREIGN KEY (register_store_id) REFERENCES org_stores (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_member_metrics (
  member_id BIGINT UNSIGNED NOT NULL,
  tenant_id BIGINT UNSIGNED NOT NULL,
  total_spend DECIMAL(14,2) NOT NULL DEFAULT 0,
  order_count INT NOT NULL DEFAULT 0,
  avg_order_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  growth_value INT NOT NULL DEFAULT 0,
  contribution_score INT NOT NULL DEFAULT 0,
  last_order_at DATETIME(3) NULL,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (member_id),
  KEY idx_crm_member_metrics_score (tenant_id, contribution_score),
  CONSTRAINT fk_crm_member_metrics_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_member_metrics_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_member_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  detail TEXT NOT NULL,
  operator_user_id BIGINT UNSIGNED NULL,
  channel VARCHAR(80) NULL,
  event_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  metadata_json JSON NULL,
  PRIMARY KEY (id),
  KEY idx_crm_member_logs_member_time (member_id, event_at),
  CONSTRAINT fk_crm_member_logs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_member_logs_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE SET NULL,
  CONSTRAINT fk_crm_member_logs_operator FOREIGN KEY (operator_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_tags (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  category VARCHAR(80) NOT NULL,
  color VARCHAR(32) NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  rules_json JSON NULL,
  coverage_count INT NOT NULL DEFAULT 0,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_crm_tags_tenant_name (tenant_id, name),
  CONSTRAINT fk_crm_tags_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_member_tags (
  tenant_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NOT NULL,
  tag_id BIGINT UNSIGNED NOT NULL,
  source VARCHAR(64) NOT NULL DEFAULT 'manual',
  assigned_by BIGINT UNSIGNED NULL,
  assigned_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (member_id, tag_id),
  KEY idx_crm_member_tags_tag (tag_id, assigned_at),
  CONSTRAINT fk_crm_member_tags_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_member_tags_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_member_tags_tag FOREIGN KEY (tag_id) REFERENCES crm_tags (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_member_tags_user FOREIGN KEY (assigned_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_segments (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  description TEXT NULL,
  segment_type VARCHAR(24) NOT NULL,
  rule_json JSON NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  member_count INT NOT NULL DEFAULT 0,
  refreshed_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_crm_segments_tenant_name (tenant_id, name),
  CONSTRAINT fk_crm_segments_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS crm_segment_members (
  segment_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NOT NULL,
  joined_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (segment_id, member_id),
  CONSTRAINT fk_crm_segment_members_segment FOREIGN KEY (segment_id) REFERENCES crm_segments (id) ON DELETE CASCADE,
  CONSTRAINT fk_crm_segment_members_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS catalog_products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  product_no VARCHAR(80) NOT NULL,
  name VARCHAR(180) NOT NULL,
  category VARCHAR(80) NOT NULL,
  price DECIMAL(12,2) NOT NULL,
  list_price DECIMAL(12,2) NULL,
  stock_qty INT NOT NULL DEFAULT 0,
  sales_qty INT NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_catalog_products_tenant_no (tenant_id, product_no),
  CONSTRAINT fk_catalog_products_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sales_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  order_no VARCHAR(80) NOT NULL,
  member_id BIGINT UNSIGNED NULL,
  store_id BIGINT UNSIGNED NULL,
  channel VARCHAR(80) NOT NULL,
  status VARCHAR(32) NOT NULL,
  item_count INT NOT NULL DEFAULT 0,
  total_amount DECIMAL(14,2) NOT NULL,
  discount_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  paid_amount DECIMAL(14,2) NOT NULL DEFAULT 0,
  ordered_at DATETIME(3) NOT NULL,
  paid_at DATETIME(3) NULL,
  completed_at DATETIME(3) NULL,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_sales_orders_tenant_no (tenant_id, order_no),
  KEY idx_sales_orders_member_time (member_id, ordered_at),
  KEY idx_sales_orders_tenant_status_time (tenant_id, status, ordered_at),
  CONSTRAINT fk_sales_orders_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_sales_orders_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE SET NULL,
  CONSTRAINT fk_sales_orders_store FOREIGN KEY (store_id) REFERENCES org_stores (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sales_order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NULL,
  product_name VARCHAR(180) NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  quantity INT NOT NULL,
  line_amount DECIMAL(14,2) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_sales_order_items_order (order_id),
  CONSTRAINT fk_sales_order_items_order FOREIGN KEY (order_id) REFERENCES sales_orders (id) ON DELETE CASCADE,
  CONSTRAINT fk_sales_order_items_product FOREIGN KEY (product_id) REFERENCES catalog_products (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sales_refunds (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  order_id BIGINT UNSIGNED NOT NULL,
  refund_no VARCHAR(80) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  reason TEXT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'pending',
  requested_by BIGINT UNSIGNED NULL,
  requested_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_sales_refunds_tenant_no (tenant_id, refund_no),
  KEY idx_sales_refunds_order (order_id),
  CONSTRAINT fk_sales_refunds_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_sales_refunds_order FOREIGN KEY (order_id) REFERENCES sales_orders (id) ON DELETE CASCADE,
  CONSTRAINT fk_sales_refunds_user FOREIGN KEY (requested_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS marketing_campaigns (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(180) NOT NULL,
  campaign_type VARCHAR(80) NOT NULL,
  target_segment_id BIGINT UNSIGNED NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'draft',
  budget_amount DECIMAL(14,2) NULL,
  starts_at DATETIME(3) NULL,
  ends_at DATETIME(3) NULL,
  rules_json JSON NULL,
  metrics_json JSON NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_marketing_campaigns_status (tenant_id, status),
  CONSTRAINT fk_marketing_campaigns_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_marketing_campaigns_segment FOREIGN KEY (target_segment_id) REFERENCES crm_segments (id) ON DELETE SET NULL,
  CONSTRAINT fk_marketing_campaigns_user FOREIGN KEY (created_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS marketing_coupons (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(160) NOT NULL,
  coupon_type VARCHAR(24) NOT NULL,
  face_value DECIMAL(12,2) NULL,
  threshold_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  total_stock INT NOT NULL DEFAULT 0,
  issued_stock INT NOT NULL DEFAULT 0,
  valid_from DATETIME(3) NULL,
  valid_to DATETIME(3) NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  rules_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_marketing_coupons_tenant_code (tenant_id, code),
  CONSTRAINT fk_marketing_coupons_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS marketing_coupon_grants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  coupon_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NOT NULL,
  grant_no VARCHAR(80) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'issued',
  issued_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  used_at DATETIME(3) NULL,
  order_id BIGINT UNSIGNED NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_marketing_coupon_grants_tenant_no (tenant_id, grant_no),
  CONSTRAINT fk_marketing_coupon_grants_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_marketing_coupon_grants_coupon FOREIGN KEY (coupon_id) REFERENCES marketing_coupons (id) ON DELETE CASCADE,
  CONSTRAINT fk_marketing_coupon_grants_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE,
  CONSTRAINT fk_marketing_coupon_grants_order FOREIGN KEY (order_id) REFERENCES sales_orders (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS marketing_reach_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  campaign_id BIGINT UNSIGNED NULL,
  name VARCHAR(180) NOT NULL,
  channel VARCHAR(32) NOT NULL,
  target_segment_id BIGINT UNSIGNED NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'draft',
  scheduled_at DATETIME(3) NULL,
  payload_json JSON NULL,
  metrics_json JSON NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_marketing_reach_tasks_status (tenant_id, status, scheduled_at),
  CONSTRAINT fk_marketing_reach_tasks_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_marketing_reach_tasks_campaign FOREIGN KEY (campaign_id) REFERENCES marketing_campaigns (id) ON DELETE SET NULL,
  CONSTRAINT fk_marketing_reach_tasks_segment FOREIGN KEY (target_segment_id) REFERENCES crm_segments (id) ON DELETE SET NULL,
  CONSTRAINT fk_marketing_reach_tasks_user FOREIGN KEY (created_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_points_accounts (
  member_id BIGINT UNSIGNED NOT NULL,
  tenant_id BIGINT UNSIGNED NOT NULL,
  available_points INT NOT NULL DEFAULT 0,
  frozen_points INT NOT NULL DEFAULT 0,
  lifetime_points INT NOT NULL DEFAULT 0,
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (member_id),
  CONSTRAINT fk_loyalty_points_accounts_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE,
  CONSTRAINT fk_loyalty_points_accounts_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_points_ledger (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NOT NULL,
  biz_type VARCHAR(80) NOT NULL,
  biz_id BIGINT UNSIGNED NULL,
  points_delta INT NOT NULL,
  balance_after INT NOT NULL,
  description TEXT NULL,
  occurred_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  metadata_json JSON NULL,
  PRIMARY KEY (id),
  KEY idx_loyalty_ledger_member_time (member_id, occurred_at),
  CONSTRAINT fk_loyalty_points_ledger_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_loyalty_points_ledger_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_growth_rules (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  event_type VARCHAR(80) NOT NULL,
  growth_value INT NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  rule_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_loyalty_growth_rules_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_member_benefits (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  level_id BIGINT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  benefit_type VARCHAR(80) NOT NULL,
  quota_json JSON NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_loyalty_member_benefits_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_loyalty_member_benefits_level FOREIGN KEY (level_id) REFERENCES loyalty_membership_levels (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS loyalty_mall_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  sku_no VARCHAR(80) NOT NULL,
  name VARCHAR(160) NOT NULL,
  points_price INT NOT NULL,
  stock_qty INT NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_loyalty_mall_items_tenant_sku (tenant_id, sku_no),
  CONSTRAINT fk_loyalty_mall_items_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_accounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  account_type VARCHAR(32) NOT NULL,
  app_id VARCHAR(120) NULL,
  name VARCHAR(160) NOT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  settings_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_wechat_accounts_tenant_app (tenant_id, account_type, app_id),
  CONSTRAINT fk_wechat_accounts_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  account_id BIGINT UNSIGNED NULL,
  external_id VARCHAR(120) NULL,
  conversation_type VARCHAR(32) NOT NULL,
  title VARCHAR(180) NOT NULL,
  member_id BIGINT UNSIGNED NULL,
  assigned_user_id BIGINT UNSIGNED NULL,
  pinned TINYINT(1) NOT NULL DEFAULT 0,
  unread_count INT NOT NULL DEFAULT 0,
  last_message_preview VARCHAR(255) NULL,
  last_message_at DATETIME(3) NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'open',
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_wechat_conversations_external (tenant_id, account_id, external_id),
  KEY idx_wechat_conversations_last (tenant_id, last_message_at),
  CONSTRAINT fk_wechat_conversations_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_wechat_conversations_account FOREIGN KEY (account_id) REFERENCES wechat_accounts (id) ON DELETE SET NULL,
  CONSTRAINT fk_wechat_conversations_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE SET NULL,
  CONSTRAINT fk_wechat_conversations_user FOREIGN KEY (assigned_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  conversation_id BIGINT UNSIGNED NOT NULL,
  sender_type VARCHAR(24) NOT NULL,
  sender_name VARCHAR(120) NULL,
  message_type VARCHAR(24) NOT NULL DEFAULT 'text',
  content TEXT NOT NULL,
  sent_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  metadata_json JSON NULL,
  PRIMARY KEY (id),
  KEY idx_wechat_messages_conversation_time (conversation_id, sent_at),
  CONSTRAINT fk_wechat_messages_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_wechat_messages_conversation FOREIGN KEY (conversation_id) REFERENCES wechat_conversations (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_auto_reply_rules (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  keywords_json JSON NULL,
  reply_content TEXT NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  priority INT NOT NULL DEFAULT 0,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_wechat_auto_reply_rules_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_community_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  account_id BIGINT UNSIGNED NULL,
  group_no VARCHAR(80) NULL,
  name VARCHAR(160) NOT NULL,
  owner_user_id BIGINT UNSIGNED NULL,
  member_count INT NOT NULL DEFAULT 0,
  active_status VARCHAR(24) NOT NULL DEFAULT 'active',
  tags_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_wechat_community_groups_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_wechat_community_groups_account FOREIGN KEY (account_id) REFERENCES wechat_accounts (id) ON DELETE SET NULL,
  CONSTRAINT fk_wechat_community_groups_user FOREIGN KEY (owner_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wechat_moments_posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  account_id BIGINT UNSIGNED NULL,
  title VARCHAR(180) NOT NULL,
  content TEXT NOT NULL,
  media_urls_json JSON NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'draft',
  scheduled_at DATETIME(3) NULL,
  published_at DATETIME(3) NULL,
  metrics_json JSON NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_wechat_moments_posts_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_wechat_moments_posts_account FOREIGN KEY (account_id) REFERENCES wechat_accounts (id) ON DELETE SET NULL,
  CONSTRAINT fk_wechat_moments_posts_user FOREIGN KEY (created_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scrm_contacts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  member_id BIGINT UNSIGNED NULL,
  external_user_id VARCHAR(120) NULL,
  name VARCHAR(120) NOT NULL,
  owner_employee_id BIGINT UNSIGNED NULL,
  follow_status VARCHAR(24) NOT NULL DEFAULT 'following',
  tags_json JSON NULL,
  profile_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_scrm_contacts_member (tenant_id, member_id),
  CONSTRAINT fk_scrm_contacts_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_scrm_contacts_member FOREIGN KEY (member_id) REFERENCES crm_members (id) ON DELETE SET NULL,
  CONSTRAINT fk_scrm_contacts_employee FOREIGN KEY (owner_employee_id) REFERENCES org_employees (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scrm_customer_groups (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(160) NOT NULL,
  owner_employee_id BIGINT UNSIGNED NULL,
  member_count INT NOT NULL DEFAULT 0,
  tags_json JSON NULL,
  active_status VARCHAR(24) NOT NULL DEFAULT 'active',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_scrm_customer_groups_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_scrm_customer_groups_employee FOREIGN KEY (owner_employee_id) REFERENCES org_employees (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scrm_materials (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  material_type VARCHAR(32) NOT NULL,
  content_json JSON NULL,
  tags_json JSON NULL,
  created_by BIGINT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_scrm_materials_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_scrm_materials_user FOREIGN KEY (created_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS scrm_group_message_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(180) NOT NULL,
  material_id BIGINT UNSIGNED NULL,
  target_json JSON NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'draft',
  scheduled_at DATETIME(3) NULL,
  metrics_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_scrm_group_message_tasks_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_scrm_group_message_tasks_material FOREIGN KEY (material_id) REFERENCES scrm_materials (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_prompt_templates (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  scene VARCHAR(120) NOT NULL,
  prompt VARCHAR(255) NOT NULL,
  owner_user_id BIGINT UNSIGNED NULL,
  use_count INT NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ai_prompt_templates_tenant_scene_prompt (tenant_id, scene, prompt),
  CONSTRAINT fk_ai_prompt_templates_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_prompt_templates_user FOREIGN KEY (owner_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  title VARCHAR(180) NOT NULL,
  scope VARCHAR(80) NOT NULL DEFAULT '近30天',
  active_tool VARCHAR(80) NOT NULL DEFAULT '数据洞察',
  status VARCHAR(24) NOT NULL DEFAULT 'open',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_ai_claw_sessions_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_claw_sessions_user FOREIGN KEY (user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  session_id BIGINT UNSIGNED NOT NULL,
  role VARCHAR(24) NOT NULL,
  content TEXT NOT NULL,
  tool_name VARCHAR(120) NULL,
  scope VARCHAR(80) NULL,
  steps_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_ai_messages_session_time (session_id, created_at),
  CONSTRAINT fk_ai_claw_messages_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_claw_messages_session FOREIGN KEY (session_id) REFERENCES ai_claw_sessions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_insights (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  summary TEXT NOT NULL,
  tone VARCHAR(32) NULL,
  insight_type VARCHAR(80) NOT NULL,
  source_json JSON NULL,
  priority INT NOT NULL DEFAULT 0,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  generated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ai_claw_insights_tenant_title (tenant_id, title),
  CONSTRAINT fk_ai_claw_insights_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_suggestions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(180) NOT NULL,
  description TEXT NOT NULL,
  action_label VARCHAR(80) NOT NULL,
  expected_impact VARCHAR(80) NULL,
  source_insight_id BIGINT UNSIGNED NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'pending',
  payload_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ai_claw_suggestions_tenant_title (tenant_id, title),
  CONSTRAINT fk_ai_claw_suggestions_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_claw_suggestions_insight FOREIGN KEY (source_insight_id) REFERENCES ai_claw_insights (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ai_claw_actions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  suggestion_id BIGINT UNSIGNED NULL,
  action_type VARCHAR(80) NOT NULL,
  target_type VARCHAR(80) NULL,
  target_id BIGINT UNSIGNED NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'created',
  created_by BIGINT UNSIGNED NULL,
  payload_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_ai_claw_actions_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ai_claw_actions_suggestion FOREIGN KEY (suggestion_id) REFERENCES ai_claw_suggestions (id) ON DELETE SET NULL,
  CONSTRAINT fk_ai_claw_actions_user FOREIGN KEY (created_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_system_parameters (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  param_key VARCHAR(120) NOT NULL,
  value_json JSON NOT NULL,
  description TEXT NULL,
  is_sensitive TINYINT(1) NOT NULL DEFAULT 0,
  updated_by BIGINT UNSIGNED NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ops_system_parameters_tenant_key (tenant_id, param_key),
  CONSTRAINT fk_ops_system_parameters_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ops_system_parameters_user FOREIGN KEY (updated_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_message_templates (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  channel VARCHAR(32) NOT NULL,
  title VARCHAR(180) NOT NULL,
  content TEXT NOT NULL,
  variables_json JSON NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'draft',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ops_message_templates_tenant_code (tenant_id, code),
  CONSTRAINT fk_ops_message_templates_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_dictionary_types (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(160) NOT NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ops_dictionary_types_tenant_code (tenant_id, code),
  CONSTRAINT fk_ops_dictionary_types_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_dictionary_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  type_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  label VARCHAR(160) NOT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  metadata_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ops_dictionary_items_type_code (type_id, code),
  CONSTRAINT fk_ops_dictionary_items_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ops_dictionary_items_type FOREIGN KEY (type_id) REFERENCES ops_dictionary_types (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_scheduled_jobs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  name VARCHAR(160) NOT NULL,
  cron_expr VARCHAR(80) NOT NULL,
  handler VARCHAR(160) NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  last_run_at DATETIME(3) NULL,
  next_run_at DATETIME(3) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_ops_scheduled_jobs_tenant_code (tenant_id, code),
  CONSTRAINT fk_ops_scheduled_jobs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_job_runs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  job_id BIGINT UNSIGNED NOT NULL,
  status VARCHAR(24) NOT NULL,
  started_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  finished_at DATETIME(3) NULL,
  output_json JSON NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_ops_job_runs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ops_job_runs_job FOREIGN KEY (job_id) REFERENCES ops_scheduled_jobs (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ops_audit_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  actor_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(120) NOT NULL,
  resource_type VARCHAR(120) NOT NULL,
  resource_id BIGINT UNSIGNED NULL,
  before_json JSON NULL,
  after_json JSON NULL,
  ip_address VARCHAR(45) NULL,
  user_agent VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  KEY idx_ops_audit_resource (tenant_id, resource_type, resource_id, created_at),
  CONSTRAINT fk_ops_audit_logs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_ops_audit_logs_user FOREIGN KEY (actor_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_applications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  app_key VARCHAR(120) NOT NULL,
  name VARCHAR(160) NOT NULL,
  owner_user_id BIGINT UNSIGNED NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  scopes_json JSON NULL,
  secret_hash VARCHAR(255) NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_dev_applications_tenant_key (tenant_id, app_key),
  CONSTRAINT fk_dev_applications_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_applications_user FOREIGN KEY (owner_user_id) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_api_docs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(80) NOT NULL,
  title VARCHAR(180) NOT NULL,
  path VARCHAR(255) NOT NULL,
  method VARCHAR(16) NOT NULL,
  version VARCHAR(24) NOT NULL DEFAULT 'v1',
  doc_markdown LONGTEXT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'published',
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_dev_api_docs_tenant_code (tenant_id, code),
  CONSTRAINT fk_dev_api_docs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_api_permissions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  application_id BIGINT UNSIGNED NOT NULL,
  api_doc_id BIGINT UNSIGNED NOT NULL,
  field_scope_json JSON NULL,
  data_scope VARCHAR(80) NOT NULL DEFAULT 'tenant',
  granted_by BIGINT UNSIGNED NULL,
  granted_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  UNIQUE KEY uk_dev_api_permissions_app_doc (application_id, api_doc_id),
  CONSTRAINT fk_dev_api_permissions_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_api_permissions_app FOREIGN KEY (application_id) REFERENCES dev_applications (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_api_permissions_doc FOREIGN KEY (api_doc_id) REFERENCES dev_api_docs (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_api_permissions_user FOREIGN KEY (granted_by) REFERENCES iam_users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_webhooks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  application_id BIGINT UNSIGNED NULL,
  name VARCHAR(160) NOT NULL,
  callback_url VARCHAR(500) NOT NULL,
  secret_hash VARCHAR(255) NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  retry_policy_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_dev_webhooks_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_webhooks_app FOREIGN KEY (application_id) REFERENCES dev_applications (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_event_subscriptions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  application_id BIGINT UNSIGNED NULL,
  event_type VARCHAR(120) NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 1,
  filter_json JSON NULL,
  created_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  updated_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (id),
  CONSTRAINT fk_dev_event_subscriptions_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_event_subscriptions_app FOREIGN KEY (application_id) REFERENCES dev_applications (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS dev_api_call_logs (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  tenant_id BIGINT UNSIGNED NOT NULL,
  application_id BIGINT UNSIGNED NULL,
  api_doc_id BIGINT UNSIGNED NULL,
  request_id VARCHAR(120) NOT NULL,
  method VARCHAR(16) NOT NULL,
  path VARCHAR(255) NOT NULL,
  status_code INT NOT NULL,
  latency_ms INT NOT NULL,
  error_code VARCHAR(80) NULL,
  requested_at DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  request_json JSON NULL,
  response_json JSON NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_dev_api_call_logs_tenant_request (tenant_id, request_id),
  KEY idx_dev_api_call_logs_time (tenant_id, requested_at),
  CONSTRAINT fk_dev_api_call_logs_tenant FOREIGN KEY (tenant_id) REFERENCES app_tenants (id) ON DELETE CASCADE,
  CONSTRAINT fk_dev_api_call_logs_app FOREIGN KEY (application_id) REFERENCES dev_applications (id) ON DELETE SET NULL,
  CONSTRAINT fk_dev_api_call_logs_doc FOREIGN KEY (api_doc_id) REFERENCES dev_api_docs (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
