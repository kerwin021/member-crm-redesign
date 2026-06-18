-- Demo data aligned with the current React prototype.
-- Run after 01_schema.sql while connected to the same target database.

SET NAMES utf8mb4;
SET time_zone = '+08:00';

START TRANSACTION;

INSERT INTO app_tenants (code, name, brand_name, settings_json)
VALUES ('ym-foods', '一鸣食品', '微智', JSON_OBJECT('timezone', 'Asia/Shanghai', 'currency', 'CNY'))
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  brand_name = VALUES(brand_name),
  settings_json = VALUES(settings_json);

SET @tenant_id = (SELECT id FROM app_tenants WHERE code = 'ym-foods');

INSERT INTO org_organizations (tenant_id, code, name, org_type)
VALUES (@tenant_id, 'HQ', '一鸣食品总部', 'headquarters')
ON DUPLICATE KEY UPDATE name = VALUES(name), org_type = VALUES(org_type);

SET @org_root_id = (SELECT id FROM org_organizations WHERE tenant_id = @tenant_id AND code = 'HQ');

INSERT INTO iam_users (tenant_id, username, display_name, email, status)
VALUES (@tenant_id, 'admin', '超级管理员', 'admin@example.com', 'active')
ON DUPLICATE KEY UPDATE display_name = VALUES(display_name), status = VALUES(status);

SET @admin_user_id = (SELECT id FROM iam_users WHERE tenant_id = @tenant_id AND username = 'admin');

INSERT INTO org_employees (tenant_id, user_id, organization_id, employee_no, name, title, employment_status, joined_on)
VALUES (@tenant_id, @admin_user_id, @org_root_id, 'E0001', '超级管理员', '系统管理员', 'active', '2026-01-01')
ON DUPLICATE KEY UPDATE
  user_id = VALUES(user_id),
  organization_id = VALUES(organization_id),
  name = VALUES(name),
  title = VALUES(title);

INSERT INTO org_stores (tenant_id, store_code, name, city, address, service_status, opened_on)
VALUES
  (@tenant_id, 'S-HZ-XH', '杭州西湖店', '杭州', '杭州市西湖区会员路 1 号', 'open', '2023-03-01'),
  (@tenant_id, 'S-NB-YZ', '宁波鄞州店', '宁波', '宁波市鄞州区云门路 6 号', 'open', '2023-05-12'),
  (@tenant_id, 'S-WZ-LC', '温州鹿城店', '温州', '温州市鹿城区晨光路 8 号', 'open', '2023-08-20'),
  (@tenant_id, 'S-HZ-BJ', '杭州滨江店', '杭州', '杭州市滨江区星河路 9 号', 'open', '2024-02-18'),
  (@tenant_id, 'S-SX-YC', '绍兴越城店', '绍兴', '绍兴市越城区环城路 12 号', 'open', '2024-04-16'),
  (@tenant_id, 'S-TZ-JJ', '台州椒江店', '台州', '台州市椒江区海门路 16 号', 'open', '2024-06-08')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  city = VALUES(city),
  address = VALUES(address),
  service_status = VALUES(service_status);

INSERT INTO loyalty_membership_levels (tenant_id, code, name, level_rank, min_growth_value, benefits_json)
VALUES
  (@tenant_id, 'normal', '普通卡', 1, 0, JSON_ARRAY('会员积分')),
  (@tenant_id, 'silver', '银卡', 2, 1000, JSON_ARRAY('会员积分', '会员日专享价')),
  (@tenant_id, 'gold', '金卡', 3, 3000, JSON_ARRAY('会员积分', '生日月双倍积分')),
  (@tenant_id, 'platinum', '白金卡', 4, 8000, JSON_ARRAY('专属客服', '新品试吃')),
  (@tenant_id, 'diamond', '钻石卡', 5, 15000, JSON_ARRAY('专属客服', '钻石新品试吃', '高价值礼包'))
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  level_rank = VALUES(level_rank),
  min_growth_value = VALUES(min_growth_value),
  benefits_json = VALUES(benefits_json);

INSERT INTO crm_members (
  tenant_id, member_no, name, phone_hash, phone_mask, gender, level_id,
  source_channel, register_store_id, register_at, status, profile_json, last_active_at
)
VALUES
  (@tenant_id, 'M202606130021', '林晓然', SHA2('13800003026', 256), '138****3026', 'female',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'diamond'),
   '小程序商城', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-HZ-XH'),
   '2026-06-13 10:08:00', 'active', JSON_OBJECT('city', '杭州', 'age_band', '25-34'), '2026-06-15 14:20:00'),
  (@tenant_id, 'M202606120118', '周子墨', SHA2('18600007913', 256), '186****7913', 'male',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'gold'),
   '门店扫码', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-NB-YZ'),
   '2026-06-12 09:46:00', 'active', JSON_OBJECT('city', '宁波', 'age_band', '25-34'), '2026-06-15 13:10:00'),
  (@tenant_id, 'M202606110086', '陈安宁', SHA2('15700006088', 256), '157****6088', 'female',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'silver'),
   '公众号', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-WZ-LC'),
   '2026-06-11 12:15:00', 'to_wake', JSON_OBJECT('city', '温州', 'age_band', '35-44'), '2026-05-30 18:10:00'),
  (@tenant_id, 'M202606100035', '吴嘉言', SHA2('13900004251', 256), '139****4251', 'male',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'normal'),
   '员工邀请', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-HZ-BJ'),
   '2026-06-10 16:30:00', 'active', JSON_OBJECT('city', '杭州', 'age_band', '18-24'), '2026-06-14 11:06:00'),
  (@tenant_id, 'M202606090242', '沈清禾', SHA2('17700001638', 256), '177****1638', 'female',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'platinum'),
   '小程序商城', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-SX-YC'),
   '2026-06-09 19:38:00', 'frozen', JSON_OBJECT('city', '绍兴', 'age_band', '35-44'), '2026-06-14 18:21:00'),
  (@tenant_id, 'M202606080157', '许星遥', SHA2('15900008332', 256), '159****8332', 'female',
   (SELECT id FROM loyalty_membership_levels WHERE tenant_id = @tenant_id AND code = 'gold'),
   '门店扫码', (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-TZ-JJ'),
   '2026-06-08 08:22:00', 'active', JSON_OBJECT('city', '台州', 'age_band', '25-34'), '2026-06-15 09:05:00')
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  level_id = VALUES(level_id),
  status = VALUES(status),
  profile_json = VALUES(profile_json),
  last_active_at = VALUES(last_active_at);

INSERT INTO crm_member_metrics (
  member_id, tenant_id, total_spend, order_count, avg_order_amount,
  growth_value, contribution_score, last_order_at
)
VALUES
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606130021'), @tenant_id, 28640.00, 32, 895.00, 18800, 96, '2026-06-15 12:30:00'),
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606120118'), @tenant_id, 16730.00, 19, 880.53, 6200, 86, '2026-06-15 13:06:00'),
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606110086'), @tenant_id, 5210.00, 8, 651.25, 2500, 72, '2026-05-30 18:10:00'),
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606100035'), @tenant_id, 1680.00, 4, 420.00, 820, 55, '2026-06-14 11:06:00'),
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606090242'), @tenant_id, 19520.00, 21, 929.52, 9800, 89, '2026-06-14 19:38:00'),
  ((SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606080157'), @tenant_id, 15410.00, 18, 856.11, 5800, 82, '2026-06-08 17:12:00')
ON DUPLICATE KEY UPDATE
  total_spend = VALUES(total_spend),
  order_count = VALUES(order_count),
  avg_order_amount = VALUES(avg_order_amount),
  growth_value = VALUES(growth_value),
  contribution_score = VALUES(contribution_score),
  last_order_at = VALUES(last_order_at);

INSERT INTO crm_tags (tenant_id, name, category, color, enabled, coverage_count, rules_json)
VALUES
  (@tenant_id, '高价值会员', '价值标签', 'blue', TRUE, 18620, JSON_ARRAY(JSON_OBJECT('field', 'total_spend', 'op', '>=', 'value', 3000))),
  (@tenant_id, '待唤醒会员', '活跃标签', 'orange', TRUE, 26320, JSON_ARRAY(JSON_OBJECT('field', 'last_active_days', 'op', '>', 'value', 60))),
  (@tenant_id, '新品偏好', '偏好标签', 'purple', TRUE, 12580, JSON_ARRAY(JSON_OBJECT('field', 'product_category', 'op', 'contains', 'value', '新品'))),
  (@tenant_id, '价格敏感', '行为标签', 'green', TRUE, 8940, JSON_ARRAY(JSON_OBJECT('field', 'coupon_use_rate', 'op', '>=', 'value', 0.6))),
  (@tenant_id, '门店自提', '渠道标签', 'teal', FALSE, 34150, JSON_ARRAY(JSON_OBJECT('field', 'fulfillment', 'op', '=', 'value', 'store_pickup'))),
  (@tenant_id, '生日会员', '基础标签', 'pink', TRUE, 10246, JSON_ARRAY(JSON_OBJECT('field', 'birthday_month', 'op', '=', 'value', 'current')))
ON DUPLICATE KEY UPDATE
  category = VALUES(category),
  color = VALUES(color),
  enabled = VALUES(enabled),
  coverage_count = VALUES(coverage_count),
  rules_json = VALUES(rules_json);

INSERT INTO crm_segments (tenant_id, name, description, segment_type, rule_json, enabled, member_count, refreshed_at)
VALUES
  (@tenant_id, '高价值活跃会员', '近 90 天消费 ≥ 3000 元，且 30 天内有消费', 'dynamic', JSON_OBJECT('total_spend_90d', JSON_OBJECT('gte', 3000), 'active_days', JSON_OBJECT('lte', 30)), TRUE, 8342, NOW(3)),
  (@tenant_id, '低活跃待唤醒会员', '60 天未消费，历史消费次数 ≥ 3 次', 'dynamic', JSON_OBJECT('inactive_days', JSON_OBJECT('gte', 60), 'order_count', JSON_OBJECT('gte', 3)), TRUE, 6175, NOW(3)),
  (@tenant_id, '近 30 天新会员', '注册时间在近 30 天内的有效会员', 'system', JSON_OBJECT('register_days', JSON_OBJECT('lte', 30)), TRUE, 26843, NOW(3)),
  (@tenant_id, '门店重点维护会员', '由门店人工加入的重点跟进会员', 'static', JSON_OBJECT(), FALSE, 1256, NOW(3))
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  rule_json = VALUES(rule_json),
  enabled = VALUES(enabled),
  member_count = VALUES(member_count),
  refreshed_at = VALUES(refreshed_at);

INSERT INTO catalog_products (tenant_id, product_no, name, category, price, stock_qty, sales_qty, enabled)
VALUES
  (@tenant_id, 'P100286', '一鸣真鲜奶 950ml', '乳制品', 18.80, 2840, 12650, TRUE),
  (@tenant_id, 'P100315', '原味风味酸奶 200g', '酸奶', 8.90, 1680, 9432, TRUE),
  (@tenant_id, 'P100422', '经典奶香吐司', '烘焙', 12.80, 860, 7821, TRUE),
  (@tenant_id, 'P100507', '杨枝甘露酸奶杯', '新品', 16.90, 420, 3560, TRUE),
  (@tenant_id, 'P100198', '高钙低脂牛奶 250ml', '乳制品', 6.50, 0, 18460, FALSE)
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  category = VALUES(category),
  price = VALUES(price),
  stock_qty = VALUES(stock_qty),
  sales_qty = VALUES(sales_qty),
  enabled = VALUES(enabled);

INSERT INTO sales_orders (
  tenant_id, order_no, member_id, store_id, channel, status,
  item_count, total_amount, paid_amount, ordered_at, paid_at
)
VALUES
  (@tenant_id, 'SO202606150328', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606130021'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-HZ-XH'), '小程序商城', 'pending_ship', 6, 186.80, 186.80, '2026-06-15 14:28:00', '2026-06-15 14:28:00'),
  (@tenant_id, 'SO202606150296', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606120118'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-NB-YZ'), '门店收银', 'completed', 3, 98.50, 98.50, '2026-06-15 13:06:00', '2026-06-15 13:06:00'),
  (@tenant_id, 'SO202606150241', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606110086'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-WZ-LC'), '小程序商城', 'shipping', 8, 256.00, 256.00, '2026-06-15 11:42:00', '2026-06-15 11:42:00'),
  (@tenant_id, 'SO202606150187', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606100035'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-HZ-BJ'), '门店收银', 'completed', 2, 72.60, 72.60, '2026-06-15 10:15:00', '2026-06-15 10:15:00'),
  (@tenant_id, 'SO202606140936', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606090242'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-SX-YC'), '公众号商城', 'refunding', 9, 328.90, 328.90, '2026-06-14 19:38:00', '2026-06-14 19:38:00'),
  (@tenant_id, 'SO202606140821', (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606080157'), (SELECT id FROM org_stores WHERE tenant_id = @tenant_id AND store_code = 'S-TZ-JJ'), '小程序商城', 'pending_payment', 4, 126.00, 126.00, '2026-06-14 17:12:00', '2026-06-14 17:12:00')
ON DUPLICATE KEY UPDATE
  status = VALUES(status),
  item_count = VALUES(item_count),
  total_amount = VALUES(total_amount),
  paid_amount = VALUES(paid_amount),
  ordered_at = VALUES(ordered_at);

INSERT INTO marketing_coupons (
  tenant_id, code, name, coupon_type, face_value, threshold_amount,
  total_stock, issued_stock, valid_from, valid_to, status, rules_json
)
VALUES
  (@tenant_id, 'CPN-NEW-202606', '新会员首单满 59 减 10', 'amount', 10.00, 59.00, 20000, 4680, '2026-06-01 00:00:00', '2026-06-30 23:59:59', 'active', JSON_OBJECT('scene', 'new_member', 'channels', JSON_ARRAY('小程序商城', '门店收银'))),
  (@tenant_id, 'CPN-WAKE-202606', '沉睡会员唤醒满 99 减 20', 'amount', 20.00, 99.00, 8000, 2156, '2026-06-10 00:00:00', '2026-07-10 23:59:59', 'active', JSON_OBJECT('scene', 'wake_up', 'inactive_days', 60)),
  (@tenant_id, 'CPN-VIP-202606', '金钻会员 8 折新品券', 'discount', 8.00, 0.00, 5000, 1288, '2026-06-01 00:00:00', '2026-06-25 23:59:59', 'active', JSON_OBJECT('scene', 'vip', 'level_codes', JSON_ARRAY('gold', 'platinum', 'diamond')))
ON DUPLICATE KEY UPDATE
  name = VALUES(name),
  coupon_type = VALUES(coupon_type),
  face_value = VALUES(face_value),
  threshold_amount = VALUES(threshold_amount),
  total_stock = VALUES(total_stock),
  issued_stock = VALUES(issued_stock),
  valid_from = VALUES(valid_from),
  valid_to = VALUES(valid_to),
  status = VALUES(status),
  rules_json = VALUES(rules_json);

SET @coupon_new_id = (SELECT id FROM marketing_coupons WHERE tenant_id = @tenant_id AND code = 'CPN-NEW-202606');
SET @coupon_wake_id = (SELECT id FROM marketing_coupons WHERE tenant_id = @tenant_id AND code = 'CPN-WAKE-202606');
SET @coupon_vip_id = (SELECT id FROM marketing_coupons WHERE tenant_id = @tenant_id AND code = 'CPN-VIP-202606');

INSERT INTO marketing_coupon_grants (
  tenant_id, coupon_id, member_id, grant_no, status, issued_at, used_at, order_id
)
VALUES
  (@tenant_id, @coupon_vip_id, (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606130021'), 'CG202606150001', 'used', '2026-06-15 09:10:00', '2026-06-15 14:28:00', (SELECT id FROM sales_orders WHERE tenant_id = @tenant_id AND order_no = 'SO202606150328')),
  (@tenant_id, @coupon_new_id, (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606100035'), 'CG202606150002', 'issued', '2026-06-15 10:20:00', NULL, NULL),
  (@tenant_id, @coupon_wake_id, (SELECT id FROM crm_members WHERE tenant_id = @tenant_id AND member_no = 'M202606110086'), 'CG202606150003', 'issued', '2026-06-15 11:05:00', NULL, NULL)
ON DUPLICATE KEY UPDATE
  coupon_id = VALUES(coupon_id),
  member_id = VALUES(member_id),
  status = VALUES(status),
  issued_at = VALUES(issued_at),
  used_at = VALUES(used_at),
  order_id = VALUES(order_id);

SET @segment_high_value_id = (SELECT id FROM crm_segments WHERE tenant_id = @tenant_id AND name = '高价值活跃会员');
SET @segment_low_active_id = (SELECT id FROM crm_segments WHERE tenant_id = @tenant_id AND name = '低活跃待唤醒会员');
SET @segment_new_member_id = (SELECT id FROM crm_segments WHERE tenant_id = @tenant_id AND name = '近 30 天新会员');

INSERT INTO marketing_campaigns (
  tenant_id, name, campaign_type, target_segment_id, status, budget_amount,
  starts_at, ends_at, rules_json, metrics_json, created_by
)
SELECT
  @tenant_id, '6月会员日复购提升', 'coupon', @segment_high_value_id, 'running', 50000.00,
  '2026-06-01 00:00:00', '2026-06-30 23:59:59',
  JSON_OBJECT('coupon_code', 'CPN-VIP-202606', 'goal', 'repeat_purchase'),
  JSON_OBJECT('sent', 16820, 'converted', 2346, 'gmv', 386420.50),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '6月会员日复购提升'
);
UPDATE marketing_campaigns
SET campaign_type = 'coupon',
    target_segment_id = @segment_high_value_id,
    status = 'running',
    budget_amount = 50000.00,
    starts_at = '2026-06-01 00:00:00',
    ends_at = '2026-06-30 23:59:59',
    rules_json = JSON_OBJECT('coupon_code', 'CPN-VIP-202606', 'goal', 'repeat_purchase'),
    metrics_json = JSON_OBJECT('sent', 16820, 'converted', 2346, 'gmv', 386420.50),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '6月会员日复购提升';

INSERT INTO marketing_campaigns (
  tenant_id, name, campaign_type, target_segment_id, status, budget_amount,
  starts_at, ends_at, rules_json, metrics_json, created_by
)
SELECT
  @tenant_id, '沉睡会员7日唤醒', 'reach', @segment_low_active_id, 'scheduled', 18000.00,
  '2026-06-18 09:00:00', '2026-06-25 23:59:59',
  JSON_OBJECT('coupon_code', 'CPN-WAKE-202606', 'touch_channels', JSON_ARRAY('sms', 'wechat')),
  JSON_OBJECT('planned', 6175, 'sent', 0, 'converted', 0),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '沉睡会员7日唤醒'
);
UPDATE marketing_campaigns
SET campaign_type = 'reach',
    target_segment_id = @segment_low_active_id,
    status = 'scheduled',
    budget_amount = 18000.00,
    starts_at = '2026-06-18 09:00:00',
    ends_at = '2026-06-25 23:59:59',
    rules_json = JSON_OBJECT('coupon_code', 'CPN-WAKE-202606', 'touch_channels', JSON_ARRAY('sms', 'wechat')),
    metrics_json = JSON_OBJECT('planned', 6175, 'sent', 0, 'converted', 0),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '沉睡会员7日唤醒';

INSERT INTO marketing_campaigns (
  tenant_id, name, campaign_type, target_segment_id, status, budget_amount,
  starts_at, ends_at, rules_json, metrics_json, created_by
)
SELECT
  @tenant_id, '新会员首单转化', 'coupon', @segment_new_member_id, 'running', 26000.00,
  '2026-06-01 00:00:00', '2026-06-30 23:59:59',
  JSON_OBJECT('coupon_code', 'CPN-NEW-202606', 'goal', 'first_order'),
  JSON_OBJECT('sent', 26843, 'converted', 4128, 'conversion_rate', 0.1538),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '新会员首单转化'
);
UPDATE marketing_campaigns
SET campaign_type = 'coupon',
    target_segment_id = @segment_new_member_id,
    status = 'running',
    budget_amount = 26000.00,
    starts_at = '2026-06-01 00:00:00',
    ends_at = '2026-06-30 23:59:59',
    rules_json = JSON_OBJECT('coupon_code', 'CPN-NEW-202606', 'goal', 'first_order'),
    metrics_json = JSON_OBJECT('sent', 26843, 'converted', 4128, 'conversion_rate', 0.1538),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '新会员首单转化';

SET @campaign_member_day_id = (SELECT id FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '6月会员日复购提升');
SET @campaign_wake_id = (SELECT id FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '沉睡会员7日唤醒');
SET @campaign_new_member_id = (SELECT id FROM marketing_campaigns WHERE tenant_id = @tenant_id AND name = '新会员首单转化');

INSERT INTO marketing_reach_tasks (
  tenant_id, campaign_id, name, channel, target_segment_id, status,
  scheduled_at, payload_json, metrics_json, created_by
)
SELECT
  @tenant_id, @campaign_member_day_id, '会员日金钻客户企微提醒', 'wechat', @segment_high_value_id, 'done',
  '2026-06-15 10:00:00',
  JSON_OBJECT('template', 'member_day_vip', 'coupon_code', 'CPN-VIP-202606'),
  JSON_OBJECT('sent', 16820, 'delivered', 16408, 'clicked', 4216),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_reach_tasks WHERE tenant_id = @tenant_id AND name = '会员日金钻客户企微提醒'
);
UPDATE marketing_reach_tasks
SET campaign_id = @campaign_member_day_id,
    channel = 'wechat',
    target_segment_id = @segment_high_value_id,
    status = 'done',
    scheduled_at = '2026-06-15 10:00:00',
    payload_json = JSON_OBJECT('template', 'member_day_vip', 'coupon_code', 'CPN-VIP-202606'),
    metrics_json = JSON_OBJECT('sent', 16820, 'delivered', 16408, 'clicked', 4216),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '会员日金钻客户企微提醒';

INSERT INTO marketing_reach_tasks (
  tenant_id, campaign_id, name, channel, target_segment_id, status,
  scheduled_at, payload_json, metrics_json, created_by
)
SELECT
  @tenant_id, @campaign_wake_id, '沉睡会员短信唤醒首触达', 'sms', @segment_low_active_id, 'scheduled',
  '2026-06-18 09:00:00',
  JSON_OBJECT('template', 'wake_sms_01', 'coupon_code', 'CPN-WAKE-202606'),
  JSON_OBJECT('planned', 6175, 'sent', 0, 'clicked', 0),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_reach_tasks WHERE tenant_id = @tenant_id AND name = '沉睡会员短信唤醒首触达'
);
UPDATE marketing_reach_tasks
SET campaign_id = @campaign_wake_id,
    channel = 'sms',
    target_segment_id = @segment_low_active_id,
    status = 'scheduled',
    scheduled_at = '2026-06-18 09:00:00',
    payload_json = JSON_OBJECT('template', 'wake_sms_01', 'coupon_code', 'CPN-WAKE-202606'),
    metrics_json = JSON_OBJECT('planned', 6175, 'sent', 0, 'clicked', 0),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '沉睡会员短信唤醒首触达';

INSERT INTO marketing_reach_tasks (
  tenant_id, campaign_id, name, channel, target_segment_id, status,
  scheduled_at, payload_json, metrics_json, created_by
)
SELECT
  @tenant_id, @campaign_new_member_id, '新会员首单小程序订阅消息', 'mini_program', @segment_new_member_id, 'running',
  '2026-06-16 18:00:00',
  JSON_OBJECT('template', 'new_member_first_order', 'coupon_code', 'CPN-NEW-202606'),
  JSON_OBJECT('sent', 12680, 'delivered', 12420, 'converted', 1860),
  @admin_user_id
WHERE NOT EXISTS (
  SELECT 1 FROM marketing_reach_tasks WHERE tenant_id = @tenant_id AND name = '新会员首单小程序订阅消息'
);
UPDATE marketing_reach_tasks
SET campaign_id = @campaign_new_member_id,
    channel = 'mini_program',
    target_segment_id = @segment_new_member_id,
    status = 'running',
    scheduled_at = '2026-06-16 18:00:00',
    payload_json = JSON_OBJECT('template', 'new_member_first_order', 'coupon_code', 'CPN-NEW-202606'),
    metrics_json = JSON_OBJECT('sent', 12680, 'delivered', 12420, 'converted', 1860),
    created_by = @admin_user_id
WHERE tenant_id = @tenant_id AND name = '新会员首单小程序订阅消息';

INSERT INTO ai_claw_prompt_templates (tenant_id, scene, prompt, owner_user_id, use_count)
VALUES
  (@tenant_id, '增长复盘', '本月新增会员来源占比如何？', @admin_user_id, 128),
  (@tenant_id, '趋势追踪', '近 7 天新增趋势怎么样？', @admin_user_id, 96),
  (@tenant_id, '价值洞察', '高价值会员的消费特征是什么？', @admin_user_id, 84),
  (@tenant_id, '渠道质量', '哪些渠道带来的会员质量最高？', @admin_user_id, 72)
ON DUPLICATE KEY UPDATE use_count = VALUES(use_count), owner_user_id = VALUES(owner_user_id);

INSERT INTO ai_claw_insights (tenant_id, title, summary, tone, insight_type, source_json, priority)
VALUES
  (@tenant_id, '新增趋势上升', '本月新增会员 6,782 人，较上月 ↑ 12.31%，主要增长来自小程序商城。', 'green', 'growth', JSON_OBJECT('period', 'month'), 90),
  (@tenant_id, '高价值会员占比偏低', '高价值会员占 18.62%，低于行业均值 25%，建议加强会员分层运营。', 'orange', 'value', JSON_OBJECT('benchmark', 'industry'), 80),
  (@tenant_id, '会员活跃度下降', '低活跃会员占比 26.32%，较上周期 ↑ 3.18%，建议触达唤醒。', 'purple', 'activity', JSON_OBJECT('period', 'cycle'), 70)
ON DUPLICATE KEY UPDATE
  summary = VALUES(summary),
  tone = VALUES(tone),
  insight_type = VALUES(insight_type),
  source_json = VALUES(source_json),
  priority = VALUES(priority);

INSERT INTO ai_claw_suggestions (tenant_id, title, description, action_label, expected_impact, payload_json)
VALUES
  (@tenant_id, '针对重要发展会员', '推送成长型会员礼包，预计可提升银卡到金卡升级率 4.8%。', '发放优惠券', '4.8%', JSON_OBJECT('target', '重要发展会员')),
  (@tenant_id, '优化会员等级权益', '补强银卡 / 金卡权益激励，降低会员停留在低等级的时间。', '去配置', '6.2%', JSON_OBJECT('module', 'loyalty')),
  (@tenant_id, '沉睡会员唤醒计划', '按最后活跃时间和历史客单价分层触达，优先召回中高价值人群。', '创建分群', '9.1%', JSON_OBJECT('target', '沉睡会员'))
ON DUPLICATE KEY UPDATE
  description = VALUES(description),
  action_label = VALUES(action_label),
  expected_impact = VALUES(expected_impact),
  payload_json = VALUES(payload_json);

INSERT INTO wechat_accounts (tenant_id, account_type, app_id, name)
VALUES (@tenant_id, 'enterprise_wechat', 'wx-demo', '微智企业微信')
ON DUPLICATE KEY UPDATE name = VALUES(name);

SET @wechat_account_id = (
  SELECT id FROM wechat_accounts
  WHERE tenant_id = @tenant_id AND account_type = 'enterprise_wechat' AND app_id = 'wx-demo'
);

INSERT INTO wechat_conversations (
  tenant_id, account_id, external_id, conversation_type, title,
  pinned, unread_count, last_message_preview, last_message_at
)
VALUES
  (@tenant_id, @wechat_account_id, 'wechat-pay', 'chat', '微信支付', TRUE, 1, '关于支付通道和客户侧提示的咨询', '2026-05-13 15:00:00'),
  (@tenant_id, @wechat_account_id, 'yingyou', 'chat', '营优教育', TRUE, 1, '客户询问系统登录微信和客户端关系', '2026-05-13 15:40:00'),
  (@tenant_id, @wechat_account_id, 'henan-tel', 'chat', '河南电信', FALSE, 0, '5G 套餐活动接入和权益兑换确认', '2026-05-11 15:40:00'),
  (@tenant_id, @wechat_account_id, 'zz-card', 'group', '郑州市民卡', FALSE, 0, '社群活动物料已完成二次确认', '2026-05-08 15:40:00')
ON DUPLICATE KEY UPDATE
  title = VALUES(title),
  pinned = VALUES(pinned),
  unread_count = VALUES(unread_count),
  last_message_preview = VALUES(last_message_preview),
  last_message_at = VALUES(last_message_at);

INSERT INTO ops_system_parameters (tenant_id, param_key, value_json, description, updated_by)
VALUES
  (@tenant_id, 'member.phone_mask.enabled', JSON_EXTRACT('true', '$'), '会员手机号脱敏', @admin_user_id),
  (@tenant_id, 'order.auto_close_minutes', JSON_EXTRACT('30', '$'), '订单自动关闭时间', @admin_user_id),
  (@tenant_id, 'marketing.frequency_limit', JSON_OBJECT('sms_per_day', 2, 'wechat_per_day', 3), '营销任务频控', @admin_user_id)
ON DUPLICATE KEY UPDATE
  value_json = VALUES(value_json),
  description = VALUES(description),
  updated_by = VALUES(updated_by);

COMMIT;
