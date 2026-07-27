-- Keep segment and marketing audience filters on one persisted JSON contract.
-- This migration is safe for databases created before audience_json existed.

SET @schema_name = DATABASE();

SET @sql = IF(
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = @schema_name AND table_name = 'crm_segments' AND column_name = 'audience_json'
  ),
  'SELECT 1',
  'ALTER TABLE crm_segments ADD COLUMN audience_json JSON NULL AFTER rule_json'
);
PREPARE audience_schema_stmt FROM @sql;
EXECUTE audience_schema_stmt;
DEALLOCATE PREPARE audience_schema_stmt;

SET @sql = IF(
  EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = @schema_name AND table_name = 'marketing_campaigns' AND column_name = 'audience_json'
  ),
  'SELECT 1',
  'ALTER TABLE marketing_campaigns ADD COLUMN audience_json JSON NULL AFTER rules_json'
);
PREPARE campaign_audience_schema_stmt FROM @sql;
EXECUTE campaign_audience_schema_stmt;
DEALLOCATE PREPARE campaign_audience_schema_stmt;

UPDATE crm_segments
SET audience_json = JSON_OBJECT(
  'version', 1,
  'logic', 'AND',
  'tagIds', JSON_ARRAY(),
  'rules', JSON_ARRAY()
)
WHERE audience_json IS NULL;

UPDATE marketing_campaigns c
JOIN crm_segments s ON s.id = c.target_segment_id AND s.tenant_id = c.tenant_id
SET c.audience_json = s.audience_json
WHERE c.audience_json IS NULL;
