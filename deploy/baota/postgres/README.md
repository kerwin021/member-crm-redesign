# 宝塔 PostgreSQL 部署包

这个目录用于在宝塔面板的 Docker / Compose 项目中部署 PostgreSQL。

## 文件准备

1. 在宝塔服务器创建目录：

```bash
mkdir -p /www/server/member-crm-postgres/init
```

2. 上传以下文件：

```text
deploy/baota/postgres/docker-compose.yml -> /www/server/member-crm-postgres/docker-compose.yml
deploy/baota/postgres/.env.example -> /www/server/member-crm-postgres/.env
database/postgres/01_schema.sql -> /www/server/member-crm-postgres/init/01_schema.sql
database/postgres/02_seed_demo.sql -> /www/server/member-crm-postgres/init/02_seed_demo.sql
```

3. 编辑 `/www/server/member-crm-postgres/.env`，把 `POSTGRES_PASSWORD` 换成强密码。

## 启动

在宝塔终端或 SSH 中运行：

```bash
cd /www/server/member-crm-postgres
docker compose up -d
```

初始化脚本只会在首次创建数据卷时自动执行。若已经创建过容器和数据卷，修改 SQL 后需要手动进入容器执行迁移。

## 连接

默认只监听本机：

```text
host=127.0.0.1
port=5432
database=member_crm
user=member_crm_app
password=见 .env
```

如果后端 API 和数据库在同一台宝塔服务器，建议保持 `POSTGRES_BIND_HOST=127.0.0.1`，不要对公网开放 5432。
