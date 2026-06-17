-- IS 微智会员 SCRM PostgreSQL schema
-- Run after 00_bootstrap.sql while connected to database `member_crm`.

BEGIN;

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE SCHEMA IF NOT EXISTS app;
CREATE SCHEMA IF NOT EXISTS org;
CREATE SCHEMA IF NOT EXISTS iam;
CREATE SCHEMA IF NOT EXISTS crm;
CREATE SCHEMA IF NOT EXISTS catalog;
CREATE SCHEMA IF NOT EXISTS sales;
CREATE SCHEMA IF NOT EXISTS marketing;
CREATE SCHEMA IF NOT EXISTS loyalty;
CREATE SCHEMA IF NOT EXISTS wechat;
CREATE SCHEMA IF NOT EXISTS scrm;
CREATE SCHEMA IF NOT EXISTS ai;
CREATE SCHEMA IF NOT EXISTS ops;
CREATE SCHEMA IF NOT EXISTS dev;

CREATE OR REPLACE FUNCTION app.set_updated_at()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE app.tenants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  brand_name text NOT NULL DEFAULT '微智',
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE org.organizations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  parent_id uuid REFERENCES org.organizations(id) ON DELETE SET NULL,
  code text NOT NULL,
  name text NOT NULL,
  org_type text NOT NULL CHECK (org_type IN ('headquarters', 'region', 'city', 'store_group', 'department')),
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  sort_order integer NOT NULL DEFAULT 0,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE org.stores (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  organization_id uuid REFERENCES org.organizations(id) ON DELETE SET NULL,
  store_code text NOT NULL,
  name text NOT NULL,
  city text,
  address text,
  phone text,
  service_status text NOT NULL DEFAULT 'open' CHECK (service_status IN ('open', 'closed', 'paused')),
  opened_on date,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, store_code)
);

CREATE TABLE iam.users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  username text NOT NULL,
  display_name text NOT NULL,
  email text,
  phone text,
  password_hash text,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled', 'locked')),
  last_login_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, username),
  UNIQUE (tenant_id, email)
);

CREATE TABLE org.employees (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  user_id uuid UNIQUE REFERENCES iam.users(id) ON DELETE SET NULL,
  organization_id uuid REFERENCES org.organizations(id) ON DELETE SET NULL,
  store_id uuid REFERENCES org.stores(id) ON DELETE SET NULL,
  employee_no text NOT NULL,
  name text NOT NULL,
  title text,
  employment_status text NOT NULL DEFAULT 'active' CHECK (employment_status IN ('active', 'inactive', 'left')),
  joined_on date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, employee_no)
);

CREATE TABLE iam.roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  data_scope text NOT NULL DEFAULT 'tenant' CHECK (data_scope IN ('tenant', 'organization', 'store', 'self')),
  description text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE iam.permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  resource text NOT NULL,
  action text NOT NULL,
  description text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE iam.role_permissions (
  role_id uuid NOT NULL REFERENCES iam.roles(id) ON DELETE CASCADE,
  permission_id uuid NOT NULL REFERENCES iam.permissions(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE iam.user_roles (
  user_id uuid NOT NULL REFERENCES iam.users(id) ON DELETE CASCADE,
  role_id uuid NOT NULL REFERENCES iam.roles(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, role_id)
);

CREATE TABLE loyalty.membership_levels (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  rank integer NOT NULL,
  min_growth_value integer NOT NULL DEFAULT 0,
  keep_months integer NOT NULL DEFAULT 12,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  benefits jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code),
  UNIQUE (tenant_id, rank)
);

CREATE TABLE crm.members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  member_no text NOT NULL,
  name text NOT NULL,
  phone_hash text NOT NULL,
  phone_mask text NOT NULL,
  gender text CHECK (gender IN ('male', 'female', 'unknown')),
  birthday date,
  level_id uuid REFERENCES loyalty.membership_levels(id) ON DELETE SET NULL,
  source_channel text NOT NULL,
  register_store_id uuid REFERENCES org.stores(id) ON DELETE SET NULL,
  register_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'to_wake', 'frozen', 'deleted')),
  profile jsonb NOT NULL DEFAULT '{}'::jsonb,
  last_active_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, member_no),
  UNIQUE (tenant_id, phone_hash)
);

CREATE TABLE crm.member_metrics (
  member_id uuid PRIMARY KEY REFERENCES crm.members(id) ON DELETE CASCADE,
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  total_spend numeric(14,2) NOT NULL DEFAULT 0 CHECK (total_spend >= 0),
  order_count integer NOT NULL DEFAULT 0 CHECK (order_count >= 0),
  avg_order_amount numeric(12,2) NOT NULL DEFAULT 0 CHECK (avg_order_amount >= 0),
  growth_value integer NOT NULL DEFAULT 0,
  contribution_score integer NOT NULL DEFAULT 0 CHECK (contribution_score BETWEEN 0 AND 100),
  last_order_at timestamptz,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE crm.member_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  member_id uuid REFERENCES crm.members(id) ON DELETE SET NULL,
  action text NOT NULL,
  detail text NOT NULL,
  operator_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  channel text,
  event_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE crm.tags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  category text NOT NULL,
  color text,
  enabled boolean NOT NULL DEFAULT true,
  rules jsonb NOT NULL DEFAULT '[]'::jsonb,
  coverage_count integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, name)
);

CREATE TABLE crm.member_tags (
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES crm.members(id) ON DELETE CASCADE,
  tag_id uuid NOT NULL REFERENCES crm.tags(id) ON DELETE CASCADE,
  source text NOT NULL DEFAULT 'manual',
  assigned_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (member_id, tag_id)
);

CREATE TABLE crm.segments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  description text,
  segment_type text NOT NULL CHECK (segment_type IN ('dynamic', 'static', 'system')),
  rule_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  enabled boolean NOT NULL DEFAULT true,
  member_count integer NOT NULL DEFAULT 0,
  refreshed_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, name)
);

CREATE TABLE crm.segment_members (
  segment_id uuid NOT NULL REFERENCES crm.segments(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES crm.members(id) ON DELETE CASCADE,
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (segment_id, member_id)
);

CREATE TABLE catalog.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  product_no text NOT NULL,
  name text NOT NULL,
  category text NOT NULL,
  price numeric(12,2) NOT NULL CHECK (price >= 0),
  list_price numeric(12,2) CHECK (list_price IS NULL OR list_price >= 0),
  stock_qty integer NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  sales_qty integer NOT NULL DEFAULT 0 CHECK (sales_qty >= 0),
  enabled boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, product_no)
);

CREATE TABLE sales.orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  order_no text NOT NULL,
  member_id uuid REFERENCES crm.members(id) ON DELETE SET NULL,
  store_id uuid REFERENCES org.stores(id) ON DELETE SET NULL,
  channel text NOT NULL,
  status text NOT NULL CHECK (status IN ('pending_payment', 'pending_ship', 'shipping', 'completed', 'refunding', 'refunded', 'closed')),
  item_count integer NOT NULL DEFAULT 0 CHECK (item_count >= 0),
  total_amount numeric(14,2) NOT NULL CHECK (total_amount >= 0),
  discount_amount numeric(14,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
  paid_amount numeric(14,2) NOT NULL DEFAULT 0 CHECK (paid_amount >= 0),
  ordered_at timestamptz NOT NULL,
  paid_at timestamptz,
  completed_at timestamptz,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, order_no)
);

CREATE TABLE sales.order_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid NOT NULL REFERENCES sales.orders(id) ON DELETE CASCADE,
  product_id uuid REFERENCES catalog.products(id) ON DELETE SET NULL,
  product_name text NOT NULL,
  unit_price numeric(12,2) NOT NULL CHECK (unit_price >= 0),
  quantity integer NOT NULL CHECK (quantity > 0),
  line_amount numeric(14,2) NOT NULL CHECK (line_amount >= 0),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE sales.refunds (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  order_id uuid NOT NULL REFERENCES sales.orders(id) ON DELETE CASCADE,
  refund_no text NOT NULL,
  amount numeric(14,2) NOT NULL CHECK (amount >= 0),
  reason text,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'completed')),
  requested_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  requested_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, refund_no)
);

CREATE TABLE marketing.campaigns (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  campaign_type text NOT NULL,
  target_segment_id uuid REFERENCES crm.segments(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'running', 'paused', 'completed', 'archived')),
  budget_amount numeric(14,2) CHECK (budget_amount IS NULL OR budget_amount >= 0),
  starts_at timestamptz,
  ends_at timestamptz,
  rules jsonb NOT NULL DEFAULT '{}'::jsonb,
  metrics jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE marketing.coupons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  coupon_type text NOT NULL CHECK (coupon_type IN ('cash', 'discount', 'gift', 'shipping')),
  face_value numeric(12,2) CHECK (face_value IS NULL OR face_value >= 0),
  threshold_amount numeric(12,2) NOT NULL DEFAULT 0 CHECK (threshold_amount >= 0),
  total_stock integer NOT NULL DEFAULT 0 CHECK (total_stock >= 0),
  issued_stock integer NOT NULL DEFAULT 0 CHECK (issued_stock >= 0),
  valid_from timestamptz,
  valid_to timestamptz,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled', 'expired')),
  rules jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE marketing.coupon_grants (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  coupon_id uuid NOT NULL REFERENCES marketing.coupons(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES crm.members(id) ON DELETE CASCADE,
  grant_no text NOT NULL,
  status text NOT NULL DEFAULT 'issued' CHECK (status IN ('issued', 'used', 'expired', 'revoked')),
  issued_at timestamptz NOT NULL DEFAULT now(),
  used_at timestamptz,
  order_id uuid REFERENCES sales.orders(id) ON DELETE SET NULL,
  UNIQUE (tenant_id, grant_no)
);

CREATE TABLE marketing.reach_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  campaign_id uuid REFERENCES marketing.campaigns(id) ON DELETE SET NULL,
  name text NOT NULL,
  channel text NOT NULL CHECK (channel IN ('sms', 'wechat', 'enterprise_wechat', 'site_message', 'email')),
  target_segment_id uuid REFERENCES crm.segments(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'running', 'completed', 'failed')),
  scheduled_at timestamptz,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  metrics jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE loyalty.points_accounts (
  member_id uuid PRIMARY KEY REFERENCES crm.members(id) ON DELETE CASCADE,
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  available_points integer NOT NULL DEFAULT 0,
  frozen_points integer NOT NULL DEFAULT 0,
  lifetime_points integer NOT NULL DEFAULT 0,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE loyalty.points_ledger (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  member_id uuid NOT NULL REFERENCES crm.members(id) ON DELETE CASCADE,
  biz_type text NOT NULL,
  biz_id uuid,
  points_delta integer NOT NULL,
  balance_after integer NOT NULL,
  description text,
  occurred_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE loyalty.growth_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  event_type text NOT NULL,
  growth_value integer NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  rule_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE loyalty.member_benefits (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  level_id uuid REFERENCES loyalty.membership_levels(id) ON DELETE CASCADE,
  name text NOT NULL,
  benefit_type text NOT NULL,
  quota_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE loyalty.mall_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  sku_no text NOT NULL,
  name text NOT NULL,
  points_price integer NOT NULL CHECK (points_price >= 0),
  stock_qty integer NOT NULL DEFAULT 0 CHECK (stock_qty >= 0),
  enabled boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, sku_no)
);

CREATE TABLE wechat.accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  account_type text NOT NULL CHECK (account_type IN ('wechat_service', 'mini_program', 'enterprise_wechat')),
  app_id text,
  name text NOT NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  settings jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, account_type, app_id)
);

CREATE TABLE wechat.conversations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  account_id uuid REFERENCES wechat.accounts(id) ON DELETE SET NULL,
  external_id text,
  conversation_type text NOT NULL CHECK (conversation_type IN ('chat', 'group', 'official_account')),
  title text NOT NULL,
  member_id uuid REFERENCES crm.members(id) ON DELETE SET NULL,
  assigned_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  pinned boolean NOT NULL DEFAULT false,
  unread_count integer NOT NULL DEFAULT 0,
  last_message_preview text,
  last_message_at timestamptz,
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'closed', 'archived')),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, account_id, external_id)
);

CREATE TABLE wechat.messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  conversation_id uuid NOT NULL REFERENCES wechat.conversations(id) ON DELETE CASCADE,
  sender_type text NOT NULL CHECK (sender_type IN ('customer', 'employee', 'system', 'bot')),
  sender_name text,
  message_type text NOT NULL DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'voice', 'video', 'file', 'link')),
  content text NOT NULL,
  sent_at timestamptz NOT NULL DEFAULT now(),
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE wechat.auto_reply_rules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  keywords text[] NOT NULL DEFAULT ARRAY[]::text[],
  reply_content text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  priority integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE wechat.community_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  account_id uuid REFERENCES wechat.accounts(id) ON DELETE SET NULL,
  group_no text,
  name text NOT NULL,
  owner_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  member_count integer NOT NULL DEFAULT 0,
  active_status text NOT NULL DEFAULT 'active' CHECK (active_status IN ('active', 'silent', 'archived')),
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE wechat.moments_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  account_id uuid REFERENCES wechat.accounts(id) ON DELETE SET NULL,
  title text NOT NULL,
  content text NOT NULL,
  media_urls text[] NOT NULL DEFAULT ARRAY[]::text[],
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'published', 'failed')),
  scheduled_at timestamptz,
  published_at timestamptz,
  metrics jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE scrm.contacts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  member_id uuid REFERENCES crm.members(id) ON DELETE SET NULL,
  external_user_id text,
  name text NOT NULL,
  owner_employee_id uuid REFERENCES org.employees(id) ON DELETE SET NULL,
  follow_status text NOT NULL DEFAULT 'following' CHECK (follow_status IN ('following', 'blocked', 'deleted')),
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  profile jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE scrm.customer_groups (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  owner_employee_id uuid REFERENCES org.employees(id) ON DELETE SET NULL,
  member_count integer NOT NULL DEFAULT 0,
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  active_status text NOT NULL DEFAULT 'active' CHECK (active_status IN ('active', 'silent', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE scrm.materials (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  title text NOT NULL,
  material_type text NOT NULL CHECK (material_type IN ('text', 'image', 'poster', 'link', 'mini_program', 'video')),
  content jsonb NOT NULL DEFAULT '{}'::jsonb,
  tags text[] NOT NULL DEFAULT ARRAY[]::text[],
  created_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE scrm.group_message_tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  name text NOT NULL,
  material_id uuid REFERENCES scrm.materials(id) ON DELETE SET NULL,
  target_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'scheduled', 'running', 'completed', 'failed')),
  scheduled_at timestamptz,
  metrics jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ai.claw_prompt_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  scene text NOT NULL,
  prompt text NOT NULL,
  owner_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  use_count integer NOT NULL DEFAULT 0 CHECK (use_count >= 0),
  enabled boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, scene, prompt)
);

CREATE TABLE ai.claw_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  title text NOT NULL,
  scope text NOT NULL DEFAULT '近30天',
  active_tool text NOT NULL DEFAULT '数据洞察',
  status text NOT NULL DEFAULT 'open' CHECK (status IN ('open', 'archived')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ai.claw_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  session_id uuid NOT NULL REFERENCES ai.claw_sessions(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('user', 'assistant', 'system')),
  content text NOT NULL,
  tool_name text,
  scope text,
  steps jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ai.claw_insights (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  title text NOT NULL,
  summary text NOT NULL,
  tone text,
  insight_type text NOT NULL,
  source_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  priority integer NOT NULL DEFAULT 0,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'dismissed', 'resolved')),
  generated_at timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, title)
);

CREATE TABLE ai.claw_suggestions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text NOT NULL,
  action_label text NOT NULL,
  expected_impact text,
  source_insight_id uuid REFERENCES ai.claw_insights(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'done', 'dismissed')),
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, title)
);

CREATE TABLE ai.claw_actions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  suggestion_id uuid REFERENCES ai.claw_suggestions(id) ON DELETE SET NULL,
  action_type text NOT NULL,
  target_type text,
  target_id uuid,
  status text NOT NULL DEFAULT 'created' CHECK (status IN ('created', 'running', 'completed', 'failed')),
  created_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ops.system_parameters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  key text NOT NULL,
  value jsonb NOT NULL,
  description text,
  is_sensitive boolean NOT NULL DEFAULT false,
  updated_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, key)
);

CREATE TABLE ops.message_templates (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  channel text NOT NULL,
  title text NOT NULL,
  content text NOT NULL,
  variables jsonb NOT NULL DEFAULT '[]'::jsonb,
  status text NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'active', 'disabled')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE ops.dictionary_types (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE ops.dictionary_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  type_id uuid NOT NULL REFERENCES ops.dictionary_types(id) ON DELETE CASCADE,
  code text NOT NULL,
  label text NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  enabled boolean NOT NULL DEFAULT true,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (type_id, code)
);

CREATE TABLE ops.scheduled_jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  name text NOT NULL,
  cron_expr text NOT NULL,
  handler text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  last_run_at timestamptz,
  next_run_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE ops.job_runs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  job_id uuid NOT NULL REFERENCES ops.scheduled_jobs(id) ON DELETE CASCADE,
  status text NOT NULL CHECK (status IN ('running', 'success', 'failed')),
  started_at timestamptz NOT NULL DEFAULT now(),
  finished_at timestamptz,
  output jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE ops.audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  actor_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  action text NOT NULL,
  resource_type text NOT NULL,
  resource_id uuid,
  before_json jsonb,
  after_json jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dev.applications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  app_key text NOT NULL,
  name text NOT NULL,
  owner_user_id uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'disabled')),
  scopes text[] NOT NULL DEFAULT ARRAY[]::text[],
  secret_hash text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, app_key)
);

CREATE TABLE dev.api_docs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  code text NOT NULL,
  title text NOT NULL,
  path text NOT NULL,
  method text NOT NULL,
  version text NOT NULL DEFAULT 'v1',
  doc_markdown text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'published' CHECK (status IN ('draft', 'published', 'deprecated')),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (tenant_id, code)
);

CREATE TABLE dev.api_permissions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  application_id uuid NOT NULL REFERENCES dev.applications(id) ON DELETE CASCADE,
  api_doc_id uuid NOT NULL REFERENCES dev.api_docs(id) ON DELETE CASCADE,
  field_scope jsonb NOT NULL DEFAULT '{}'::jsonb,
  data_scope text NOT NULL DEFAULT 'tenant',
  granted_by uuid REFERENCES iam.users(id) ON DELETE SET NULL,
  granted_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (application_id, api_doc_id)
);

CREATE TABLE dev.webhooks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  application_id uuid REFERENCES dev.applications(id) ON DELETE CASCADE,
  name text NOT NULL,
  callback_url text NOT NULL,
  secret_hash text,
  enabled boolean NOT NULL DEFAULT true,
  retry_policy jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dev.event_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  application_id uuid REFERENCES dev.applications(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  enabled boolean NOT NULL DEFAULT true,
  filter_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE dev.api_call_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id uuid NOT NULL REFERENCES app.tenants(id) ON DELETE CASCADE,
  application_id uuid REFERENCES dev.applications(id) ON DELETE SET NULL,
  api_doc_id uuid REFERENCES dev.api_docs(id) ON DELETE SET NULL,
  request_id text NOT NULL,
  method text NOT NULL,
  path text NOT NULL,
  status_code integer NOT NULL,
  latency_ms integer NOT NULL CHECK (latency_ms >= 0),
  error_code text,
  requested_at timestamptz NOT NULL DEFAULT now(),
  request_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  response_json jsonb NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE (tenant_id, request_id)
);

CREATE INDEX idx_org_organizations_tenant_parent ON org.organizations (tenant_id, parent_id);
CREATE INDEX idx_org_stores_tenant_city ON org.stores (tenant_id, city);
CREATE INDEX idx_iam_users_tenant_status ON iam.users (tenant_id, status);
CREATE INDEX idx_crm_member_metrics_score ON crm.member_metrics (tenant_id, contribution_score DESC);
CREATE INDEX idx_crm_members_tenant_status ON crm.members (tenant_id, status);
CREATE INDEX idx_crm_members_tenant_level ON crm.members (tenant_id, level_id);
CREATE INDEX idx_crm_members_source ON crm.members (tenant_id, source_channel);
CREATE INDEX idx_crm_member_logs_member_time ON crm.member_logs (member_id, event_at DESC);
CREATE INDEX idx_crm_member_tags_tag ON crm.member_tags (tag_id, assigned_at DESC);
CREATE INDEX idx_sales_orders_member_time ON sales.orders (member_id, ordered_at DESC);
CREATE INDEX idx_sales_orders_tenant_status_time ON sales.orders (tenant_id, status, ordered_at DESC);
CREATE INDEX idx_marketing_campaigns_status ON marketing.campaigns (tenant_id, status);
CREATE INDEX idx_marketing_reach_tasks_status ON marketing.reach_tasks (tenant_id, status, scheduled_at);
CREATE INDEX idx_loyalty_ledger_member_time ON loyalty.points_ledger (member_id, occurred_at DESC);
CREATE INDEX idx_wechat_conversations_last ON wechat.conversations (tenant_id, last_message_at DESC);
CREATE INDEX idx_wechat_messages_conversation_time ON wechat.messages (conversation_id, sent_at);
CREATE INDEX idx_scrm_contacts_member ON scrm.contacts (tenant_id, member_id);
CREATE INDEX idx_ai_messages_session_time ON ai.claw_messages (session_id, created_at);
CREATE INDEX idx_ops_audit_resource ON ops.audit_logs (tenant_id, resource_type, resource_id, created_at DESC);
CREATE INDEX idx_dev_api_call_logs_time ON dev.api_call_logs (tenant_id, requested_at DESC);

DO $$
DECLARE
  target record;
BEGIN
  FOR target IN
    SELECT table_schema, table_name
    FROM information_schema.columns
    WHERE column_name = 'updated_at'
      AND table_schema IN ('app', 'org', 'iam', 'crm', 'catalog', 'sales', 'marketing', 'loyalty', 'wechat', 'scrm', 'ai', 'ops', 'dev')
    GROUP BY table_schema, table_name
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS set_updated_at ON %I.%I', target.table_schema, target.table_name);
    EXECUTE format('CREATE TRIGGER set_updated_at BEFORE UPDATE ON %I.%I FOR EACH ROW EXECUTE FUNCTION app.set_updated_at()', target.table_schema, target.table_name);
  END LOOP;
END;
$$;

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_crm_app') THEN
    EXECUTE 'GRANT USAGE ON SCHEMA app, org, iam, crm, catalog, sales, marketing, loyalty, wechat, scrm, ai, ops, dev TO member_crm_app';
    EXECUTE 'GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA app, org, iam, crm, catalog, sales, marketing, loyalty, wechat, scrm, ai, ops, dev TO member_crm_app';
    EXECUTE 'GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA app, org, iam, crm, catalog, sales, marketing, loyalty, wechat, scrm, ai, ops, dev TO member_crm_app';
  END IF;

  IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'member_crm_readonly') THEN
    EXECUTE 'GRANT USAGE ON SCHEMA app, org, iam, crm, catalog, sales, marketing, loyalty, wechat, scrm, ai, ops, dev TO member_crm_readonly';
    EXECUTE 'GRANT SELECT ON ALL TABLES IN SCHEMA app, org, iam, crm, catalog, sales, marketing, loyalty, wechat, scrm, ai, ops, dev TO member_crm_readonly';
  END IF;
END;
$$;

COMMIT;
