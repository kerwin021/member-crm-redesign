-- Detail data for the pages that need relational records beyond the summary seed.
-- This migration is idempotent and only adds the project's demo baseline when the
-- corresponding business record does not already exist.

SET NAMES utf8mb4;
SET time_zone = '+08:00';

START TRANSACTION;

SET @tenant_id = (SELECT id FROM app_tenants WHERE code = 'ym-foods' LIMIT 1);
SET @admin_user_id = (SELECT id FROM iam_users WHERE tenant_id = @tenant_id AND username = 'admin' LIMIT 1);
SET @org_root_id = (SELECT id FROM org_organizations WHERE tenant_id = @tenant_id AND code = 'HQ' LIMIT 1);
SET @wechat_account_id = (SELECT id FROM wechat_accounts WHERE tenant_id = @tenant_id ORDER BY id LIMIT 1);

-- Member tags, segment membership and a real activity trail.
INSERT INTO crm_member_tags (tenant_id, member_id, tag_id, source, assigned_by, assigned_at)
SELECT @tenant_id, m.id, t.id, 'rule', @admin_user_id, '2026-06-15 14:22:00'
FROM crm_members m JOIN crm_tags t ON t.tenant_id = @tenant_id AND t.name = '高价值会员'
WHERE m.tenant_id = @tenant_id AND m.member_no IN ('M202606130021', 'M202606120118', 'M202606090242')
ON DUPLICATE KEY UPDATE source = VALUES(source), assigned_by = VALUES(assigned_by), assigned_at = VALUES(assigned_at);

INSERT INTO crm_member_tags (tenant_id, member_id, tag_id, source, assigned_by, assigned_at)
SELECT @tenant_id, m.id, t.id, 'manual', @admin_user_id, '2026-06-14 10:15:00'
FROM crm_members m JOIN crm_tags t ON t.tenant_id = @tenant_id AND t.name = '待唤醒会员'
WHERE m.tenant_id = @tenant_id AND m.member_no IN ('M202606110086', 'M202606090242')
ON DUPLICATE KEY UPDATE source = VALUES(source), assigned_by = VALUES(assigned_by), assigned_at = VALUES(assigned_at);

INSERT INTO crm_member_tags (tenant_id, member_id, tag_id, source, assigned_by, assigned_at)
SELECT @tenant_id, m.id, t.id, 'manual', @admin_user_id, '2026-06-13 09:20:00'
FROM crm_members m JOIN crm_tags t ON t.tenant_id = @tenant_id AND t.name = '生日会员'
WHERE m.tenant_id = @tenant_id AND m.member_no IN ('M202606130021', 'M202606100035')
ON DUPLICATE KEY UPDATE source = VALUES(source), assigned_by = VALUES(assigned_by), assigned_at = VALUES(assigned_at);

INSERT IGNORE INTO crm_segment_members (segment_id, member_id, joined_at)
SELECT s.id, m.id, '2026-06-15 09:00:00'
FROM crm_segments s JOIN crm_members m ON m.tenant_id = @tenant_id
WHERE s.tenant_id = @tenant_id AND s.name = '门店重点维护会员'
  AND m.member_no IN ('M202606130021', 'M202606120118', 'M202606110086', 'M202606100035');

INSERT INTO crm_member_logs (tenant_id, member_id, action, detail, operator_user_id, channel, event_at, metadata_json)
SELECT @tenant_id, m.id, '会员分组', '加入门店重点维护会员分组', @admin_user_id, '运营工作台', '2026-06-15 09:00:00', JSON_OBJECT('segment', '门店重点维护会员')
FROM crm_members m
WHERE m.tenant_id = @tenant_id AND m.member_no = 'M202606130021'
  AND NOT EXISTS (SELECT 1 FROM crm_member_logs l WHERE l.tenant_id = @tenant_id AND l.member_id = m.id AND l.action = '会员分组' AND l.event_at = '2026-06-15 09:00:00');

INSERT INTO crm_member_logs (tenant_id, member_id, action, detail, operator_user_id, channel, event_at, metadata_json)
SELECT @tenant_id, m.id, '标签变更', '新增高价值会员、生日会员标签', @admin_user_id, '会员运营', '2026-06-15 10:30:00', JSON_OBJECT('tags', JSON_ARRAY('高价值会员', '生日会员'))
FROM crm_members m
WHERE m.tenant_id = @tenant_id AND m.member_no = 'M202606130021'
  AND NOT EXISTS (SELECT 1 FROM crm_member_logs l WHERE l.tenant_id = @tenant_id AND l.member_id = m.id AND l.action = '标签变更' AND l.event_at = '2026-06-15 10:30:00');

INSERT INTO crm_member_logs (tenant_id, member_id, action, detail, operator_user_id, channel, event_at, metadata_json)
SELECT @tenant_id, m.id, '订单完成', '完成订单 SO202606150296，累计消费 98.50 元', @admin_user_id, '门店收银', '2026-06-15 13:08:00', JSON_OBJECT('orderNo', 'SO202606150296', 'amount', 98.50)
FROM crm_members m
WHERE m.tenant_id = @tenant_id AND m.member_no = 'M202606120118'
  AND NOT EXISTS (SELECT 1 FROM crm_member_logs l WHERE l.tenant_id = @tenant_id AND l.member_id = m.id AND l.action = '订单完成' AND l.event_at = '2026-06-15 13:08:00');

-- Order lines and after-sales data used by order detail views.
INSERT INTO sales_order_items (order_id, product_id, product_name, unit_price, quantity, line_amount)
SELECT o.id, p.id, p.name, p.price, 1, p.price
FROM sales_orders o JOIN catalog_products p ON p.tenant_id = @tenant_id AND p.product_no = 'P100286'
WHERE o.tenant_id = @tenant_id AND o.order_no = 'SO202606150328'
  AND NOT EXISTS (SELECT 1 FROM sales_order_items i WHERE i.order_id = o.id AND i.product_id = p.id);

INSERT INTO sales_order_items (order_id, product_id, product_name, unit_price, quantity, line_amount)
SELECT o.id, p.id, p.name, p.price, 1, p.price
FROM sales_orders o JOIN catalog_products p ON p.tenant_id = @tenant_id AND p.product_no = 'P100315'
WHERE o.tenant_id = @tenant_id AND o.order_no = 'SO202606150296'
  AND NOT EXISTS (SELECT 1 FROM sales_order_items i WHERE i.order_id = o.id AND i.product_id = p.id);

INSERT INTO sales_order_items (order_id, product_id, product_name, unit_price, quantity, line_amount)
SELECT o.id, p.id, p.name, 2.90, 3, 8.70
FROM sales_orders o JOIN catalog_products p ON p.tenant_id = @tenant_id AND p.product_no = 'P100315'
WHERE o.tenant_id = @tenant_id AND o.order_no = 'SO202606150241'
  AND NOT EXISTS (SELECT 1 FROM sales_order_items i WHERE i.order_id = o.id AND i.product_id = p.id);

INSERT INTO sales_order_items (order_id, product_id, product_name, unit_price, quantity, line_amount)
SELECT o.id, p.id, p.name, p.price, 2, p.price * 2
FROM sales_orders o JOIN catalog_products p ON p.tenant_id = @tenant_id AND p.product_no = 'P100422'
WHERE o.tenant_id = @tenant_id AND o.order_no = 'SO202606150187'
  AND NOT EXISTS (SELECT 1 FROM sales_order_items i WHERE i.order_id = o.id AND i.product_id = p.id);

INSERT INTO sales_refunds (tenant_id, order_id, refund_no, amount, reason, status, requested_by, requested_at)
SELECT @tenant_id, o.id, 'RF202606140001', 32.80, '商品破损，申请部分退款', 'approved', @admin_user_id, '2026-06-15 09:40:00'
FROM sales_orders o
WHERE o.tenant_id = @tenant_id AND o.order_no = 'SO202606140936'
  AND NOT EXISTS (SELECT 1 FROM sales_refunds r WHERE r.tenant_id = @tenant_id AND r.refund_no = 'RF202606140001');

-- Loyalty accounts, ledger, growth rules, benefits and mall inventory.
INSERT INTO loyalty_points_accounts (member_id, tenant_id, available_points, frozen_points, lifetime_points)
SELECT m.id, @tenant_id,
       CASE m.member_no WHEN 'M202606130021' THEN 2864 WHEN 'M202606120118' THEN 1673 WHEN 'M202606110086' THEN 521 ELSE 168 END,
       0,
       CASE m.member_no WHEN 'M202606130021' THEN 2864 WHEN 'M202606120118' THEN 1673 WHEN 'M202606110086' THEN 521 ELSE 168 END
FROM crm_members m
WHERE m.tenant_id = @tenant_id
ON DUPLICATE KEY UPDATE available_points = VALUES(available_points), lifetime_points = VALUES(lifetime_points);

INSERT INTO loyalty_points_ledger (tenant_id, member_id, biz_type, biz_id, points_delta, balance_after, description, occurred_at)
SELECT @tenant_id, m.id, 'order_reward', o.id, 186, 2864, '订单消费奖励积分', '2026-06-15 12:30:00'
FROM crm_members m JOIN sales_orders o ON o.tenant_id = @tenant_id AND o.order_no = 'SO202606150328'
WHERE m.tenant_id = @tenant_id AND m.member_no = 'M202606130021'
  AND NOT EXISTS (SELECT 1 FROM loyalty_points_ledger l WHERE l.member_id = m.id AND l.biz_type = 'order_reward' AND l.biz_id = o.id);

INSERT INTO loyalty_growth_rules (tenant_id, name, event_type, growth_value, enabled, rule_json)
SELECT @tenant_id, '消费满 100 元', 'order_paid', 100, 1, JSON_OBJECT('minAmount', 100, 'unit', 'CNY')
WHERE NOT EXISTS (SELECT 1 FROM loyalty_growth_rules WHERE tenant_id = @tenant_id AND name = '消费满 100 元');

INSERT INTO loyalty_growth_rules (tenant_id, name, event_type, growth_value, enabled, rule_json)
SELECT @tenant_id, '完善会员资料', 'profile_completed', 200, 1, JSON_OBJECT('requiredFields', JSON_ARRAY('birthday', 'city'))
WHERE NOT EXISTS (SELECT 1 FROM loyalty_growth_rules WHERE tenant_id = @tenant_id AND name = '完善会员资料');

INSERT INTO loyalty_member_benefits (tenant_id, level_id, name, benefit_type, quota_json, enabled)
SELECT @tenant_id, l.id, CONCAT(l.name, '会员日专享价'), 'discount', JSON_OBJECT('discount', CASE l.code WHEN 'gold' THEN 0.95 WHEN 'platinum' THEN 0.9 ELSE 0.88 END), 1
FROM loyalty_membership_levels l
WHERE l.tenant_id = @tenant_id
  AND NOT EXISTS (SELECT 1 FROM loyalty_member_benefits b WHERE b.tenant_id = @tenant_id AND b.name = CONCAT(l.name, '会员日专享价'));

INSERT INTO loyalty_mall_items (tenant_id, sku_no, name, points_price, stock_qty, enabled, metadata_json)
VALUES
  (@tenant_id, 'LM-GIFT-001', '新品试吃礼包', 1200, 86, 1, JSON_OBJECT('category', '新品体验', 'validDays', 30)),
  (@tenant_id, 'LM-GIFT-002', '门店咖啡兑换券', 800, 230, 1, JSON_OBJECT('category', '到店权益', 'validDays', 60)),
  (@tenant_id, 'LM-GIFT-003', '会员专属保温杯', 3200, 42, 1, JSON_OBJECT('category', '实物礼品', 'validDays', 90))
ON DUPLICATE KEY UPDATE name = VALUES(name), points_price = VALUES(points_price), stock_qty = VALUES(stock_qty), metadata_json = VALUES(metadata_json);

-- WeChat operations: auto replies, communities and moments.
INSERT INTO wechat_auto_reply_rules (tenant_id, name, keywords_json, reply_content, enabled, priority)
SELECT @tenant_id, '会员权益咨询', JSON_ARRAY('会员权益', '积分', '等级'), '您好，回复“积分”可查询当前积分，回复“升级”可查看下一等级权益。', 1, 100
WHERE NOT EXISTS (SELECT 1 FROM wechat_auto_reply_rules WHERE tenant_id = @tenant_id AND name = '会员权益咨询');

INSERT INTO wechat_auto_reply_rules (tenant_id, name, keywords_json, reply_content, enabled, priority)
SELECT @tenant_id, '门店地址查询', JSON_ARRAY('门店', '地址', '营业时间'), '已为您准备附近门店信息，请发送所在城市，我们会推荐最近的门店。', 1, 90
WHERE NOT EXISTS (SELECT 1 FROM wechat_auto_reply_rules WHERE tenant_id = @tenant_id AND name = '门店地址查询');

INSERT INTO wechat_community_groups (tenant_id, account_id, group_no, name, owner_user_id, member_count, active_status, tags_json)
SELECT @tenant_id, @wechat_account_id, 'WXG-HZ-001', '杭州高价值会员群', @admin_user_id, 386, 'active', JSON_ARRAY('高价值会员', '杭州', '新品内测')
WHERE NOT EXISTS (SELECT 1 FROM wechat_community_groups WHERE tenant_id = @tenant_id AND group_no = 'WXG-HZ-001');

INSERT INTO wechat_community_groups (tenant_id, account_id, group_no, name, owner_user_id, member_count, active_status, tags_json)
SELECT @tenant_id, @wechat_account_id, 'WXG-NB-002', '宁波新品体验群', @admin_user_id, 218, 'active', JSON_ARRAY('新品偏好', '宁波')
WHERE NOT EXISTS (SELECT 1 FROM wechat_community_groups WHERE tenant_id = @tenant_id AND group_no = 'WXG-NB-002');

INSERT INTO wechat_moments_posts (tenant_id, account_id, title, content, media_urls_json, status, scheduled_at, published_at, metrics_json, created_by)
SELECT @tenant_id, @wechat_account_id, '夏日新品试吃招募', '本周五至周日，邀请高价值会员到店体验夏日新品，完成反馈即可领取积分。', JSON_ARRAY(), 'published', '2026-06-13 09:00:00', '2026-06-13 09:00:00', JSON_OBJECT('views', 26840, 'likes', 1256, 'comments', 86), @admin_user_id
WHERE NOT EXISTS (SELECT 1 FROM wechat_moments_posts WHERE tenant_id = @tenant_id AND title = '夏日新品试吃招募');

INSERT INTO wechat_moments_posts (tenant_id, account_id, title, content, media_urls_json, status, scheduled_at, metrics_json, created_by)
SELECT @tenant_id, @wechat_account_id, '会员日权益预告', '下周会员日将开放双倍积分和指定商品专享价，敬请关注。', JSON_ARRAY(), 'scheduled', '2026-06-20 10:00:00', JSON_OBJECT('estimatedReach', 18620), @admin_user_id
WHERE NOT EXISTS (SELECT 1 FROM wechat_moments_posts WHERE tenant_id = @tenant_id AND title = '会员日权益预告');

-- SCRM contacts, groups, materials and group message tasks.
INSERT INTO scrm_contacts (tenant_id, member_id, external_user_id, name, owner_employee_id, follow_status, tags_json, profile_json)
SELECT @tenant_id, m.id, CONCAT('wx_contact_', m.member_no), m.name, e.id, 'following', JSON_ARRAY('高价值会员'), m.profile_json
FROM crm_members m JOIN org_employees e ON e.tenant_id = @tenant_id AND e.employee_no = 'E0001'
WHERE m.tenant_id = @tenant_id AND m.member_no IN ('M202606130021', 'M202606120118', 'M202606090242')
  AND NOT EXISTS (SELECT 1 FROM scrm_contacts c WHERE c.tenant_id = @tenant_id AND c.external_user_id = CONCAT('wx_contact_', m.member_no));

INSERT INTO scrm_customer_groups (tenant_id, name, owner_employee_id, member_count, tags_json, active_status)
SELECT @tenant_id, '重点客户一对一跟进', e.id, 128, JSON_ARRAY('高价值会员', '本月重点'), 'active'
FROM org_employees e
WHERE e.tenant_id = @tenant_id AND e.employee_no = 'E0001'
  AND NOT EXISTS (SELECT 1 FROM scrm_customer_groups g WHERE g.tenant_id = @tenant_id AND g.name = '重点客户一对一跟进');

INSERT INTO scrm_materials (tenant_id, title, material_type, content_json, tags_json, created_by)
SELECT @tenant_id, '会员日权益长图', 'image', JSON_OBJECT('url', '/materials/member-day.png', 'description', '会员日权益与积分规则'), JSON_ARRAY('会员日', '权益'), @admin_user_id
WHERE NOT EXISTS (SELECT 1 FROM scrm_materials WHERE tenant_id = @tenant_id AND title = '会员日权益长图');

INSERT INTO scrm_materials (tenant_id, title, material_type, content_json, tags_json, created_by)
SELECT @tenant_id, '新品试吃邀请话术', 'text', JSON_OBJECT('content', '您好，本周有新品试吃活动，诚邀您到店体验并领取积分。'), JSON_ARRAY('新品', '邀约'), @admin_user_id
WHERE NOT EXISTS (SELECT 1 FROM scrm_materials WHERE tenant_id = @tenant_id AND title = '新品试吃邀请话术');

INSERT INTO scrm_group_message_tasks (tenant_id, name, material_id, target_json, status, scheduled_at, metrics_json)
SELECT @tenant_id, '高价值会员新品邀约', m.id, JSON_OBJECT('groupIds', JSON_ARRAY('WXG-HZ-001', 'WXG-NB-002'), 'estimatedMembers', 604), 'scheduled', '2026-06-18 10:00:00', JSON_OBJECT('sent', 0, 'read', 0, 'click', 0)
FROM scrm_materials m
WHERE m.tenant_id = @tenant_id AND m.title = '新品试吃邀请话术'
  AND NOT EXISTS (SELECT 1 FROM scrm_group_message_tasks t WHERE t.tenant_id = @tenant_id AND t.name = '高价值会员新品邀约');

-- AI Claw conversation history and executable actions.
INSERT INTO ai_claw_sessions (tenant_id, user_id, title, scope, active_tool, status)
SELECT @tenant_id, @admin_user_id, '会员增长周报分析', '近30天', '数据洞察', 'open'
WHERE NOT EXISTS (SELECT 1 FROM ai_claw_sessions WHERE tenant_id = @tenant_id AND title = '会员增长周报分析');

SET @claw_session_id = (SELECT id FROM ai_claw_sessions WHERE tenant_id = @tenant_id AND title = '会员增长周报分析' LIMIT 1);

INSERT INTO ai_claw_messages (tenant_id, session_id, role, content, tool_name, scope, steps_json)
SELECT @tenant_id, @claw_session_id, 'user', '近 30 天高价值会员的活跃情况怎么样？', '数据洞察', '近30天', JSON_ARRAY('读取会员指标', '按价值标签筛选', '生成经营建议')
WHERE NOT EXISTS (SELECT 1 FROM ai_claw_messages WHERE session_id = @claw_session_id AND role = 'user' AND content = '近 30 天高价值会员的活跃情况怎么样？');

INSERT INTO ai_claw_messages (tenant_id, session_id, role, content, tool_name, scope, steps_json)
SELECT @tenant_id, @claw_session_id, 'assistant', '当前数据库中高价值会员共 3 人，建议优先邀请其参与新品试吃，并通过会员日权益提升复购。', '数据洞察', '近30天', JSON_ARRAY('读取会员指标', '按价值标签筛选', '生成经营建议')
WHERE NOT EXISTS (SELECT 1 FROM ai_claw_messages WHERE session_id = @claw_session_id AND role = 'assistant' AND content LIKE '当前数据库中高价值会员共 3 人%');

INSERT INTO ai_claw_actions (tenant_id, suggestion_id, action_type, target_type, target_id, status, created_by, payload_json)
SELECT @tenant_id, s.id, 'create_campaign', 'segment', g.id, 'created', @admin_user_id, JSON_OBJECT('channel', '微信社群', 'campaignName', '高价值会员新品邀约')
FROM ai_claw_suggestions s JOIN crm_segments g ON g.tenant_id = @tenant_id AND g.name = '高价值活跃会员'
WHERE s.tenant_id = @tenant_id AND s.title = '针对重要发展会员'
  AND NOT EXISTS (SELECT 1 FROM ai_claw_actions a WHERE a.tenant_id = @tenant_id AND a.suggestion_id = s.id AND a.action_type = 'create_campaign');

-- IAM, configuration and developer pages get persistent records as well.
INSERT INTO iam_roles (tenant_id, code, name, data_scope, description)
VALUES (@tenant_id, 'operator', '会员运营专员', 'tenant', '负责会员分群、标签和营销任务执行')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT INTO iam_permissions (code, name, resource, action, description)
VALUES
  ('member.read', '查看会员', 'members', 'read', '查看会员列表与会员详情'),
  ('segment.write', '管理人群分组', 'segments', 'write', '创建、编辑和刷新会员分组'),
  ('campaign.write', '管理营销活动', 'campaigns', 'write', '创建和排期营销活动'),
  ('claw.execute', '执行 Claw 建议', 'claw', 'execute', '将 AI 建议转为运营任务')
ON DUPLICATE KEY UPDATE name = VALUES(name), description = VALUES(description);

INSERT IGNORE INTO iam_role_permissions (role_id, permission_id)
SELECT r.id, p.id FROM iam_roles r JOIN iam_permissions p
WHERE r.tenant_id = @tenant_id AND r.code = 'operator'
  AND p.code IN ('member.read', 'segment.write', 'campaign.write', 'claw.execute');

INSERT IGNORE INTO iam_user_roles (user_id, role_id)
SELECT @admin_user_id, r.id FROM iam_roles r WHERE r.tenant_id = @tenant_id AND r.code = 'operator';

INSERT INTO ops_message_templates (tenant_id, code, channel, title, content, variables_json, status)
VALUES
  (@tenant_id, 'member_wakeup_wechat', 'wechat', '会员唤醒提醒', '您好，{{memberName}}，本周会员日有专属权益，欢迎到店体验。', JSON_ARRAY('memberName'), 'published'),
  (@tenant_id, 'campaign_success_notice', 'wechat', '活动完成通知', '活动 {{campaignName}} 已完成，触达 {{reachCount}} 人。', JSON_ARRAY('campaignName', 'reachCount'), 'published')
ON DUPLICATE KEY UPDATE title = VALUES(title), content = VALUES(content), status = VALUES(status);

INSERT INTO ops_dictionary_types (tenant_id, code, name)
VALUES (@tenant_id, 'member_status', '会员状态'), (@tenant_id, 'campaign_channel', '营销渠道')
ON DUPLICATE KEY UPDATE name = VALUES(name);

INSERT INTO ops_dictionary_items (tenant_id, type_id, code, label, sort_order, enabled)
SELECT @tenant_id, d.id, 'active', '活跃', 1, 1 FROM ops_dictionary_types d
WHERE d.tenant_id = @tenant_id AND d.code = 'member_status'
  AND NOT EXISTS (SELECT 1 FROM ops_dictionary_items i WHERE i.type_id = d.id AND i.code = 'active');

INSERT INTO ops_dictionary_items (tenant_id, type_id, code, label, sort_order, enabled)
SELECT @tenant_id, d.id, 'to_wake', '待唤醒', 2, 1 FROM ops_dictionary_types d
WHERE d.tenant_id = @tenant_id AND d.code = 'member_status'
  AND NOT EXISTS (SELECT 1 FROM ops_dictionary_items i WHERE i.type_id = d.id AND i.code = 'to_wake');

INSERT INTO ops_dictionary_items (tenant_id, type_id, code, label, sort_order, enabled)
SELECT @tenant_id, d.id, 'wechat', '微信触达', 1, 1 FROM ops_dictionary_types d
WHERE d.tenant_id = @tenant_id AND d.code = 'campaign_channel'
  AND NOT EXISTS (SELECT 1 FROM ops_dictionary_items i WHERE i.type_id = d.id AND i.code = 'wechat');

INSERT INTO ops_scheduled_jobs (tenant_id, code, name, cron_expr, handler, enabled, next_run_at)
VALUES
  (@tenant_id, 'refresh_member_segments', '刷新会员分组', '0 */2 * * *', 'segment.refresh', 1, '2026-06-16 16:00:00'),
  (@tenant_id, 'generate_claw_insights', '生成 Claw 洞察', '0 8 * * *', 'claw.insight', 1, '2026-06-17 08:00:00')
ON DUPLICATE KEY UPDATE name = VALUES(name), next_run_at = VALUES(next_run_at);

SET @segment_job_id = (SELECT id FROM ops_scheduled_jobs WHERE tenant_id = @tenant_id AND code = 'refresh_member_segments' LIMIT 1);
INSERT INTO ops_job_runs (tenant_id, job_id, status, started_at, finished_at, output_json)
SELECT @tenant_id, @segment_job_id, 'success', '2026-06-15 14:00:00', '2026-06-15 14:00:03', JSON_OBJECT('segments', 4, 'updated', 4)
WHERE NOT EXISTS (SELECT 1 FROM ops_job_runs WHERE tenant_id = @tenant_id AND job_id = @segment_job_id AND started_at = '2026-06-15 14:00:00');

INSERT INTO ops_audit_logs (tenant_id, actor_user_id, action, resource_type, resource_id, after_json, ip_address, user_agent)
SELECT @tenant_id, @admin_user_id, 'seed_demo_data', 'database', NULL, JSON_OBJECT('source', '05_seed_page_detail_data.sql', 'status', 'completed'), '127.0.0.1', 'member-crm-migration'
WHERE NOT EXISTS (SELECT 1 FROM ops_audit_logs WHERE tenant_id = @tenant_id AND action = 'seed_demo_data' AND user_agent = 'member-crm-migration');

-- Developer platform records.
INSERT INTO dev_applications (tenant_id, app_key, name, owner_user_id, status, scopes_json)
VALUES (@tenant_id, 'member-ops-console', '会员运营工作台', @admin_user_id, 'active', JSON_ARRAY('member.read', 'segment.write', 'campaign.write'))
ON DUPLICATE KEY UPDATE name = VALUES(name), status = VALUES(status), scopes_json = VALUES(scopes_json);

INSERT INTO dev_api_docs (tenant_id, code, title, path, method, version, doc_markdown, status)
VALUES
  (@tenant_id, 'app-data', '获取应用数据', '/api/app-data', 'GET', 'v1', '返回当前租户的会员、营销、微信与 Claw 数据。', 'published'),
  (@tenant_id, 'audience-conditions', '保存人群条件', '/api/audience/conditions', 'POST', 'v1', '保存会员分组条件并同步营销筛选。', 'published')
ON DUPLICATE KEY UPDATE title = VALUES(title), doc_markdown = VALUES(doc_markdown), status = VALUES(status);

INSERT INTO dev_api_permissions (tenant_id, application_id, api_doc_id, field_scope_json, data_scope, granted_by)
SELECT @tenant_id, a.id, d.id, JSON_OBJECT('fields', JSON_ARRAY('*')), 'tenant', @admin_user_id
FROM dev_applications a JOIN dev_api_docs d ON d.tenant_id = @tenant_id
WHERE a.tenant_id = @tenant_id AND a.app_key = 'member-ops-console'
  AND d.code IN ('app-data', 'audience-conditions')
ON DUPLICATE KEY UPDATE field_scope_json = VALUES(field_scope_json), data_scope = VALUES(data_scope);

INSERT INTO dev_webhooks (tenant_id, application_id, name, callback_url, enabled, retry_policy_json)
SELECT @tenant_id, a.id, '会员分组变更通知', 'https://example.invalid/hooks/member-segment-updated', 0, JSON_OBJECT('maxRetries', 3, 'backoffSeconds', 30)
FROM dev_applications a
WHERE a.tenant_id = @tenant_id AND a.app_key = 'member-ops-console'
  AND NOT EXISTS (SELECT 1 FROM dev_webhooks w WHERE w.tenant_id = @tenant_id AND w.name = '会员分组变更通知');

INSERT INTO dev_event_subscriptions (tenant_id, application_id, event_type, enabled, filter_json)
SELECT @tenant_id, a.id, 'member.segment.updated', 1, JSON_OBJECT('tenantCode', 'ym-foods')
FROM dev_applications a
WHERE a.tenant_id = @tenant_id AND a.app_key = 'member-ops-console'
  AND NOT EXISTS (SELECT 1 FROM dev_event_subscriptions e WHERE e.tenant_id = @tenant_id AND e.event_type = 'member.segment.updated');

COMMIT;
