import { FEATURE_PAGE_CONFIG } from "../navigationConfig.jsx";

const trends30 = [
  { day: "06-09", members: 680, rate: 9.2 },
  { day: "06-10", members: 760, rate: 10.1 },
  { day: "06-11", members: 620, rate: 8.6 },
  { day: "06-12", members: 940, rate: 12.4 },
  { day: "06-13", members: 1080, rate: 13.8 },
  { day: "06-14", members: 880, rate: 11.7 },
  { day: "06-15", members: 1258, rate: 15.2 },
];

const trends90 = [
  { day: "03-16", members: 630, rate: 7 },
  { day: "03-26", members: 920, rate: 10 },
  { day: "04-05", members: 1180, rate: 13 },
  { day: "04-15", members: 890, rate: 9 },
  { day: "04-25", members: 1460, rate: 17 },
  { day: "05-05", members: 1220, rate: 15 },
  { day: "05-15", members: 1590, rate: 19 },
  { day: "05-25", members: 1320, rate: 15 },
  { day: "06-04", members: 1890, rate: 24 },
  { day: "06-14", members: 1258, rate: 12.31 },
];

const levels = [
  { name: "普通卡", value: 68452, color: "#2869f6", ratio: "53.18%" },
  { name: "银卡", value: 26315, color: "#11bfa8", ratio: "20.44%" },
  { name: "金卡", value: 18964, color: "#f6a817", ratio: "14.74%" },
  { name: "白金卡", value: 9842, color: "#f36f8e", ratio: "7.65%" },
  { name: "钻石卡", value: 5097, color: "#7b61e8", ratio: "3.96%" },
];

const members = [
  { id: "M202606150021", name: "林晓然", phone: "138****3026", store: "杭州西湖店", level: "钻石卡", source: "小程序商城", date: "2026-06-15", status: "活跃" },
  { id: "M202606140118", name: "周子墨", phone: "186****7913", store: "宁波鄞州店", level: "金卡", source: "门店扫码", date: "2026-06-14", status: "活跃" },
  { id: "M202606130086", name: "陈安宁", phone: "157****6088", store: "温州鹿城店", level: "银卡", source: "公众号", date: "2026-06-13", status: "待唤醒" },
  { id: "M202606120035", name: "吴嘉言", phone: "139****4251", store: "杭州滨江店", level: "普通卡", source: "员工邀请", date: "2026-06-12", status: "活跃" },
  { id: "M202606110242", name: "沈清禾", phone: "177****1638", store: "绍兴越城店", level: "白金卡", source: "小程序商城", date: "2026-06-11", status: "冻结" },
];

const highValueMembers = [
  { name: "林晓然", id: "M202606150021", level: "钻石卡", value: "¥28,640", orders: 32, last: "2 小时前", store: "杭州西湖店", score: 96, trend: "+12.8%" },
  { name: "顾言溪", id: "M202604230192", level: "钻石卡", value: "¥24,980", orders: 28, last: "昨天", store: "宁波鄞州店", score: 93, trend: "+8.6%" },
  { name: "沈清禾", id: "M202603180087", level: "白金卡", value: "¥19,520", orders: 21, last: "3 天前", store: "绍兴越城店", score: 89, trend: "+6.2%" },
];

const segments = [
  { id: 1, name: "高价值活跃会员", desc: "近 90 天消费 ≥ 3000 元，且 30 天内有消费", members: 8342, type: "动态分群", status: true, updated: "今天 10:24", color: "blue" },
  { id: 2, name: "低活跃待唤醒会员", desc: "60 天未消费，历史消费次数 ≥ 3 次", members: 6175, type: "动态分群", status: true, updated: "今天 09:12", color: "orange" },
  { id: 3, name: "近 30 天新会员", desc: "注册时间在近 30 天内的有效会员", members: 26843, type: "系统分群", status: true, updated: "每日更新", color: "green" },
];

const tags = [
  { id: 1, name: "高价值会员", category: "价值标签", coverage: 18620, rules: 3, updated: "今天 10:24", color: "blue", enabled: true },
  { id: 2, name: "待唤醒会员", category: "活跃标签", coverage: 26320, rules: 2, updated: "今天 09:12", color: "orange", enabled: true },
  { id: 3, name: "新品偏好", category: "偏好标签", coverage: 12580, rules: 5, updated: "昨天 16:35", color: "purple", enabled: true },
];

const tagScenes = [
  { id: 1, module: "会员看板", name: "会员价值分层", desc: "在会员看板中展示价值分层标签", tags: ["高价值会员", "待唤醒会员"], enabled: true },
  { id: 2, module: "营销管理", name: "营销任务人群", desc: "在营销创建时快速筛选目标人群", tags: ["新品偏好"], enabled: true },
];

const products = [
  { id: "P100286", name: "一鸣真鲜奶 950ml", category: "乳制品", price: 18.8, stock: 2840, sales: 12650, status: true, updated: "今天 13:20" },
  { id: "P100315", name: "原味风味酸奶 200g", category: "酸奶", price: 8.9, stock: 1680, sales: 9432, status: true, updated: "今天 11:05" },
  { id: "P100422", name: "经典奶香吐司", category: "烘焙", price: 12.8, stock: 860, sales: 7821, status: true, updated: "昨天 17:48" },
];

const orders = [
  { id: "SO202606150328", member: "林晓然", amount: 186.8, items: 6, channel: "小程序商城", store: "杭州西湖店", status: "待发货", time: "2026-06-15 14:28" },
  { id: "SO202606150296", member: "周子墨", amount: 98.5, items: 3, channel: "门店收银", store: "宁波鄞州店", status: "已完成", time: "2026-06-15 13:06" },
  { id: "SO202606150241", member: "陈安宁", amount: 256, items: 8, channel: "小程序商城", store: "温州鹿城店", status: "配送中", time: "2026-06-15 11:42" },
];

const logRows = [
  { time: "2026-06-15 14:32", member: "林晓然", action: "会员等级变更", detail: "白金卡升级为钻石卡", operator: "系统自动", channel: "等级引擎" },
  { time: "2026-06-15 13:18", member: "周子墨", action: "优惠券发放", detail: "发放夏日满减券 ¥20", operator: "超级管理员", channel: "运营后台" },
  { time: "2026-06-15 11:05", member: "陈安宁", action: "标签变更", detail: "新增标签：待唤醒会员", operator: "AI 分群任务", channel: "标签引擎" },
];

const wechatConversations = [
  { id: "wechat-pay", name: "微信支付", type: "聊天", date: "2026/06/15", unread: 1, preview: "关于支付通道和客户侧提示的咨询", tone: "green", icon: "wx", pinned: true },
  { id: "yingyou", name: "营优教育", type: "聊天", date: "2026/06/15", unread: 1, preview: "客户询问系统登录微信和客户端关系", tone: "blue", icon: "text", pinned: true },
  { id: "zz-card", name: "郑州市民卡", type: "群聊", date: "2026/06/14", unread: 0, preview: "社群活动物料已完成二次确认", tone: "orange", icon: "card", pinned: false },
];

const insights = {
  fans: {
    stats: [["粉丝总数", "286,420", "净增长 8.2%"], ["今日新增", "1,258", "取关 98 人"], ["活跃粉丝", "86,520", "活跃率 30.21%"], ["会员转化率", "44.92%", "较上期 +2.8%"]],
    channels: [{ name: "小程序", value: 52 }, { name: "公众号", value: 31 }, { name: "企业微信", value: 17 }],
    contentRanking: [{ name: "夏日新品会员尝鲜活动", value: "12.8%" }, { name: "早餐营养搭配指南", value: "10.6%" }, { name: "会员积分兑换提醒", value: "8.9%" }],
    funnel: [{ label: "内容触达", count: "186,420", value: 100 }, { label: "产生互动", count: "92,860", value: 82 }, { label: "进入商城", count: "48,320", value: 63 }, { label: "转化会员", count: "21,706", value: 44 }],
    recommendation: { title: "AI 增长建议", desc: "建议将公众号高互动粉丝导入小程序新人礼包链路，预计可提升转化 3.2%。" },
  },
  members: {
    stats: [["有效会员", "128,670", "本月新增 6,782"], ["月活会员", "52,340", "活跃率 40.68%"], ["90 天留存", "81.2%", "较上期 +3.1%"], ["高价值会员", "18,620", "占比 14.47%"]],
    lifecycle: [{ label: "新会员", value: 18.2, tone: "blue" }, { label: "成长期", value: 26.8, tone: "green" }, { label: "成熟期", value: 34.5, tone: "purple" }, { label: "衰退期", value: 12.6, tone: "orange" }, { label: "流失期", value: 7.9, tone: "red" }],
    migration: [["升级为高价值", "2,486", "价值提升"], ["价值下降", "1,128", "需要关注"], ["价值稳定", "86.4%", "保持稳定"]],
    levels: [{ label: "普通卡", value: 53 }, { label: "银卡", value: 20 }, { label: "金卡", value: 15 }, { label: "白金卡", value: 8 }, { label: "钻石卡", value: 4 }],
    recommendation: { title: "AI 留存建议", desc: "建议面向近 60 天消费 2 次以上人群配置成长加速任务。" },
  },
  sales: {
    stats: [["今日销售额", "¥176万", "较昨日 +18.9%"], ["今日订单", "2,380", "转化率 12.6%"], ["会员客单价", "¥73.9", "较非会员高 28%"], ["复购销售占比", "62.4%", "环比 +4.1%"]],
    channels: [{ name: "小程序商城", value: 46 }, { name: "门店收银", value: 38 }, { name: "公众号商城", value: 11 }, { name: "其他", value: 5 }],
    productRanking: [{ name: "一鸣真鲜奶 950ml", value: "¥186万" }, { name: "原味风味酸奶 200g", value: "¥142万" }, { name: "经典奶香吐司", value: "¥98万" }],
    storeRanking: [{ name: "杭州西湖店", value: "¥68.4万" }, { name: "宁波鄞州店", value: "¥56.2万" }, { name: "温州鹿城店", value: "¥49.8万" }],
    recommendation: { title: "AI 销售建议", desc: "建议将高价值会员新品组合券安排在周五晚间触达。" },
  },
};

const featurePages = Object.fromEntries(
  Object.entries(FEATURE_PAGE_CONFIG).map(([pageId, config]) => [
    pageId,
    config.samples.map((name, index) => ({
      id: `${pageId}-${index + 1}`,
      name,
      owner: ["超级管理员", "会员运营组", "系统自动"][index % 3],
      scope: ["全部会员", "重点人群", "指定组织"][index % 3],
      status: ["已启用", "运行中", "待审核"][index % 3],
      enabled: index !== 2,
      updated: ["今天 14:26", "今天 10:08", "昨天 17:42"][index % 3],
    })),
  ]),
);

const domainOverviews = {
  "domain-marketing": { stats: [["执行中活动", "12", "本周新增 3 个"], ["已触达会员", "86,420", "触达率 82.6%"]], tasks: [["夏日新品会员尝鲜", "高价值活跃会员", "执行中", "68.4%"], ["沉睡会员召回计划", "低活跃待唤醒会员", "执行中", "42.8%"]] },
  "domain-loyalty": { stats: [["等级体系", "5 级", "钻石卡 5,097 人"], ["可用积分", "8,624万", "本月发放 426 万"]], tasks: [["银卡升级加速任务", "银卡会员", "执行中", "54.6%"], ["积分到期提醒", "即将到期会员", "待执行", "0%"]] },
  "domain-scrm": { stats: [["企微客户", "186,420", "净增长 6.8%"], ["活跃社群", "286", "本周新增 12 个"]], tasks: [["新品体验群运营", "12 个社群", "执行中", "72.4%"], ["社群沉默成员激活", "6,284 位成员", "待执行", "0%"]] },
  "domain-config": { stats: [["配置项", "210", "今日变更 6 项"], ["组织与权限", "346", "待审批 9 项"]], tasks: [["会员等级日终计算", "每日 02:00", "正常", "100%"], ["短信模板审核同步", "每 30 分钟", "异常", "62.0%"]] },
};

export const DEMO_DATA = {
  meta: { source: "sites-demo", tenant: { code: "demo", name: "微智演示租户", brandName: "微智" }, generatedAt: "2026-07-10T00:00:00" },
  dashboard: {
    summary: { totalMembers: "128,670", totalDelta: "2.35%", yesterdayNew: "1,258", yesterdayDelta: "8.42%", monthNew: "6,782", monthDelta: "12.31%", quarterNew: "18,934", quarterDelta: "15.62%", dailyGrowth: "+2.35%", monthlyGrowth: "+12.31%", quarterlyGrowth: "+15.62%" },
    periodLabel: "2026-05-15 至 2026-06-14",
    periodSummary: { total: "26,843", comparison: "+12.31%", dailyAverage: "1,790", peakMembers: "2,356", peakDay: "06-06" },
    totalMembers: 128670,
    totalMembersLabel: "128,670",
    sourceTotal: "26,843",
    trends30,
    trends90,
    levels,
    sourceRows: [["小程序商城", "12,456", 46.37, "blue"], ["门店扫码注册", "6,782", 25.24, "green"], ["公众号", "4,215", 15.68, "orange"], ["员工邀请", "2,156", 8.03, "purple"], ["其他渠道", "1,234", 4.58, "gray"]],
    portraitBars: [{ name: "18-24", value: 14 }, { name: "25-34", value: 40 }, { name: "35-44", value: 27 }, { name: "45-54", value: 12 }, { name: "55+", value: 7 }],
    portrait: { gender: [{ name: "男", value: 61.32 }, { name: "女", value: 38.68 }], active: [{ name: "高活跃", value: 32.45 }, { name: "中活跃", value: 41.23 }, { name: "低活跃", value: 26.32 }], valueData: [{ name: "高价值", value: 18.62 }, { name: "中价值", value: 43.28 }, { name: "低价值", value: 38.1 }], city: [{ name: "杭州", value: 42.18 }, { name: "宁波", value: 18.72 }, { name: "温州", value: 12.35 }, { name: "绍兴", value: 8.96 }], platform: [{ name: "微信小程序", value: 72.45 }, { name: "公众号", value: 18.37 }, { name: "APP", value: 9.18 }] },
    valueQuadrant: { cutoffLabel: "2026-06-14", compareLabel: "对比周期 2026-05-15 至 2026-06-14", previousMembers: "22,356", currentMembers: "25,843", salesTotal: "1,562,748 元", boxes: [{ title: "重要保持", value: "8,342人", note: "24%", className: "keep", previous: "7,125", spend: "842,635 元" }, { title: "重要发展", value: "6,175人", note: "18%", className: "grow", previous: "5,246", spend: "512,635 元" }, { title: "一般保持", value: "7,856人", note: "30.36%", className: "normal", previous: "6,246", spend: "392,635 元" }, { title: "低价值挽回", value: "3,470人", note: "13.46%", className: "winback", previous: "3,739", spend: "142,635 元" }] },
  },
  members,
  highValueMembers,
  logRows,
  segments,
  tags,
  tagScenes,
  tagLogRows: logRows.map((row, index) => ({ time: row.time, member: row.member, tag: ["待唤醒会员", "高价值会员", "新品偏好"][index], change: index === 2 ? "移除" : "新增", source: row.channel, operator: row.operator })),
  products,
  orders,
  wechatConversations,
  wechatMessages: [{ id: 1, side: "left", author: "营优教育", time: "06/15 14:26:18", text: "您好，想确认一下会员系统的登录方式。" }, { id: 2, side: "right", author: "我", time: "06/15 14:27:02", text: "可以使用企业微信工作台直接登录。" }],
  filterOptions: { stores: ["杭州西湖店", "宁波鄞州店", "温州鹿城店", "杭州滨江店", "绍兴越城店"], registrationRange: "2026-06-01 至 2026-06-15" },
  clawInsightCards: [{ title: "新增趋势上升", desc: "本月新增会员 6,782 人，较上月增长 12.31%。", tone: "green" }, { title: "高价值会员占比偏低", desc: "高价值会员占 18.62%，建议加强分层运营。", tone: "orange" }, { title: "会员活跃度下降", desc: "低活跃会员占比 26.32%，建议及时触达唤醒。", tone: "purple" }],
  clawSuggestionCards: [{ title: "针对重要发展会员", desc: "推送成长型会员礼包，提升升级效率。", action: "去执行", expected: "4.8%", tone: "blue" }, { title: "优化会员等级权益", desc: "升级银卡 / 金卡权益激励，促进成长。", action: "去配置", expected: "6.2%", tone: "green" }, { title: "沉睡会员唤醒计划", desc: "基于最后活跃时间触达，提升复购。", action: "去创建", expected: "9.1%", tone: "orange" }],
  clawPromptTemplates: [{ scene: "增长复盘", prompt: "本月新增会员来源占比如何？", owner: "会员运营组", used: 128 }, { scene: "趋势追踪", prompt: "近 7 天新增趋势怎么样？", owner: "超级管理员", used: 96 }, { scene: "价值洞察", prompt: "高价值会员的消费特征是什么？", owner: "数据分析组", used: 84 }],
  clawToolEntrances: [{ label: "数据洞察", question: "本月新增会员来源占比如何？", hint: "直接拉取关键指标和异常点" }, { label: "生成方案", question: "帮我生成高价值会员提升方案", hint: "输出可落地的运营动作" }, { label: "创建任务", question: "把沉睡会员唤醒计划生成执行任务", hint: "拆成对象、触达和复盘节点" }],
  clawScopeOptions: ["近7天", "近30天", "本月", "高价值会员"],
  clawFollowUps: ["按门店拆一下表现", "给出三条执行建议", "转成运营任务清单", "补充风险提醒"],
  clawTrend: [{ day: "06-09", insight: 68, suggestion: 42 }, { day: "06-10", insight: 72, suggestion: 48 }, { day: "06-11", insight: 69, suggestion: 46 }, { day: "06-12", insight: 78, suggestion: 52 }, { day: "06-13", insight: 86, suggestion: 58 }, { day: "06-14", insight: 82, suggestion: 55 }, { day: "06-15", insight: 91, suggestion: 63 }],
  fanTrend: trends30.map((row) => ({ day: row.day, new: row.members, lost: 90, active: row.members + 3500 })),
  memberTrend: [{ month: "1月", active: 62, retention: 71, value: 58 }, { month: "2月", active: 64, retention: 73, value: 61 }, { month: "3月", active: 68, retention: 75, value: 64 }, { month: "4月", active: 65, retention: 74, value: 66 }, { month: "5月", active: 72, retention: 78, value: 69 }, { month: "6月", active: 76, retention: 81, value: 74 }],
  salesTrend: trends30.map((row, index) => ({ day: row.day, sales: 128 + index * 8, orders: 1860 + index * 90, avg: 68.8 + index })),
  insights,
  ltvModel: { asOf: "2026-06-14", stages: [], nodes: [] },
  featurePages,
  domainOverviews,
};
