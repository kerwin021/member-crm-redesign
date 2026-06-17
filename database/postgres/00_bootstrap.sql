-- IS 微智会员 SCRM PostgreSQL bootstrap
-- Run this file as a PostgreSQL superuser in the default `postgres` database.
-- Replace the CHANGE_ME passwords before running in production.

CREATE ROLE member_crm_app LOGIN PASSWORD 'CHANGE_ME_APP_PASSWORD';
CREATE ROLE member_crm_readonly LOGIN PASSWORD 'CHANGE_ME_READONLY_PASSWORD';

CREATE DATABASE member_crm
  WITH OWNER = member_crm_app
       ENCODING = 'UTF8'
       TEMPLATE = template0;

COMMENT ON DATABASE member_crm IS 'IS 微智会员 SCRM 业务数据库';
