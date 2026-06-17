# Codex Handoff

## Project

- Repository: https://github.com/kerwin021/member-crm-redesign
- Live preview: https://kerwin021.github.io/member-crm-redesign/
- Latest main commit before navigation merge: `985f87b`
- Latest deployed gh-pages commit before navigation merge: `bcd6d51`

## Current State

This is a React + Vite interactive prototype for the IS 微智会员 SCRM system.

Implemented business domains:

- 微智 Claw
- 用户数据
- 微信管理
- 营销管理
- 忠诚度管理
- 社交SCRM
- 配置管理

Note: 企业管理 and 开发平台 have been merged into 配置管理. Their left-side menus now live under 配置管理 as 组织管理、权限与审批、应用与接口、事件与监控.

Recent completed work:

- Added 微智 Claw before 用户数据 in the top business domain navigation.
- Added 微智 Claw left navigation: 本期洞察、智能问答、推荐问题.
- Merged the old 智能推荐 / 智能建议 page into 智能问答.
- Updated 智能问答 with a larger Doubao-like composer, four tool entrances, recommendation cards, and prompt cards.
- Added 微信管理 business domain with 聊天会话、社群营销、朋友圈、自动回复.
- Reworked 聊天会话 as a WeChat-style customer service workspace.
- Increased AI assistant width, improved content font sizing, and made the AI insight floating button draggable.
- Brand text has been unified to 微智.
- Merged 企业管理 and 开发平台 into 配置管理 to reduce top-level business domains.

## How To Continue On Another Codex Device

1. Clone or open this repository on the other device:

```bash
git clone https://github.com/kerwin021/member-crm-redesign.git
cd member-crm-redesign
```

2. Install and run:

```bash
pnpm install
pnpm dev
```

3. If dependencies are already present, build directly:

```bash
pnpm build
pnpm preview
```

## Recommended Next Prompt For Codex

```text
继续完善 member-crm-redesign 项目。当前目标是提升微智 Claw 的智能问答体验：
1. 保持顶部七个业务域和动态左侧菜单不变；企业管理、开发平台能力已合并到配置管理。
2. 重点优化 微智 Claw -> 智能问答 页面。
3. 参考豆包的输入框体验，继续增强输入区的视觉层级、推荐问题入口和智能推荐动作。
4. 所有可见入口必须可点击、有反馈，并兼容桌面和移动端。
5. 修改后运行生产构建，使用浏览器验证本地和线上页面，提交并推送 main，更新 gh-pages。
6. 最终报告提交哈希、线上地址、验证结果和剩余风险。
```

## Verification Checklist

- Production build passes.
- Top business domain order starts with 微智 Claw, then 用户数据.
- Top business domains no longer include 企业管理 or 开发平台; those menus appear under 配置管理.
- 微智 Claw left menu only includes 本期洞察、智能问答、推荐问题.
- 智能问答 page includes:
  - Large multiline composer.
  - Tool entrances: 数据洞察、生成方案、创建任务、推荐问题.
  - Prompt cards.
  - Integrated 智能推荐 cards.
  - Send interaction with generated answer and cleared input.
- Desktop and mobile layouts remain usable.
- Browser console has no relevant errors.
