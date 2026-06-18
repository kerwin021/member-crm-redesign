# 宝塔 MySQL 部署包

这个目录用于在宝塔面板中部署 IS 微智会员 SCRM 的 MySQL 数据库。

## 方案 A：宝塔内置 MySQL

如果宝塔软件商店已经安装 MySQL，优先使用这个方案。

1. 在宝塔数据库面板创建数据库：

```text
数据库名：member_crm
用户名：member_crm_app
字符集：utf8mb4
```

2. 上传并执行：

```bash
mysql -h 127.0.0.1 -u member_crm_app -p member_crm < database/mysql/01_schema.sql
mysql -h 127.0.0.1 -u member_crm_app -p member_crm < database/mysql/02_seed_demo.sql
```

## 方案 B：宝塔 Docker Compose

适合想把数据库和宝塔内置 MySQL 隔离，或服务器当前没有 MySQL 的情况。

1. 在宝塔服务器创建目录：

```bash
mkdir -p /www/server/member-crm-mysql/init
```

2. 上传以下文件：

```text
deploy/baota/mysql/docker-compose.yml -> /www/server/member-crm-mysql/docker-compose.yml
deploy/baota/mysql/.env.example -> /www/server/member-crm-mysql/.env
database/mysql/01_schema.sql -> /www/server/member-crm-mysql/init/01_schema.sql
database/mysql/02_seed_demo.sql -> /www/server/member-crm-mysql/init/02_seed_demo.sql
```

3. 编辑 `/www/server/member-crm-mysql/.env`，把两个密码换成强密码。

4. 启动：

```bash
cd /www/server/member-crm-mysql
docker compose up -d
```

初始化脚本只会在首次创建数据卷时自动执行。若已经创建过容器和数据卷，修改 SQL 后需要手动进入容器执行迁移。

## 连接

默认只监听本机：

```text
host=127.0.0.1
port=3306
database=member_crm
user=member_crm_app
password=见 .env 或宝塔数据库面板
```

如果后端 API 和数据库在同一台宝塔服务器，建议保持 `MYSQL_BIND_HOST=127.0.0.1`，不要对公网开放 3306。
