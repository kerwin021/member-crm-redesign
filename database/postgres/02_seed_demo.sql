-- Demo data aligned with the current React prototype.
-- Run while connected to database `member_crm`.

BEGIN;

WITH tenant AS (
  INSERT INTO app.tenants (code, name, brand_name, settings)
  VALUES ('ym-foods', '一鸣食品', '微智', '{"timezone":"Asia/Shanghai","currency":"CNY"}')
  ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name
  RETURNING id
),
org_root AS (
  INSERT INTO org.organizations (tenant_id, code, name, org_type)
  SELECT id, 'HQ', '一鸣食品总部', 'headquarters' FROM tenant
  ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name
  RETURNING id, tenant_id
),
admin_user AS (
  INSERT INTO iam.users (tenant_id, username, display_name, email, status)
  SELECT tenant_id, 'admin', '超级管理员', 'admin@example.com', 'active' FROM org_root
  ON CONFLICT (tenant_id, username) DO UPDATE SET display_name = EXCLUDED.display_name
  RETURNING id, tenant_id
)
INSERT INTO org.employees (tenant_id, user_id, organization_id, employee_no, name, title, employment_status, joined_on)
SELECT admin_user.tenant_id, admin_user.id, org_root.id, 'E0001', '超级管理员', '系统管理员', 'active', DATE '2026-01-01'
FROM admin_user
JOIN org_root ON org_root.tenant_id = admin_user.tenant_id
ON CONFLICT (tenant_id, employee_no) DO UPDATE SET name = EXCLUDED.name;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO org.stores (tenant_id, store_code, name, city, address, service_status, opened_on)
SELECT t.id, item.store_code, item.name, item.city, item.address, 'open', item.opened_on
FROM t
CROSS JOIN (VALUES
  ('S-HZ-XH', '杭州西湖店', '杭州', '杭州市西湖区会员路 1 号', DATE '2023-03-01'),
  ('S-NB-YZ', '宁波鄞州店', '宁波', '宁波市鄞州区云门路 6 号', DATE '2023-05-12'),
  ('S-WZ-LC', '温州鹿城店', '温州', '温州市鹿城区晨光路 8 号', DATE '2023-08-20'),
  ('S-HZ-BJ', '杭州滨江店', '杭州', '杭州市滨江区星河路 9 号', DATE '2024-02-18'),
  ('S-SX-YC', '绍兴越城店', '绍兴', '绍兴市越城区环城路 12 号', DATE '2024-04-16'),
  ('S-TZ-JJ', '台州椒江店', '台州', '台州市椒江区海门路 16 号', DATE '2024-06-08')
) AS item(store_code, name, city, address, opened_on)
ON CONFLICT (tenant_id, store_code) DO UPDATE SET name = EXCLUDED.name, city = EXCLUDED.city;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO loyalty.membership_levels (tenant_id, code, name, rank, min_growth_value, benefits)
SELECT t.id, item.code, item.name, item.rank, item.min_growth_value, item.benefits::jsonb
FROM t
CROSS JOIN (VALUES
  ('normal', '普通卡', 1, 0, '["会员积分"]'),
  ('silver', '银卡', 2, 1000, '["会员积分","会员日专享价"]'),
  ('gold', '金卡', 3, 3000, '["会员积分","生日月双倍积分"]'),
  ('platinum', '白金卡', 4, 8000, '["专属客服","新品试吃"]'),
  ('diamond', '钻石卡', 5, 15000, '["专属客服","钻石新品试吃","高价值礼包"]')
) AS item(code, name, rank, min_growth_value, benefits)
ON CONFLICT (tenant_id, code) DO UPDATE SET name = EXCLUDED.name, rank = EXCLUDED.rank;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO crm.members (tenant_id, member_no, name, phone_hash, phone_mask, gender, level_id, source_channel, register_store_id, register_at, status, last_active_at, profile)
SELECT t.id, item.member_no, item.name, encode(digest(item.phone_plain, 'sha256'), 'hex'), item.phone_mask, item.gender,
       level.id, item.source_channel, store.id, item.register_at::timestamptz, item.status, item.last_active_at::timestamptz, item.profile::jsonb
FROM t
CROSS JOIN (VALUES
  ('M202606130021', '林晓然', '13800003026', '138****3026', 'female', 'diamond', '小程序商城', 'S-HZ-XH', '2026-06-13 10:08+08', 'active', '2026-06-15 14:20+08', '{"city":"杭州","age_band":"25-34"}'),
  ('M202606120118', '周子墨', '18600007913', '186****7913', 'male', 'gold', '门店扫码', 'S-NB-YZ', '2026-06-12 09:46+08', 'active', '2026-06-15 13:10+08', '{"city":"宁波","age_band":"25-34"}'),
  ('M202606110086', '陈安宁', '15700006088', '157****6088', 'female', 'silver', '公众号', 'S-WZ-LC', '2026-06-11 12:15+08', 'to_wake', '2026-05-30 18:10+08', '{"city":"温州","age_band":"35-44"}'),
  ('M202606100035', '吴嘉言', '13900004251', '139****4251', 'male', 'normal', '员工邀请', 'S-HZ-BJ', '2026-06-10 16:30+08', 'active', '2026-06-14 11:06+08', '{"city":"杭州","age_band":"18-24"}'),
  ('M202606090242', '沈清禾', '17700001638', '177****1638', 'female', 'platinum', '小程序商城', 'S-SX-YC', '2026-06-09 19:38+08', 'frozen', '2026-06-14 18:21+08', '{"city":"绍兴","age_band":"35-44"}'),
  ('M202606080157', '许星遥', '15900008332', '159****8332', 'female', 'gold', '门店扫码', 'S-TZ-JJ', '2026-06-08 08:22+08', 'active', '2026-06-15 09:05+08', '{"city":"台州","age_band":"25-34"}')
) AS item(member_no, name, phone_plain, phone_mask, gender, level_code, source_channel, store_code, register_at, status, last_active_at, profile)
JOIN loyalty.membership_levels level ON level.tenant_id = t.id AND level.code = item.level_code
LEFT JOIN org.stores store ON store.tenant_id = t.id AND store.store_code = item.store_code
ON CONFLICT (tenant_id, member_no) DO UPDATE SET name = EXCLUDED.name, level_id = EXCLUDED.level_id, status = EXCLUDED.status;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO crm.member_metrics (member_id, tenant_id, total_spend, order_count, avg_order_amount, growth_value, contribution_score, last_order_at)
SELECT member.id, t.id, item.total_spend, item.order_count, item.avg_order_amount, item.growth_value, item.score, item.last_order_at::timestamptz
FROM t
JOIN (VALUES
  ('M202606130021', 28640.00, 32, 895.00, 18800, 96, '2026-06-15 12:30+08'),
  ('M202606120118', 16730.00, 19, 880.53, 6200, 86, '2026-06-15 13:06+08'),
  ('M202606110086', 5210.00, 8, 651.25, 2500, 72, '2026-05-30 18:10+08'),
  ('M202606100035', 1680.00, 4, 420.00, 820, 55, '2026-06-14 11:06+08'),
  ('M202606090242', 19520.00, 21, 929.52, 9800, 89, '2026-06-14 19:38+08'),
  ('M202606080157', 15410.00, 18, 856.11, 5800, 82, '2026-06-08 17:12+08')
) AS item(member_no, total_spend, order_count, avg_order_amount, growth_value, score, last_order_at)
JOIN crm.members member ON member.tenant_id = t.id AND member.member_no = item.member_no
ON CONFLICT (member_id) DO UPDATE
SET total_spend = EXCLUDED.total_spend,
    order_count = EXCLUDED.order_count,
    avg_order_amount = EXCLUDED.avg_order_amount,
    growth_value = EXCLUDED.growth_value,
    contribution_score = EXCLUDED.contribution_score,
    last_order_at = EXCLUDED.last_order_at;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO crm.tags (tenant_id, name, category, color, enabled, coverage_count, rules)
SELECT t.id, item.name, item.category, item.color, item.enabled, item.coverage_count, item.rules::jsonb
FROM t
CROSS JOIN (VALUES
  ('高价值会员', '价值标签', 'blue', true, 18620, '[{"field":"total_spend","op":">=","value":3000}]'),
  ('待唤醒会员', '活跃标签', 'orange', true, 26320, '[{"field":"last_active_days","op":">","value":60}]'),
  ('新品偏好', '偏好标签', 'purple', true, 12580, '[{"field":"product_category","op":"contains","value":"新品"}]'),
  ('价格敏感', '行为标签', 'green', true, 8940, '[{"field":"coupon_use_rate","op":">=","value":0.6}]'),
  ('门店自提', '渠道标签', 'teal', false, 34150, '[{"field":"fulfillment","op":"=","value":"store_pickup"}]'),
  ('生日会员', '基础标签', 'pink', true, 10246, '[{"field":"birthday_month","op":"=","value":"current"}]')
) AS item(name, category, color, enabled, coverage_count, rules)
ON CONFLICT (tenant_id, name) DO UPDATE SET coverage_count = EXCLUDED.coverage_count, enabled = EXCLUDED.enabled;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO crm.segments (tenant_id, name, description, segment_type, rule_json, enabled, member_count, refreshed_at)
SELECT t.id, item.name, item.description, item.segment_type, item.rule_json::jsonb, item.enabled, item.member_count, now()
FROM t
CROSS JOIN (VALUES
  ('高价值活跃会员', '近 90 天消费 ≥ 3000 元，且 30 天内有消费', 'dynamic', '{"total_spend_90d":{"gte":3000},"active_days":{"lte":30}}', true, 8342),
  ('低活跃待唤醒会员', '60 天未消费，历史消费次数 ≥ 3 次', 'dynamic', '{"inactive_days":{"gte":60},"order_count":{"gte":3}}', true, 6175),
  ('近 30 天新会员', '注册时间在近 30 天内的有效会员', 'system', '{"register_days":{"lte":30}}', true, 26843),
  ('门店重点维护会员', '由门店人工加入的重点跟进会员', 'static', '{}', false, 1256)
) AS item(name, description, segment_type, rule_json, enabled, member_count)
ON CONFLICT (tenant_id, name) DO UPDATE SET member_count = EXCLUDED.member_count, enabled = EXCLUDED.enabled;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO catalog.products (tenant_id, product_no, name, category, price, stock_qty, sales_qty, enabled)
SELECT t.id, item.product_no, item.name, item.category, item.price, item.stock_qty, item.sales_qty, item.enabled
FROM t
CROSS JOIN (VALUES
  ('P100286', '一鸣真鲜奶 950ml', '乳制品', 18.80, 2840, 12650, true),
  ('P100315', '原味风味酸奶 200g', '酸奶', 8.90, 1680, 9432, true),
  ('P100422', '经典奶香吐司', '烘焙', 12.80, 860, 7821, true),
  ('P100507', '杨枝甘露酸奶杯', '新品', 16.90, 420, 3560, true),
  ('P100198', '高钙低脂牛奶 250ml', '乳制品', 6.50, 0, 18460, false)
) AS item(product_no, name, category, price, stock_qty, sales_qty, enabled)
ON CONFLICT (tenant_id, product_no) DO UPDATE SET price = EXCLUDED.price, stock_qty = EXCLUDED.stock_qty, enabled = EXCLUDED.enabled;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO sales.orders (tenant_id, order_no, member_id, store_id, channel, status, item_count, total_amount, paid_amount, ordered_at, paid_at)
SELECT t.id, item.order_no, member.id, store.id, item.channel, item.status, item.item_count, item.total_amount, item.total_amount, item.ordered_at::timestamptz, item.ordered_at::timestamptz
FROM t
JOIN (VALUES
  ('SO202606150328', 'M202606130021', 'S-HZ-XH', '小程序商城', 'pending_ship', 6, 186.80, '2026-06-15 14:28+08'),
  ('SO202606150296', 'M202606120118', 'S-NB-YZ', '门店收银', 'completed', 3, 98.50, '2026-06-15 13:06+08'),
  ('SO202606150241', 'M202606110086', 'S-WZ-LC', '小程序商城', 'shipping', 8, 256.00, '2026-06-15 11:42+08'),
  ('SO202606150187', 'M202606100035', 'S-HZ-BJ', '门店收银', 'completed', 2, 72.60, '2026-06-15 10:15+08'),
  ('SO202606140936', 'M202606090242', 'S-SX-YC', '公众号商城', 'refunding', 9, 328.90, '2026-06-14 19:38+08'),
  ('SO202606140821', 'M202606080157', 'S-TZ-JJ', '小程序商城', 'pending_payment', 4, 126.00, '2026-06-14 17:12+08')
) AS item(order_no, member_no, store_code, channel, status, item_count, total_amount, ordered_at)
JOIN crm.members member ON member.tenant_id = t.id AND member.member_no = item.member_no
LEFT JOIN org.stores store ON store.tenant_id = t.id AND store.store_code = item.store_code
ON CONFLICT (tenant_id, order_no) DO UPDATE SET status = EXCLUDED.status, total_amount = EXCLUDED.total_amount;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods'), admin_user AS (SELECT id, tenant_id FROM iam.users WHERE username = 'admin')
INSERT INTO ai.claw_prompt_templates (tenant_id, scene, prompt, owner_user_id, use_count)
SELECT t.id, item.scene, item.prompt, admin_user.id, item.use_count
FROM t
JOIN admin_user ON admin_user.tenant_id = t.id
CROSS JOIN (VALUES
  ('增长复盘', '本月新增会员来源占比如何？', 128),
  ('趋势追踪', '近 7 天新增趋势怎么样？', 96),
  ('价值洞察', '高价值会员的消费特征是什么？', 84),
  ('渠道质量', '哪些渠道带来的会员质量最高？', 72)
) AS item(scene, prompt, use_count)
ON CONFLICT (tenant_id, scene, prompt) DO UPDATE SET use_count = EXCLUDED.use_count;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO ai.claw_insights (tenant_id, title, summary, tone, insight_type, source_json, priority)
SELECT t.id, item.title, item.summary, item.tone, item.insight_type, item.source_json::jsonb, item.priority
FROM t
CROSS JOIN (VALUES
  ('新增趋势上升', '本月新增会员 6,782 人，较上月 ↑ 12.31%，主要增长来自小程序商城。', 'green', 'growth', '{"period":"month"}', 90),
  ('高价值会员占比偏低', '高价值会员占 18.62%，低于行业均值 25%，建议加强会员分层运营。', 'orange', 'value', '{"benchmark":"industry"}', 80),
  ('会员活跃度下降', '低活跃会员占比 26.32%，较上周期 ↑ 3.18%，建议触达唤醒。', 'purple', 'activity', '{"period":"cycle"}', 70)
) AS item(title, summary, tone, insight_type, source_json, priority)
ON CONFLICT (tenant_id, title) DO UPDATE
SET summary = EXCLUDED.summary,
    tone = EXCLUDED.tone,
    insight_type = EXCLUDED.insight_type,
    source_json = EXCLUDED.source_json,
    priority = EXCLUDED.priority;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO ai.claw_suggestions (tenant_id, title, description, action_label, expected_impact, payload)
SELECT t.id, item.title, item.description, item.action_label, item.expected_impact, item.payload::jsonb
FROM t
CROSS JOIN (VALUES
  ('针对重要发展会员', '推送成长型会员礼包，预计可提升银卡到金卡升级率 4.8%。', '发放优惠券', '4.8%', '{"target":"重要发展会员"}'),
  ('优化会员等级权益', '补强银卡 / 金卡权益激励，降低会员停留在低等级的时间。', '去配置', '6.2%', '{"module":"loyalty"}'),
  ('沉睡会员唤醒计划', '按最后活跃时间和历史客单价分层触达，优先召回中高价值人群。', '创建分群', '9.1%', '{"target":"沉睡会员"}')
) AS item(title, description, action_label, expected_impact, payload)
ON CONFLICT (tenant_id, title) DO UPDATE
SET description = EXCLUDED.description,
    action_label = EXCLUDED.action_label,
    expected_impact = EXCLUDED.expected_impact,
    payload = EXCLUDED.payload;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods')
INSERT INTO wechat.accounts (tenant_id, account_type, app_id, name)
SELECT id, 'enterprise_wechat', 'wx-demo', '微智企业微信' FROM t
ON CONFLICT (tenant_id, account_type, app_id) DO UPDATE SET name = EXCLUDED.name;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods'), acct AS (SELECT id, tenant_id FROM wechat.accounts WHERE name = '微智企业微信' LIMIT 1)
INSERT INTO wechat.conversations (tenant_id, account_id, external_id, conversation_type, title, pinned, unread_count, last_message_preview, last_message_at)
SELECT t.id, acct.id, item.external_id, item.conversation_type, item.title, item.pinned, item.unread_count, item.preview, item.last_message_at::timestamptz
FROM t
JOIN acct ON acct.tenant_id = t.id
CROSS JOIN (VALUES
  ('wechat-pay', 'chat', '微信支付', true, 1, '关于支付通道和客户侧提示的咨询', '2026-05-13 15:00+08'),
  ('yingyou', 'chat', '营优教育', true, 1, '客户询问系统登录微信和客户端关系', '2026-05-13 15:40+08'),
  ('henan-tel', 'chat', '河南电信', false, 0, '5G 套餐活动接入和权益兑换确认', '2026-05-11 15:40+08'),
  ('zz-card', 'group', '郑州市民卡', false, 0, '社群活动物料已完成二次确认', '2026-05-08 15:40+08')
) AS item(external_id, conversation_type, title, pinned, unread_count, preview, last_message_at)
ON CONFLICT (tenant_id, account_id, external_id) DO UPDATE
SET title = EXCLUDED.title,
    pinned = EXCLUDED.pinned,
    unread_count = EXCLUDED.unread_count,
    last_message_preview = EXCLUDED.last_message_preview,
    last_message_at = EXCLUDED.last_message_at;

WITH t AS (SELECT id FROM app.tenants WHERE code = 'ym-foods'), admin_user AS (SELECT id, tenant_id FROM iam.users WHERE username = 'admin')
INSERT INTO ops.system_parameters (tenant_id, key, value, description, updated_by)
SELECT t.id, item.key, item.value::jsonb, item.description, admin_user.id
FROM t
JOIN admin_user ON admin_user.tenant_id = t.id
CROSS JOIN (VALUES
  ('member.phone_mask.enabled', 'true', '会员手机号脱敏'),
  ('order.auto_close_minutes', '30', '订单自动关闭时间'),
  ('marketing.frequency_limit', '{"sms_per_day":2,"wechat_per_day":3}', '营销任务频控')
) AS item(key, value, description)
ON CONFLICT (tenant_id, key) DO UPDATE SET value = EXCLUDED.value;

COMMIT;
