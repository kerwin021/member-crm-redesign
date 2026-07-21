-- Enrich existing Claw recommendations for the executable action layout.
-- This migration only updates the JSON metadata owned by ai_claw_suggestions.

UPDATE ai_claw_suggestions
SET payload_json = JSON_OBJECT(
  'targetAudience', '重要发展会员',
  'owner', '会员运营组',
  'channel', '企业微信 + 会员中心',
  'impactMetric', '金卡升级率',
  'primaryAction', '创建任务',
  'secondaryActions', JSON_ARRAY('生成分群', '查看会员')
)
WHERE title = '针对重要发展会员';

UPDATE ai_claw_suggestions
SET payload_json = JSON_OBJECT(
  'targetAudience', '银卡 / 金卡会员',
  'owner', '忠诚度运营组',
  'channel', '会员权益中心',
  'impactMetric', '等级升级率',
  'primaryAction', '创建任务',
  'secondaryActions', JSON_ARRAY('生成分群', '查看会员')
)
WHERE title = '优化会员等级权益';

UPDATE ai_claw_suggestions
SET payload_json = JSON_OBJECT(
  'targetAudience', '沉睡会员',
  'owner', 'CRM 运营组',
  'channel', '短信 + 企业微信',
  'impactMetric', '召回复购率',
  'primaryAction', '创建任务',
  'secondaryActions', JSON_ARRAY('生成分群', '查看会员')
)
WHERE title = '沉睡会员唤醒计划';
