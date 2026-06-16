import {
  IconActivity,
  IconAdjustmentsHorizontal,
  IconBolt,
  IconBrandWechat,
  IconBrain,
  IconBuildingStore,
  IconChartBar,
  IconClipboardData,
  IconCode,
  IconDatabaseExport,
  IconDeviceMobile,
  IconDiscount2,
  IconFileText,
  IconHeartHandshake,
  IconIdBadge2,
  IconLock,
  IconMessageCircle,
  IconPackage,
  IconSettings,
  IconSpeakerphone,
  IconTag,
  IconTargetArrow,
  IconUsers,
  IconUsersGroup,
} from "@tabler/icons-react";

const item = (id, label, icon, description, action, samples, expandable = false) => ({
  id,
  label,
  icon,
  description,
  action,
  samples,
  expandable,
});

export const DOMAIN_NAVIGATION = {
  用户数据: {
    home: { id: "dashboard", label: "主页" },
    groups: [
      {
        label: "用户档案",
        items: [
          item("members", "会员列表", IconUsers),
          item("high-value", "高贡献会员", IconTargetArrow),
          item("logs", "会员日志", IconFileText),
        ],
      },
      { label: "分群管理", items: [item("segments", "会员分组", IconUsersGroup)] },
      {
        label: "标签管理",
        items: [
          item("tags", "会员标签", IconTag),
          item("tag-scenes", "标签场景分配", IconAdjustmentsHorizontal),
          item("tag-logs", "会员标签变更日志", IconClipboardData),
        ],
      },
      {
        label: "用户销售",
        items: [item("products", "商品库", IconPackage, "", "", [], true), item("orders", "订单管理", IconFileText, "", "", [], true)],
      },
      {
        label: "用户洞察",
        items: [
          item("fans", "粉丝洞察", IconUsersGroup, "", "", [], true),
          item("member-insight", "会员洞察", IconBrain, "", "", [], true),
          item("sales-insight", "销售洞察", IconChartBar, "", "", [], true),
        ],
      },
    ],
  },
  微信管理: {
    home: { id: "wechat-chat", label: "聊天会话" },
    groups: [
      {
        label: "微信运营",
        items: [
          item("wechat-community", "社群营销", IconUsersGroup, "运营微信群、社群活动、成员标签和群发任务", "新建社群任务", ["新品体验群运营", "门店会员群激活", "沉默群成员唤醒"]),
          item("wechat-moments", "朋友圈", IconBrandWechat, "管理企业微信朋友圈内容、发布计划和互动数据", "新建朋友圈", ["夏日新品种草", "会员日福利预告", "门店早餐搭配"]),
          item("wechat-auto-reply", "自动回复", IconMessageCircle, "配置关键词、欢迎语和客服自动回复规则", "新建回复规则", ["售后咨询回复", "优惠券关键词回复", "营业时间问答"]),
        ],
      },
    ],
  },
  营销管理: {
    home: { id: "domain-marketing", label: "营销概览" },
    groups: [
      {
        label: "营销中心",
        items: [
          item("marketing-campaigns", "营销活动", IconSpeakerphone, "管理满减、拉新、召回和节日营销活动", "新建活动", ["夏日会员尝鲜季", "沉睡会员唤醒计划", "新客首单礼"]),
          item("marketing-automation", "自动化营销", IconBolt, "根据会员事件自动执行触达和跟进", "新建自动化", ["注册后 24 小时关怀", "生日月专属权益", "流失风险预警"]),
          item("marketing-journeys", "客户旅程", IconTargetArrow, "编排跨渠道的会员生命周期运营旅程", "新建旅程", ["新会员 30 天培育", "高价值会员关怀", "会员升级激励"]),
        ],
      },
      {
        label: "营销工具",
        items: [
          item("marketing-coupons", "优惠券管理", IconDiscount2, "维护优惠券模板、库存、领取和核销规则", "创建优惠券", ["新人满 50 减 10", "周末酸奶品类券", "金卡会员生日券"]),
          item("marketing-reach", "触达任务", IconMessageCircle, "创建短信、企微和站内消息触达任务", "新建触达", ["新品上市通知", "积分到期提醒", "订单完成回访"]),
          item("marketing-records", "触达记录", IconClipboardData, "查看各渠道消息发送、到达与转化结果", "导出记录", ["短信发送记录", "企业微信触达记录", "站内消息记录"]),
        ],
      },
    ],
  },
  忠诚度管理: {
    home: { id: "domain-loyalty", label: "忠诚度概览" },
    groups: [
      {
        label: "会员成长",
        items: [
          item("loyalty-levels", "会员等级", IconIdBadge2, "配置等级门槛、有效期、升降级和保级规则", "新建等级", ["普通卡", "金卡会员", "钻石会员"]),
          item("loyalty-growth", "成长值管理", IconActivity, "管理成长值获取规则与会员成长任务", "新增规则", ["订单消费成长值", "连续签到奖励", "完善资料奖励"]),
          item("loyalty-benefits", "会员权益", IconHeartHandshake, "配置不同等级可享受的长期和周期权益", "新增权益", ["会员专享价", "生日月双倍积分", "钻石会员新品试吃"]),
        ],
      },
      {
        label: "积分中心",
        items: [
          item("loyalty-points-rules", "积分规则", IconSettings, "配置积分获取、抵扣、过期和冻结规则", "新建积分规则", ["消费 1 元积 1 分", "积分抵现规则", "年度积分清零规则"]),
          item("loyalty-points-mall", "积分商城", IconPackage, "管理积分兑换商品、库存和兑换限制", "新增兑换商品", ["10 元无门槛券", "限定保温杯", "早餐套餐兑换券"]),
          item("loyalty-points-ledger", "积分流水", IconFileText, "查询积分增加、扣减、冻结和过期记录", "导出流水", ["消费积分入账", "兑换商品扣减", "过期积分清理"]),
        ],
      },
    ],
  },
  社交SCRM: {
    home: { id: "domain-scrm", label: "SCRM 概览" },
    groups: [
      {
        label: "客户运营",
        items: [
          item("scrm-contacts", "客户联系人", IconUsers, "统一管理企业微信联系人和会员绑定关系", "添加客户", ["林晓然", "周子墨", "陈安宁"]),
          item("scrm-groups", "客户群", IconUsersGroup, "管理客户群、群主、群标签和活跃状态", "新建客户群", ["杭州西湖店会员群", "新品体验官群", "钻石会员服务群"]),
          item("scrm-welcome", "欢迎语", IconMessageCircle, "配置员工添加客户后的个性化欢迎内容", "新建欢迎语", ["新会员欢迎语", "门店导购欢迎语", "活动渠道欢迎语"]),
        ],
      },
      {
        label: "内容触达",
        items: [
          item("scrm-group-messages", "群发任务", IconSpeakerphone, "创建客户和客户群的企业微信群发任务", "新建群发", ["周末会员福利", "新品预售提醒", "积分到期通知"]),
          item("scrm-materials", "素材库", IconDatabaseExport, "沉淀图文、海报、链接和小程序内容素材", "上传素材", ["夏日新品海报", "会员权益长图", "早餐搭配指南"]),
          item("scrm-conversations", "会话记录", IconClipboardData, "查询员工与客户的合规会话和服务记录", "导出记录", ["客户咨询记录", "售后服务记录", "活动跟进记录"]),
        ],
      },
    ],
  },
  企业管理: {
    home: { id: "domain-enterprise", label: "企业概览" },
    groups: [
      {
        label: "组织管理",
        items: [
          item("enterprise-org", "组织架构", IconBuildingStore, "维护总部、区域、城市、门店和部门层级", "新增组织", ["一鸣食品总部", "浙北运营区域", "杭州西湖门店组"]),
          item("enterprise-stores", "门店管理", IconBuildingStore, "维护门店资料、营业状态和服务范围", "新增门店", ["杭州西湖店", "宁波鄞州店", "温州鹿城店"]),
          item("enterprise-employees", "员工管理", IconIdBadge2, "管理员工账号、岗位、归属门店和在职状态", "新增员工", ["区域运营经理", "门店店长", "会员运营专员"]),
        ],
      },
      {
        label: "权限与审批",
        items: [
          item("enterprise-roles", "角色权限", IconLock, "按角色配置页面、数据范围和业务操作权限", "新建角色", ["超级管理员", "区域运营", "门店店长"]),
          item("enterprise-approvals", "审批中心", IconClipboardData, "处理权限、营销活动和数据导出的审批流程", "发起审批", ["优惠券活动审批", "员工数据权限申请", "会员数据导出审批"]),
          item("enterprise-audit", "操作审计", IconFileText, "追踪重要配置、数据和权限的操作记录", "导出审计", ["权限配置变更", "会员数据导出", "系统参数修改"]),
        ],
      },
    ],
  },
  配置管理: {
    home: { id: "domain-config", label: "配置概览" },
    groups: [
      {
        label: "业务配置",
        items: [
          item("config-parameters", "系统参数", IconSettings, "维护会员、订单、营销等系统级业务参数", "新增参数", ["会员手机号脱敏", "订单自动关闭时间", "营销任务频控"]),
          item("config-templates", "消息模板", IconMessageCircle, "管理短信、站内信和企业微信消息模板", "新建模板", ["会员注册成功通知", "优惠券到账提醒", "订单发货通知"]),
          item("config-dictionaries", "数据字典", IconDatabaseExport, "统一管理业务枚举、编码和基础数据", "新增字典", ["会员来源字典", "订单状态字典", "营销渠道字典"]),
        ],
      },
      {
        label: "系统运行",
        items: [
          item("config-scheduler", "任务调度", IconBolt, "管理自动任务、执行计划和失败重试", "新建任务", ["会员等级日终计算", "标签规则实时任务", "积分到期清理"]),
          item("config-logs", "系统日志", IconFileText, "查询登录、操作、接口和任务运行日志", "导出日志", ["管理员登录日志", "配置变更日志", "任务执行日志"]),
          item("config-security", "安全设置", IconLock, "配置登录安全、密码策略和数据访问限制", "修改策略", ["管理员密码策略", "异地登录保护", "敏感数据访问控制"]),
        ],
      },
    ],
  },
  开发平台: {
    home: { id: "domain-dev", label: "开发概览" },
    groups: [
      {
        label: "应用与接口",
        items: [
          item("dev-apps", "应用管理", IconDeviceMobile, "创建开放应用并配置密钥和接口范围", "新建应用", ["会员数据同步应用", "门店收银接入", "营销自动化助手"]),
          item("dev-api-docs", "API 文档", IconCode, "查看会员、订单、营销和组织开放接口", "发布文档", ["会员中心 API", "订单中心 API", "营销中心 API"]),
          item("dev-permissions", "接口权限", IconLock, "维护应用可访问的接口、字段和数据范围", "新增授权", ["会员基础信息读取", "订单数据写入", "优惠券发放权限"]),
        ],
      },
      {
        label: "事件与监控",
        items: [
          item("dev-webhooks", "Webhook", IconBolt, "配置业务事件回调地址、签名和重试策略", "新增回调", ["会员注册事件", "订单支付事件", "优惠券核销事件"]),
          item("dev-events", "事件订阅", IconActivity, "订阅平台业务事件并管理消费状态", "新增订阅", ["会员等级变更", "订单状态更新", "积分余额变化"]),
          item("dev-call-logs", "调用日志", IconClipboardData, "查询接口请求、响应、耗时和错误信息", "导出日志", ["会员查询接口", "订单同步接口", "营销任务创建接口"]),
        ],
      },
    ],
  },
};

export const DOMAIN_NAV = Object.keys(DOMAIN_NAVIGATION);

export const DOMAIN_PAGES = Object.fromEntries(
  Object.entries(DOMAIN_NAVIGATION).map(([domain, config]) => [domain, config.home.id]),
);

const existingMeta = {
  dashboard: { title: "主页", group: "用户数据", domain: "用户数据" },
  members: { title: "会员列表", group: "用户档案", domain: "用户数据" },
  "high-value": { title: "高贡献会员", group: "用户档案", domain: "用户数据" },
  logs: { title: "会员日志", group: "用户档案", domain: "用户数据" },
  segments: { title: "会员分组", group: "分群管理", domain: "用户数据" },
  tags: { title: "会员标签", group: "标签管理", domain: "用户数据" },
  "tag-scenes": { title: "标签场景分配", group: "标签管理", domain: "用户数据" },
  "tag-logs": { title: "会员标签变更日志", group: "标签管理", domain: "用户数据" },
  products: { title: "商品库", group: "用户销售", domain: "用户数据" },
  orders: { title: "订单管理", group: "用户销售", domain: "用户数据" },
  fans: { title: "粉丝洞察", group: "用户洞察", domain: "用户数据" },
  "member-insight": { title: "会员洞察", group: "用户洞察", domain: "用户数据" },
  "sales-insight": { title: "销售洞察", group: "用户洞察", domain: "用户数据" },
};

export const PAGE_META = { ...existingMeta };
export const FEATURE_PAGE_CONFIG = {};

Object.entries(DOMAIN_NAVIGATION).forEach(([domain, config]) => {
  PAGE_META[config.home.id] = { title: config.home.label, group: domain, domain };
  config.groups.forEach((group) => {
    group.items.forEach((menuItem) => {
      PAGE_META[menuItem.id] = { title: menuItem.label, group: group.label, domain };
      if (domain !== "用户数据") {
        FEATURE_PAGE_CONFIG[menuItem.id] = {
          ...menuItem,
          domain,
          group: group.label,
        };
      }
    });
  });
});
