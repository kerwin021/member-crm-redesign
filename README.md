# IS 微智会员 SCRM

一个基于 React 和 Vite 构建的会员数据与 SCRM 管理系统交互原型，采用七大业务域动态导航结构。

在线预览：[https://kerwin021.github.io/member-crm-redesign/](https://kerwin021.github.io/member-crm-redesign/)

## 功能范围

- 微智 Claw：本期洞察、智能问答（整合智能推荐）与推荐问题
- 用户数据：会员档案、分群、标签、商品、订单与经营洞察
- 微信管理：聊天会话、社群营销、朋友圈与自动回复
- 营销管理：营销活动、自动化营销、客户旅程、优惠券与触达任务
- 忠诚度管理：会员等级、成长值、权益、积分规则与积分商城
- 社交 SCRM：客户联系人、客户群、欢迎语、群发任务与会话记录
- 配置管理：组织、门店、员工、角色权限、审批、系统参数、消息模板、数据字典、任务调度、安全设置、应用、API 文档、接口权限、Webhook、事件订阅与调用日志

所有菜单入口均包含可操作的筛选、创建、状态切换、详情抽屉和执行反馈，并适配桌面端与移动端。

## 2026-06-16 迭代

- 品牌名称统一为“微智”。
- 删除侧栏顶部冗余的业务域提示，保留业务域动态菜单。
- 增加 AI 助手宽度、提升中间内容字号，并让右下角 AI 洞察按钮支持拖动与点击打开。

## v1.2 迭代

- 在顶部业务域中新增“微信管理”，并位于“用户数据”之后。
- 微信管理左侧菜单包含聊天会话、社群营销、朋友圈、自动回复。
- 聊天会话页面参考桌面微信客服工作台，支持会话筛选、切换、置顶、日期筛选和消息发送。
- 在“用户数据”之前新增“微智 Claw”业务域，左侧菜单参考右侧 AI 助手能力。
- 将“智能推荐”能力整合进“智能问答”页面，并升级为大号输入框与推荐问题卡片布局。

## 本地运行

```bash
pnpm install
pnpm dev
```

默认访问地址：`http://127.0.0.1:5173/`

## 连接真实 MySQL 数据

前端会优先请求 `/api/app-data`，由 `server/api.py` 从 MySQL 读取会员、分群、标签、商品、订单、微信会话和微智 Claw 数据。API 不可用时页面会自动使用本地兜底数据，避免白屏。

```bash
cp server/.env.example server/.env
python3 -m pip install -r server/requirements.txt
python3 server/api.py
pnpm dev
```

本地 Vite 已代理 `/api` 到 `http://127.0.0.1:8787`。线上部署时建议在宝塔中把站点的 `/api` 反向代理到 API 进程，或构建前设置 `VITE_API_BASE_URL` 指向 API 地址。

## 构建

```bash
pnpm build
pnpm preview
```

## 数据库与宝塔部署

MySQL 数据库设计与宝塔部署文件已放在：

- `database/mysql/`
- `deploy/baota/mysql/`
- `docs/baota-mysql-deployment.md`
- `server/api.py`

## 技术栈

- React 19
- Vite 6
- Recharts
- Tabler Icons
