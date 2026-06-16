import { useMemo, useState } from "react";
import { createPortal } from "react-dom";
import {
  IconActivity,
  IconAdjustments,
  IconArrowDownRight,
  IconArrowUpRight,
  IconBolt,
  IconBox,
  IconBrandWechat,
  IconBuildingStore,
  IconCalendar,
  IconChartBar,
  IconChartDonut,
  IconCheck,
  IconChevronDown,
  IconChevronRight,
  IconClipboardData,
  IconClock,
  IconDatabaseExport,
  IconDeviceMobile,
  IconDiscount2,
  IconEdit,
  IconEye,
  IconFileInvoice,
  IconFilter,
  IconHistory,
  IconHeartHandshake,
  IconIdBadge2,
  IconLink,
  IconLock,
  IconMessageCircle,
  IconMicrophone,
  IconMoodSmile,
  IconPackage,
  IconPaperclip,
  IconPhoto,
  IconPinned,
  IconPlus,
  IconRefresh,
  IconSearch,
  IconSend2,
  IconSettings,
  IconSpeakerphone,
  IconShoppingBag,
  IconSparkles,
  IconTag,
  IconTargetArrow,
  IconTrash,
  IconUserCheck,
  IconUsers,
  IconUsersGroup,
  IconCode,
  IconX,
} from "@tabler/icons-react";
import {
  Area,
  AreaChart,
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  Line,
  LineChart,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { FEATURE_PAGE_CONFIG } from "./navigationConfig.jsx";

const highValueMembers = [
  { name: "林晓然", id: "M202606130021", level: "钻石卡", value: "¥28,640", orders: 32, last: "2 小时前", store: "杭州西湖店", score: 96, trend: "+12.8%" },
  { name: "顾言溪", id: "M202604230192", level: "钻石卡", value: "¥24,980", orders: 28, last: "昨天", store: "宁波鄞州店", score: 93, trend: "+8.6%" },
  { name: "沈清禾", id: "M202603180087", level: "白金卡", value: "¥19,520", orders: 21, last: "3 天前", store: "绍兴越城店", score: 89, trend: "+6.2%" },
  { name: "周子墨", id: "M202605090115", level: "金卡", value: "¥16,730", orders: 19, last: "5 天前", store: "温州鹿城店", score: 86, trend: "+4.9%" },
  { name: "许星遥", id: "M202601210246", level: "金卡", value: "¥15,410", orders: 18, last: "7 天前", store: "台州椒江店", score: 82, trend: "-1.3%" },
];

const logRows = [
  { time: "2026-06-15 14:32", member: "林晓然", action: "会员等级变更", detail: "白金卡升级为钻石卡", operator: "系统自动", channel: "等级引擎" },
  { time: "2026-06-15 13:18", member: "周子墨", action: "优惠券发放", detail: "发放夏日满减券 ¥20", operator: "超级管理员", channel: "运营后台" },
  { time: "2026-06-15 11:05", member: "陈安宁", action: "标签变更", detail: "新增标签：待唤醒会员", operator: "AI 分群任务", channel: "标签引擎" },
  { time: "2026-06-15 09:46", member: "吴嘉言", action: "资料更新", detail: "更新归属门店为杭州滨江店", operator: "门店店长", channel: "门店端" },
  { time: "2026-06-14 18:21", member: "沈清禾", action: "账户冻结", detail: "异常登录触发临时冻结", operator: "风控系统", channel: "安全中心" },
  { time: "2026-06-14 16:10", member: "许星遥", action: "积分变更", detail: "订单完成增加 860 积分", operator: "订单系统", channel: "积分引擎" },
];

const initialSegments = [
  { id: 1, name: "高价值活跃会员", desc: "近 90 天消费 ≥ 3000 元，且 30 天内有消费", members: 8342, type: "动态分群", status: true, updated: "今天 10:24", color: "blue" },
  { id: 2, name: "低活跃待唤醒会员", desc: "60 天未消费，历史消费次数 ≥ 3 次", members: 6175, type: "动态分群", status: true, updated: "今天 09:12", color: "orange" },
  { id: 3, name: "近 30 天新会员", desc: "注册时间在近 30 天内的有效会员", members: 26843, type: "系统分群", status: true, updated: "每日更新", color: "green" },
  { id: 4, name: "门店重点维护会员", desc: "由门店人工加入的重点跟进会员", members: 1256, type: "静态分群", status: false, updated: "06-12 17:40", color: "purple" },
];

const initialTags = [
  { id: 1, name: "高价值会员", category: "价值标签", coverage: 18620, rules: 3, updated: "今天 10:24", color: "blue", enabled: true },
  { id: 2, name: "待唤醒会员", category: "活跃标签", coverage: 26320, rules: 2, updated: "今天 09:12", color: "orange", enabled: true },
  { id: 3, name: "新品偏好", category: "偏好标签", coverage: 12580, rules: 5, updated: "昨天 16:35", color: "purple", enabled: true },
  { id: 4, name: "价格敏感", category: "行为标签", coverage: 8940, rules: 4, updated: "昨天 14:20", color: "green", enabled: true },
  { id: 5, name: "门店自提", category: "渠道标签", coverage: 34150, rules: 1, updated: "06-13 18:02", color: "teal", enabled: false },
  { id: 6, name: "生日会员", category: "基础标签", coverage: 10246, rules: 1, updated: "每日更新", color: "pink", enabled: true },
];

const tagLogRows = [
  { time: "2026-06-15 13:45", member: "陈安宁", tag: "待唤醒会员", change: "新增", source: "动态规则", operator: "标签引擎" },
  { time: "2026-06-15 12:10", member: "林晓然", tag: "高价值会员", change: "新增", source: "会员价值模型", operator: "AI 任务" },
  { time: "2026-06-15 10:32", member: "周子墨", tag: "价格敏感", change: "移除", source: "人工调整", operator: "超级管理员" },
  { time: "2026-06-15 09:06", member: "吴嘉言", tag: "门店自提", change: "新增", source: "订单行为", operator: "标签引擎" },
  { time: "2026-06-14 17:48", member: "许星遥", tag: "新品偏好", change: "新增", source: "浏览行为", operator: "实时任务" },
];

const initialProducts = [
  { id: "P100286", name: "一鸣真鲜奶 950ml", category: "乳制品", price: 18.8, stock: 2840, sales: 12650, status: true, updated: "今天 13:20" },
  { id: "P100315", name: "原味风味酸奶 200g", category: "酸奶", price: 8.9, stock: 1680, sales: 9432, status: true, updated: "今天 11:05" },
  { id: "P100422", name: "经典奶香吐司", category: "烘焙", price: 12.8, stock: 860, sales: 7821, status: true, updated: "昨天 17:48" },
  { id: "P100507", name: "杨枝甘露酸奶杯", category: "新品", price: 16.9, stock: 420, sales: 3560, status: true, updated: "昨天 15:33" },
  { id: "P100198", name: "高钙低脂牛奶 250ml", category: "乳制品", price: 6.5, stock: 0, sales: 18460, status: false, updated: "06-12 09:20" },
];

const initialOrders = [
  { id: "SO202606150328", member: "林晓然", amount: 186.8, items: 6, channel: "小程序商城", store: "杭州西湖店", status: "待发货", time: "2026-06-15 14:28" },
  { id: "SO202606150296", member: "周子墨", amount: 98.5, items: 3, channel: "门店收银", store: "宁波鄞州店", status: "已完成", time: "2026-06-15 13:06" },
  { id: "SO202606150241", member: "陈安宁", amount: 256.0, items: 8, channel: "小程序商城", store: "温州鹿城店", status: "配送中", time: "2026-06-15 11:42" },
  { id: "SO202606150187", member: "吴嘉言", amount: 72.6, items: 2, channel: "门店收银", store: "杭州滨江店", status: "已完成", time: "2026-06-15 10:15" },
  { id: "SO202606140936", member: "沈清禾", amount: 328.9, items: 9, channel: "公众号商城", store: "绍兴越城店", status: "退款中", time: "2026-06-14 19:38" },
  { id: "SO202606140821", member: "许星遥", amount: 126.0, items: 4, channel: "小程序商城", store: "台州椒江店", status: "待付款", time: "2026-06-14 17:12" },
];

const fanTrend = [
  { day: "06-09", new: 680, lost: 92, active: 4200 }, { day: "06-10", new: 760, lost: 108, active: 4380 },
  { day: "06-11", new: 620, lost: 85, active: 4150 }, { day: "06-12", new: 940, lost: 116, active: 4680 },
  { day: "06-13", new: 1080, lost: 103, active: 4920 }, { day: "06-14", new: 880, lost: 121, active: 4760 },
  { day: "06-15", new: 1258, lost: 98, active: 5320 },
];

const memberTrend = [
  { month: "1月", active: 62, retention: 71, value: 58 }, { month: "2月", active: 64, retention: 73, value: 61 },
  { month: "3月", active: 68, retention: 75, value: 64 }, { month: "4月", active: 65, retention: 74, value: 66 },
  { month: "5月", active: 72, retention: 78, value: 69 }, { month: "6月", active: 76, retention: 81, value: 74 },
];

const salesTrend = [
  { day: "06-09", sales: 128, orders: 1860, avg: 68.8 }, { day: "06-10", sales: 136, orders: 1920, avg: 70.8 },
  { day: "06-11", sales: 119, orders: 1760, avg: 67.6 }, { day: "06-12", sales: 152, orders: 2080, avg: 73.1 },
  { day: "06-13", sales: 168, orders: 2240, avg: 75.0 }, { day: "06-14", sales: 148, orders: 2010, avg: 73.6 },
  { day: "06-15", sales: 176, orders: 2380, avg: 73.9 },
];

const wechatConversations = [
  { id: "wechat-pay", name: "微信支付", type: "聊天", date: "2026/05/13", unread: 1, preview: "关于支付通道和客户侧提示的咨询", tone: "green", icon: "wx", pinned: true },
  { id: "yingyou", name: "营优教育", type: "聊天", date: "2026/05/13", unread: 1, preview: "客户询问系统登录微信和客户端关系", tone: "blue", icon: "text", pinned: true },
  { id: "henan-tel", name: "河南电信", type: "聊天", date: "2026/05/11", unread: 0, preview: "5G 套餐活动接入和权益兑换确认", tone: "red", icon: "5G", pinned: false },
  { id: "zz-card", name: "郑州市民卡", type: "群聊", date: "2026/05/08", unread: 0, preview: "社群活动物料已完成二次确认", tone: "orange", icon: "card", pinned: false },
  { id: "tencent-service", name: "gh_402d777f217d", type: "公众号", date: "2026/05/06", unread: 0, preview: "腾讯客服 您好，您咨询的微信服务号...", tone: "gray", icon: "none", pinned: false },
];

const initialWechatMessages = [
  { id: 1, side: "right", time: "05/14 15:32:18", text: "类似登电脑端微信一样" },
  { id: 2, side: "left", author: "小柯", time: "05/14 15:34:32", text: "那就是在你们的系统里登录的微信咯？" },
  { id: 3, side: "left", author: "小柯", time: "05/14 15:34:37", text: "不是官方的客户端？" },
  { id: 4, side: "right", time: "05/14 15:35:59", text: "我们的系统肯定不是腾讯官方的，再说腾讯也不是做这样的系统。" },
  { id: 5, side: "left", author: "小柯", time: "05/14 15:36:27", text: "那会被腾讯封号吧" },
  { id: 6, side: "right", time: "05/14 15:37:02", text: "不会封，现在在用的数量将近3000，我们自己也在用" },
];

function PageHeader({ title, subtitle, primaryLabel, primaryIcon: PrimaryIcon = IconPlus, onPrimary, actions }) {
  return (
    <div className="workspace-title">
      <div><h1>{title}</h1><p>{subtitle}</p></div>
      <div className="workspace-title__actions">{actions}{primaryLabel && <button className="primary-button" onClick={onPrimary}><PrimaryIcon size={17} />{primaryLabel}</button>}</div>
    </div>
  );
}

function StatCards({ items }) {
  return <div className="business-stats">{items.map(({ label, value, note, icon: Icon, tone = "blue" }) => <article key={label}><span className={`business-stat__icon is-${tone}`}><Icon size={20} /></span><div><small>{label}</small><strong>{value}</strong><p>{note}</p></div></article>)}</div>;
}

function SearchFilters({ query, onQuery, placeholder, children, onReset, onSearch }) {
  return (
    <section className="panel business-filters">
      <label className="business-search"><IconSearch size={17} /><input value={query} onChange={(event) => onQuery(event.target.value)} placeholder={placeholder} /></label>
      {children}
      <button className="outline-button" onClick={onReset}><IconRefresh size={16} />重置</button>
      <button className="primary-button" onClick={onSearch}><IconSearch size={16} />查询</button>
    </section>
  );
}

function Pill({ children, tone = "blue" }) {
  return <span className={`business-pill is-${tone}`}>{children}</span>;
}

function Toggle({ checked, onChange, label }) {
  return <button className={`toggle ${checked ? "is-on" : ""}`} onClick={onChange} aria-label={label} aria-pressed={checked}><i /></button>;
}

function Drawer({ open, title, subtitle, onClose, children, footer }) {
  if (!open) return null;
  return createPortal((
    <div className="drawer-shade" onMouseDown={onClose}>
      <aside className="detail-drawer" onMouseDown={(event) => event.stopPropagation()}>
        <div className="detail-drawer__head"><div><h2>{title}</h2><p>{subtitle}</p></div><button className="icon-button" onClick={onClose}><IconX size={19} /></button></div>
        <div className="detail-drawer__body">{children}</div>
        {footer && <div className="detail-drawer__footer">{footer}</div>}
      </aside>
    </div>
  ), document.body);
}

function FormDialog({ open, title, subtitle, fields, onClose, onSave, saveLabel = "保存" }) {
  const [values, setValues] = useState({});
  if (!open) return null;
  return createPortal((
    <div className="modal-backdrop" onMouseDown={onClose}>
      <div className="modal business-dialog" onMouseDown={(event) => event.stopPropagation()}>
        <div className="modal__head"><div><span className="modal-icon"><IconEdit size={20} /></span><div><h2>{title}</h2><p>{subtitle}</p></div></div><button className="icon-button" onClick={onClose}><IconX size={19} /></button></div>
        <div className="modal__body">
          {fields.map((field) => <label className={field.full ? "modal__full" : ""} key={field.key}>{field.label}{field.type === "textarea" ? <textarea value={values[field.key] || field.defaultValue || ""} onChange={(event) => setValues({ ...values, [field.key]: event.target.value })} placeholder={field.placeholder} /> : field.type === "select" ? <select value={values[field.key] || field.defaultValue || field.options[0]} onChange={(event) => setValues({ ...values, [field.key]: event.target.value })}>{field.options.map((option) => <option key={option}>{option}</option>)}</select> : <input type={field.type || "text"} value={values[field.key] || field.defaultValue || ""} onChange={(event) => setValues({ ...values, [field.key]: event.target.value })} placeholder={field.placeholder} />}</label>)}
        </div>
        <div className="modal__footer"><button className="outline-button" onClick={onClose}>取消</button><button className="primary-button" onClick={() => onSave(values)}>{saveLabel}</button></div>
      </div>
    </div>
  ), document.body);
}

function ConfirmDialog({ open, title, text, onClose, onConfirm }) {
  if (!open) return null;
  return createPortal(<div className="modal-backdrop" onMouseDown={onClose}><div className="confirm-dialog" onMouseDown={(event) => event.stopPropagation()}><span><IconLock size={25} /></span><h2>{title}</h2><p>{text}</p><div><button className="outline-button" onClick={onClose}>取消</button><button className="primary-button" onClick={onConfirm}>确认执行</button></div></div></div>, document.body);
}

function EmptyFiltered() {
  return <div className="business-empty"><IconFilter size={34} /><strong>没有符合条件的数据</strong><p>调整筛选条件后重新查询</p></div>;
}

function WechatAvatar({ item, compact = false }) {
  const content = item.icon === "wx" ? <IconBrandWechat size={compact ? 18 : 23} /> : item.icon === "text" ? "营优" : item.icon;
  return <span className={`wechat-avatar is-${item.tone} ${compact ? "is-compact" : ""}`}>{content}</span>;
}

function WechatChatPage({ onToast }) {
  const [query, setQuery] = useState("");
  const [activeTab, setActiveTab] = useState("聊天框");
  const [activeType, setActiveType] = useState("聊天");
  const [dayFilter, setDayFilter] = useState("今日");
  const [selectedId, setSelectedId] = useState("yingyou");
  const [pinned, setPinned] = useState(true);
  const [draft, setDraft] = useState("");
  const [messages, setMessages] = useState(initialWechatMessages);
  const filteredConversations = wechatConversations.filter((item) => {
    const typeMatched = activeTab === "未读" ? item.unread > 0 : activeTab === "通讯录" ? true : activeType === "全部" || item.type === activeType;
    return typeMatched && `${item.name}${item.preview}`.includes(query);
  });
  const selected = wechatConversations.find((item) => item.id === selectedId) || wechatConversations[0];
  const sendMessage = () => {
    const text = draft.trim();
    if (!text) {
      onToast("请输入要发送的消息");
      return;
    }
    setMessages((current) => [...current, { id: Date.now(), side: "right", time: "刚刚", text }]);
    setDraft("");
    onToast("微信消息已发送");
  };
  return (
    <section className="wechat-chat-page" aria-label="微信聊天会话">
      <aside className="wechat-session-list">
        <div className="wechat-search-row">
          <label><IconSearch size={16} /><input value={query} onChange={(event) => setQuery(event.target.value)} placeholder="搜索昵称、备注" /></label>
          <button onClick={() => { setQuery(""); onToast("会话列表已刷新"); }} aria-label="刷新会话"><IconRefresh size={18} /></button>
        </div>
        <div className="wechat-main-tabs">
          {["聊天框", "通讯录", "未读"].map((tab) => <button className={activeTab === tab ? "is-active" : ""} key={tab} onClick={() => setActiveTab(tab)}>{tab}</button>)}
        </div>
        <div className="wechat-type-tabs">
          {["聊天", "群聊", "公众号"].map((type) => <button className={activeType === type ? "is-active" : ""} key={type} onClick={() => { setActiveType(type); setActiveTab("聊天框"); }}>{type}{type === "聊天" ? "(686)" : type === "群聊" ? "(25)" : ""}</button>)}
        </div>
        <div className="wechat-conversation-scroll">
          {filteredConversations.map((conversation) => (
            <button className={`wechat-conversation ${selectedId === conversation.id ? "is-active" : ""}`} key={conversation.id} onClick={() => setSelectedId(conversation.id)}>
              {!!conversation.unread && <span className="wechat-unread">{conversation.unread}</span>}
              <WechatAvatar item={conversation} />
              <span><strong>{conversation.name}</strong><small>{conversation.preview}</small></span>
              <time>{conversation.date}</time>
            </button>
          ))}
          {!filteredConversations.length && <div className="wechat-empty"><IconMessageCircle size={28} /><strong>暂无会话</strong><small>换个关键词或类型试试</small></div>}
        </div>
      </aside>
      <main className="wechat-chat-workspace">
        <header className="wechat-chat-toolbar">
          <div className="wechat-chat-tools-left">
            <WechatAvatar item={selected} compact />
            <button className={`wechat-pin ${pinned ? "is-on" : ""}`} onClick={() => { setPinned((value) => !value); onToast(pinned ? "已取消置顶" : "已置顶当前会话"); }}><IconPinned size={14} />置顶</button>
            <button className="wechat-tag-button" onClick={() => onToast("已打开客户标签")}>客户标签</button>
            <div className="wechat-date-segment">{["今日", "昨日", "前天"].map((item) => <button className={dayFilter === item ? "is-active" : ""} key={item} onClick={() => setDayFilter(item)}>{item}</button>)}</div>
            <span className="wechat-reply-stat">3分钟回复率：<strong>100%</strong></span>
            <span className="wechat-reply-stat">平均回复时长：<strong>42.95 秒</strong></span>
          </div>
          <div className="wechat-chat-tools-right">
            <button onClick={() => onToast("已打开会话质检视图")} aria-label="查看"><IconEye size={19} /></button>
            <button onClick={() => onToast("已切换会话布局")} aria-label="布局"><IconDeviceMobile size={19} /></button>
            <button onClick={() => onToast("已打开关联订单")} aria-label="订单"><IconBox size={19} /></button>
          </div>
        </header>
        <section className="wechat-message-board">
          {messages.map((message) => (
            <div className={`wechat-message-row is-${message.side}`} key={message.id}>
              {message.side === "left" && <span className="wechat-user-photo">小</span>}
              <div className="wechat-message-body">
                {message.side === "left" && <small>{message.author} {message.time}</small>}
                {message.side === "right" && <small>{message.time}</small>}
                <p>{message.text}</p>
              </div>
              {message.side === "right" && <span className="wechat-user-photo is-self">超</span>}
            </div>
          ))}
        </section>
        <footer className="wechat-composer">
          <div className="wechat-composer-tools">
            {[
              [IconClipboardData, "快捷话术"],
              [IconMoodSmile, "表情"],
              [IconPhoto, "图片"],
              [IconMicrophone, "语音"],
              [IconDeviceMobile, "视频"],
              [IconPaperclip, "文件"],
              [IconLink, "链接"],
              [IconSparkles, "AI 改写"],
            ].map(([Icon, label]) => <button key={label} onClick={() => onToast(`${label}面板已打开`)} title={label}><Icon size={18} /></button>)}
          </div>
          <textarea value={draft} onChange={(event) => setDraft(event.target.value)} onKeyDown={(event) => { if (event.key === "Enter" && !event.ctrlKey && !event.shiftKey) { event.preventDefault(); sendMessage(); } }} placeholder="输入消息" />
          <div className="wechat-send-row"><span>Ctrl+Enter 可换行</span><button onClick={sendMessage}><IconSend2 size={16} />发送(Enter)</button></div>
        </footer>
      </main>
    </section>
  );
}

function HighValuePage({ onToast, onAction }) {
  const [query, setQuery] = useState("");
  const [selected, setSelected] = useState(null);
  const rows = highValueMembers.filter((item) => `${item.name}${item.id}${item.store}`.includes(query));
  return (
    <section className="business-page">
      <PageHeader title="高贡献会员" subtitle="聚焦高价值、高频次和高成长会员，提供专属运营策略" primaryLabel="创建专属人群" primaryIcon={IconUsersGroup} onPrimary={() => onAction("创建分群")} actions={<button className="outline-button" onClick={() => onToast("高贡献会员名单已加入导出任务")}><IconDatabaseExport size={16} />导出名单</button>} />
      <StatCards items={[{ label: "高贡献会员", value: "18,620", note: "占总会员 14.47%", icon: IconTargetArrow }, { label: "近 30 天消费", value: "¥8,452万", note: "环比增长 12.8%", icon: IconShoppingBag, tone: "green" }, { label: "人均消费", value: "¥4,539", note: "高于整体 3.6 倍", icon: IconChartBar, tone: "orange" }, { label: "复购率", value: "78.6%", note: "较上月提升 4.2%", icon: IconRefresh, tone: "purple" }]} />
      <SearchFilters query={query} onQuery={setQuery} placeholder="搜索会员名称、编码或归属门店" onReset={() => setQuery("")} onSearch={() => onToast(`已找到 ${rows.length} 位高贡献会员`)}><select><option>全部等级</option><option>钻石卡</option><option>白金卡</option><option>金卡</option></select><select><option>全部价值区间</option><option>消费 ≥ ¥20,000</option><option>消费 ¥10,000 - ¥20,000</option></select></SearchFilters>
      <section className="panel business-table-card"><div className="business-table-head"><div><h2>会员价值排行</h2><p>基于消费、活跃、复购和成长综合评分</p></div><button className="quiet-button"><IconAdjustments size={15} />评分规则</button></div><div className="table-scroll"><table><thead><tr><th>排名</th><th>会员</th><th>等级</th><th>累计贡献</th><th>订单数</th><th>最近消费</th><th>归属门店</th><th>价值评分</th><th>趋势</th><th>操作</th></tr></thead><tbody>{rows.map((item, index) => <tr key={item.id}><td><span className={`rank-number is-${index + 1}`}>{index + 1}</span></td><td><div className="member-cell"><span>{item.name.slice(0, 1)}</span><div><strong>{item.name}</strong><small>{item.id}</small></div></div></td><td><Pill tone="purple">{item.level}</Pill></td><td><strong>{item.value}</strong></td><td>{item.orders}</td><td>{item.last}</td><td>{item.store}</td><td><div className="score-cell"><b>{item.score}</b><i><span style={{ width: `${item.score}%` }} /></i></div></td><td><span className={item.trend.startsWith("+") ? "positive-text" : "negative-text"}>{item.trend}</span></td><td><button className="table-link" onClick={() => setSelected(item)}>查看画像</button></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered />}</div></section>
      <Drawer open={!!selected} title={selected?.name || ""} subtitle={`${selected?.id || ""} · 高贡献会员画像`} onClose={() => setSelected(null)} footer={<><button className="outline-button" onClick={() => onToast("已记录跟进任务")}>创建跟进</button><button className="primary-button" onClick={() => onAction("发放优惠券")}><IconDiscount2 size={16} />发放专属权益</button></>}><div className="drawer-profile"><span>{selected?.name.slice(0,1)}</span><div><strong>{selected?.level}</strong><p>{selected?.store}</p></div></div><div className="drawer-metrics"><div><small>价值评分</small><strong>{selected?.score}</strong></div><div><small>累计贡献</small><strong>{selected?.value}</strong></div><div><small>订单数</small><strong>{selected?.orders}</strong></div></div><h3>关键标签</h3><div className="tag-cloud"><Pill>高价值会员</Pill><Pill tone="green">高复购</Pill><Pill tone="orange">新品偏好</Pill><Pill tone="purple">小程序活跃</Pill></div><h3>AI 运营建议</h3><div className="drawer-insight"><IconSparkles size={20} /><p>该会员近期消费保持增长，建议发放新品优先体验权益，并安排门店专属顾问在 7 天内完成一次关怀触达。</p></div></Drawer>
    </section>
  );
}

function LogsPage({ onToast }) {
  const [query, setQuery] = useState("");
  const [type, setType] = useState("全部类型");
  const [selected, setSelected] = useState(null);
  const rows = logRows.filter((row) => (!query || `${row.member}${row.detail}${row.operator}`.includes(query)) && (type === "全部类型" || row.action === type));
  return <section className="business-page"><PageHeader title="会员日志" subtitle="追踪会员资料、等级、权益、积分和账户状态的全部变更" actions={<button className="outline-button" onClick={() => onToast("会员日志已导出")}><IconDatabaseExport size={16} />导出日志</button>} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索会员、操作人或变更内容" onReset={() => { setQuery(""); setType("全部类型"); }} onSearch={() => onToast(`已筛选 ${rows.length} 条日志`)}><select value={type} onChange={(event) => setType(event.target.value)}><option>全部类型</option><option>会员等级变更</option><option>优惠券发放</option><option>标签变更</option><option>资料更新</option><option>账户冻结</option><option>积分变更</option></select><button className="business-date"><IconCalendar size={15} />2026-06-01 至 2026-06-15</button></SearchFilters><section className="panel business-table-card"><div className="business-table-head"><div><h2>操作记录</h2><p>所有关键变更均保留操作来源与执行人</p></div><span className="record-count">共 {rows.length} 条</span></div><div className="table-scroll"><table><thead><tr><th>操作时间</th><th>会员</th><th>操作类型</th><th>变更内容</th><th>操作人</th><th>来源</th><th>操作</th></tr></thead><tbody>{rows.map((row) => <tr key={`${row.time}-${row.member}`}><td>{row.time}</td><td><strong>{row.member}</strong></td><td><Pill tone={row.action.includes("冻结") ? "red" : row.action.includes("发放") ? "orange" : "blue"}>{row.action}</Pill></td><td>{row.detail}</td><td>{row.operator}</td><td>{row.channel}</td><td><button className="table-link" onClick={() => setSelected(row)}>详情</button></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered />}</div></section><Drawer open={!!selected} title="日志详情" subtitle={selected?.time || ""} onClose={() => setSelected(null)}><div className="detail-list"><div><span>会员</span><strong>{selected?.member}</strong></div><div><span>操作类型</span><strong>{selected?.action}</strong></div><div><span>变更内容</span><strong>{selected?.detail}</strong></div><div><span>操作人</span><strong>{selected?.operator}</strong></div><div><span>操作来源</span><strong>{selected?.channel}</strong></div><div><span>日志编号</span><strong>LOG-{selected?.time.replace(/\D/g, "")}</strong></div></div><h3>操作链路</h3><div className="log-timeline"><div><i /><strong>触发变更</strong><small>{selected?.channel}</small></div><div><i /><strong>规则校验通过</strong><small>系统自动完成</small></div><div><i /><strong>数据写入成功</strong><small>{selected?.time}</small></div></div></Drawer></section>;
}

function SegmentsPage({ onToast }) {
  const [segments, setSegments] = useState(initialSegments);
  const [query, setQuery] = useState("");
  const [dialog, setDialog] = useState(false);
  const [selected, setSelected] = useState(null);
  const rows = segments.filter((item) => item.name.includes(query));
  const save = (values) => { const name = values.name || `新建会员分组 ${segments.length + 1}`; setSegments([{ id: Date.now(), name, desc: values.rule || "满足指定会员条件的动态分组", members: 0, type: values.type || "动态分群", status: true, updated: "刚刚", color: "blue" }, ...segments]); setDialog(false); onToast(`分组“${name}”已创建`); };
  return <section className="business-page"><PageHeader title="会员分组" subtitle="通过规则或人工选择建立可持续运营的会员人群" primaryLabel="新建分组" primaryIcon={IconUsersGroup} onPrimary={() => setDialog(true)} actions={<button className="outline-button" onClick={() => onToast("分群数据已同步") }><IconRefresh size={16} />立即同步</button>} /><StatCards items={[{ label: "分组总数", value: String(segments.length), note: "3 个动态分群", icon: IconUsersGroup }, { label: "已覆盖会员", value: "42,616", note: "覆盖率 33.12%", icon: IconUsers, tone: "green" }, { label: "今日更新", value: "18,942", note: "规则计算完成", icon: IconRefresh, tone: "orange" }, { label: "待执行任务", value: "3", note: "2 个营销任务", icon: IconBolt, tone: "purple" }]} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索分组名称" onReset={() => setQuery("")} onSearch={() => onToast(`已找到 ${rows.length} 个会员分组`)}><select><option>全部类型</option><option>动态分群</option><option>静态分群</option><option>系统分群</option></select><select><option>全部状态</option><option>启用</option><option>停用</option></select></SearchFilters><div className="segment-grid">{rows.map((item) => <article className="segment-card" key={item.id}><div className="segment-card__head"><span className={`segment-icon is-${item.color}`}><IconUsersGroup size={22} /></span><Toggle checked={item.status} label={`${item.name}状态`} onChange={() => setSegments((current) => current.map((segment) => segment.id === item.id ? { ...segment, status: !segment.status } : segment))} /></div><h2>{item.name}</h2><p>{item.desc}</p><div className="segment-card__meta"><span><strong>{item.members.toLocaleString()}</strong> 位会员</span><Pill tone={item.type === "动态分群" ? "blue" : item.type === "系统分群" ? "green" : "purple"}>{item.type}</Pill></div><div className="segment-card__foot"><small>更新：{item.updated}</small><div><button onClick={() => setSelected(item)}><IconEye size={16} /></button><button onClick={() => { setSelected(item); onToast("可在详情中调整分群规则"); }}><IconEdit size={16} /></button></div></div></article>)}{!rows.length && <EmptyFiltered />}</div><FormDialog open={dialog} title="新建会员分组" subtitle="设置人群名称与筛选规则" onClose={() => setDialog(false)} onSave={save} fields={[{ key: "name", label: "分组名称", placeholder: "例如：高潜力新会员" }, { key: "type", label: "分组类型", type: "select", options: ["动态分群", "静态分群"] }, { key: "rule", label: "分组规则", type: "textarea", full: true, placeholder: "例如：注册 30 天内，且累计消费金额 ≥ 300 元" }]} /><Drawer open={!!selected} title={selected?.name || ""} subtitle={`${selected?.type || ""} · ${selected?.members.toLocaleString() || 0} 位会员`} onClose={() => setSelected(null)} footer={<><button className="outline-button" onClick={() => onToast("分群名单已导出")}>导出名单</button><button className="primary-button" onClick={() => onToast("营销任务创建成功")}>创建营销任务</button></>}><h3>分群规则</h3><div className="rule-builder"><div><span>近 90 天消费金额</span><b>大于等于</b><strong>¥3,000</strong></div><div><span>最近消费时间</span><b>小于等于</b><strong>30 天</strong></div><div><span>会员状态</span><b>等于</b><strong>正常</strong></div></div><h3>人群概览</h3><div className="drawer-metrics"><div><small>会员数</small><strong>{selected?.members.toLocaleString()}</strong></div><div><small>平均客单</small><strong>¥268</strong></div><div><small>复购率</small><strong>68.4%</strong></div></div><h3>关联任务</h3><div className="linked-task"><IconDiscount2 size={18} /><div><strong>高价值会员月度关怀</strong><small>执行中 · 已触达 6,824 人</small></div><IconChevronRight size={16} /></div></Drawer></section>;
}

function TagsPage({ onToast }) {
  const [tags, setTags] = useState(initialTags);
  const [query, setQuery] = useState("");
  const [dialog, setDialog] = useState(false);
  const [selected, setSelected] = useState(null);
  const rows = tags.filter((tag) => `${tag.name}${tag.category}`.includes(query));
  const save = (values) => { const name = values.name || `新标签 ${tags.length + 1}`; setTags([{ id: Date.now(), name, category: values.category || "行为标签", coverage: 0, rules: 1, updated: "刚刚", color: "blue", enabled: true }, ...tags]); setDialog(false); onToast(`标签“${name}”已创建`); };
  return <section className="business-page"><PageHeader title="会员标签" subtitle="统一管理会员属性、行为、偏好、价值和渠道标签" primaryLabel="新建标签" primaryIcon={IconTag} onPrimary={() => setDialog(true)} actions={<button className="outline-button" onClick={() => onToast("标签规则已重新计算")}><IconRefresh size={16} />重新计算</button>} /><StatCards items={[{ label: "标签总数", value: "86", note: "启用 72 个", icon: IconTag }, { label: "今日命中", value: "38,426", note: "较昨日 +8.2%", icon: IconTargetArrow, tone: "green" }, { label: "自动标签", value: "54", note: "实时规则 21 个", icon: IconSparkles, tone: "purple" }, { label: "待处理异常", value: "2", note: "规则执行超时", icon: IconActivity, tone: "orange" }]} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索标签名称或分类" onReset={() => setQuery("")} onSearch={() => onToast(`已找到 ${rows.length} 个标签`)}><select><option>全部分类</option><option>价值标签</option><option>活跃标签</option><option>偏好标签</option><option>行为标签</option></select><select><option>全部状态</option><option>启用</option><option>停用</option></select></SearchFilters><section className="panel tag-library"><div className="business-table-head"><div><h2>标签库</h2><p>点击标签可查看规则和覆盖人群</p></div><span className="record-count">{rows.length} 个标签</span></div><div className="tag-grid">{rows.map((tag) => <article key={tag.id} onClick={() => setSelected(tag)}><div><span className={`tag-library__icon is-${tag.color}`}><IconTag size={19} /></span><Toggle checked={tag.enabled} label={`${tag.name}状态`} onChange={(event) => { event.stopPropagation(); setTags((current) => current.map((item) => item.id === tag.id ? { ...item, enabled: !item.enabled } : item)); }} /></div><h3>{tag.name}</h3><Pill tone={tag.color === "pink" ? "red" : tag.color}>{tag.category}</Pill><dl><div><dt>覆盖会员</dt><dd>{tag.coverage.toLocaleString()}</dd></div><div><dt>规则数</dt><dd>{tag.rules}</dd></div></dl><small>更新：{tag.updated}</small></article>)}</div></section><FormDialog open={dialog} title="新建会员标签" subtitle="创建标签并配置基础规则" onClose={() => setDialog(false)} onSave={save} fields={[{ key: "name", label: "标签名称", placeholder: "例如：高频到店会员" }, { key: "category", label: "标签分类", type: "select", options: ["行为标签", "价值标签", "活跃标签", "偏好标签", "渠道标签"] }, { key: "description", label: "标签说明", type: "textarea", full: true, placeholder: "说明标签的业务含义和使用场景" }]} /><Drawer open={!!selected} title={selected?.name || ""} subtitle={`${selected?.category || ""} · 覆盖 ${selected?.coverage.toLocaleString() || 0} 位会员`} onClose={() => setSelected(null)} footer={<><button className="outline-button" onClick={() => onToast("标签规则已进入编辑状态")}><IconEdit size={16} />编辑规则</button><button className="primary-button" onClick={() => onToast("标签人群已同步至分群")}>创建人群</button></>}><h3>标签说明</h3><p className="drawer-copy">系统根据会员交易、活跃和渠道行为自动计算该标签，每日更新一次，关键事件实时更新。</p><h3>命中规则</h3><div className="rule-builder"><div><span>累计消费金额</span><b>大于</b><strong>¥3,000</strong></div><div><span>近 90 天订单数</span><b>大于等于</b><strong>5 单</strong></div></div><h3>覆盖趋势</h3><div className="tag-trend-mini"><IconArrowUpRight size={20} /><strong>近 7 天增加 1,268 人</strong><small>增长 7.3%</small></div></Drawer></section>;
}

function TagScenesPage({ onToast }) {
  const available = ["高价值会员", "待唤醒会员", "新品偏好", "价格敏感", "门店自提", "生日会员"];
  const [scenes, setScenes] = useState([{ id: 1, name: "首页会员概览", module: "用户数据", desc: "用于首页关键指标的人群筛选", tags: ["高价值会员", "待唤醒会员"], enabled: true }, { id: 2, name: "优惠券精准发放", module: "营销管理", desc: "发券任务创建时的人群筛选", tags: ["价格敏感", "生日会员"], enabled: true }, { id: 3, name: "新品推荐", module: "营销管理", desc: "新品上市时的推荐目标人群", tags: ["新品偏好", "高价值会员"], enabled: true }, { id: 4, name: "门店运营看板", module: "企业管理", desc: "门店会员结构和到店行为分析", tags: ["门店自提"], enabled: false }]);
  const [editing, setEditing] = useState(null);
  const [draftTags, setDraftTags] = useState([]);
  const open = (scene) => { setEditing(scene); setDraftTags(scene.tags); };
  const save = () => { setScenes((current) => current.map((scene) => scene.id === editing.id ? { ...scene, tags: draftTags } : scene)); setEditing(null); onToast("场景标签分配已保存"); };
  return <section className="business-page"><PageHeader title="标签场景分配" subtitle="将标签配置到看板、营销、门店和自动化任务等业务场景" actions={<button className="outline-button" onClick={() => onToast("场景配置已同步到各业务模块")}><IconRefresh size={16} />同步配置</button>} /><div className="scene-grid">{scenes.map((scene) => <article className="scene-card panel" key={scene.id}><div className="scene-card__head"><span><IconAdjustments size={21} /></span><Toggle checked={scene.enabled} label={`${scene.name}状态`} onChange={() => setScenes((current) => current.map((item) => item.id === scene.id ? { ...item, enabled: !item.enabled } : item))} /></div><Pill tone="blue">{scene.module}</Pill><h2>{scene.name}</h2><p>{scene.desc}</p><div className="tag-cloud">{scene.tags.map((tag) => <Pill key={tag} tone="purple">{tag}</Pill>)}{!scene.tags.length && <small>暂未分配标签</small>}</div><button className="scene-card__button" onClick={() => open(scene)}><IconEdit size={16} />配置标签</button></article>)}</div><Drawer open={!!editing} title="配置场景标签" subtitle={`${editing?.module || ""} · ${editing?.name || ""}`} onClose={() => setEditing(null)} footer={<><button className="outline-button" onClick={() => setEditing(null)}>取消</button><button className="primary-button" onClick={save}><IconCheck size={16} />保存分配</button></>}><h3>可用标签</h3><div className="check-list">{available.map((tag) => <label key={tag}><input type="checkbox" checked={draftTags.includes(tag)} onChange={() => setDraftTags((current) => current.includes(tag) ? current.filter((item) => item !== tag) : [...current, tag])} /><span><IconTag size={16} />{tag}</span></label>)}</div><h3>应用说明</h3><p className="drawer-copy">选中的标签将出现在该业务场景的人群筛选器中。取消分配不会删除标签或影响已经保存的历史任务。</p></Drawer></section>;
}

function TagLogsPage({ onToast }) {
  const [query, setQuery] = useState("");
  const [change, setChange] = useState("全部变更");
  const rows = tagLogRows.filter((row) => (!query || `${row.member}${row.tag}${row.operator}`.includes(query)) && (change === "全部变更" || row.change === change));
  return <section className="business-page"><PageHeader title="会员标签变更日志" subtitle="查看标签命中、移除和人工调整的完整记录" actions={<button className="outline-button" onClick={() => onToast("标签变更日志已导出")}><IconDatabaseExport size={16} />导出日志</button>} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索会员、标签或操作人" onReset={() => { setQuery(""); setChange("全部变更"); }} onSearch={() => onToast(`已筛选 ${rows.length} 条记录`)}><select value={change} onChange={(event) => setChange(event.target.value)}><option>全部变更</option><option>新增</option><option>移除</option></select><button className="business-date"><IconCalendar size={15} />近 30 天</button></SearchFilters><section className="panel business-table-card"><div className="business-table-head"><div><h2>标签变更记录</h2><p>自动规则与人工操作均可追溯</p></div><span className="record-count">共 {rows.length} 条</span></div><div className="table-scroll"><table><thead><tr><th>变更时间</th><th>会员</th><th>标签</th><th>变更类型</th><th>触发来源</th><th>操作人</th><th>结果</th></tr></thead><tbody>{rows.map((row) => <tr key={`${row.time}-${row.member}`}><td>{row.time}</td><td><strong>{row.member}</strong></td><td><Pill tone="purple">{row.tag}</Pill></td><td><Pill tone={row.change === "新增" ? "green" : "red"}>{row.change}</Pill></td><td>{row.source}</td><td>{row.operator}</td><td><span className="result-success"><IconCheck size={14} />成功</span></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered />}</div></section></section>;
}

function ProductsPage({ onToast }) {
  const [products, setProducts] = useState(initialProducts);
  const [query, setQuery] = useState("");
  const [dialog, setDialog] = useState(false);
  const [selected, setSelected] = useState(null);
  const rows = products.filter((product) => `${product.name}${product.id}${product.category}`.includes(query));
  const save = (values) => { const product = { id: `P${Date.now().toString().slice(-6)}`, name: values.name || "新商品", category: values.category || "乳制品", price: Number(values.price || 9.9), stock: Number(values.stock || 100), sales: 0, status: true, updated: "刚刚" }; setProducts([product, ...products]); setDialog(false); onToast(`商品“${product.name}”已创建`); };
  return <section className="business-page"><PageHeader title="商品库" subtitle="维护商品资料、价格、库存和会员销售状态" primaryLabel="新增商品" primaryIcon={IconPackage} onPrimary={() => setDialog(true)} actions={<button className="outline-button" onClick={() => onToast("商品数据已导出")}><IconDatabaseExport size={16} />导出商品</button>} /><StatCards items={[{ label: "商品总数", value: "286", note: "上架 248 个", icon: IconPackage }, { label: "低库存商品", value: "12", note: "需要及时补货", icon: IconBox, tone: "orange" }, { label: "本月动销率", value: "82.6%", note: "环比提升 3.8%", icon: IconChartBar, tone: "green" }, { label: "新品数量", value: "18", note: "近 30 天上新", icon: IconSparkles, tone: "purple" }]} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索商品名称、编码或分类" onReset={() => setQuery("")} onSearch={() => onToast(`已找到 ${rows.length} 个商品`)}><select><option>全部分类</option><option>乳制品</option><option>酸奶</option><option>烘焙</option><option>新品</option></select><select><option>全部状态</option><option>上架</option><option>下架</option><option>低库存</option></select></SearchFilters><section className="panel business-table-card"><div className="business-table-head"><div><h2>商品列表</h2><p>库存和销售数据每 10 分钟更新</p></div><button className="quiet-button" onClick={() => onToast("库存已刷新")}><IconRefresh size={15} />刷新库存</button></div><div className="table-scroll"><table><thead><tr><th>商品</th><th>分类</th><th>会员价</th><th>库存</th><th>累计销量</th><th>状态</th><th>更新时间</th><th>操作</th></tr></thead><tbody>{rows.map((product) => <tr key={product.id}><td><div className="product-cell"><span><IconPackage size={20} /></span><div><strong>{product.name}</strong><small>{product.id}</small></div></div></td><td><Pill>{product.category}</Pill></td><td><strong>¥{product.price.toFixed(2)}</strong></td><td><span className={product.stock < 500 ? "negative-text" : ""}>{product.stock.toLocaleString()}</span></td><td>{product.sales.toLocaleString()}</td><td><Toggle checked={product.status} label={`${product.name}状态`} onChange={() => setProducts((current) => current.map((item) => item.id === product.id ? { ...item, status: !item.status } : item))} /></td><td>{product.updated}</td><td><button className="table-link" onClick={() => setSelected(product)}>查看</button></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered />}</div></section><FormDialog open={dialog} title="新增商品" subtitle="创建会员系统中的可售商品" onClose={() => setDialog(false)} onSave={save} fields={[{ key: "name", label: "商品名称", placeholder: "请输入商品名称" }, { key: "category", label: "商品分类", type: "select", options: ["乳制品", "酸奶", "烘焙", "新品"] }, { key: "price", label: "会员价格", type: "number", placeholder: "0.00" }, { key: "stock", label: "初始库存", type: "number", placeholder: "0" }, { key: "desc", label: "商品说明", type: "textarea", full: true, placeholder: "输入商品卖点和适用会员" }]} /><Drawer open={!!selected} title={selected?.name || ""} subtitle={`${selected?.id || ""} · ${selected?.category || ""}`} onClose={() => setSelected(null)} footer={<><button className="outline-button" onClick={() => onToast("商品资料进入编辑状态")}><IconEdit size={16} />编辑商品</button><button className="primary-button" onClick={() => onToast("已创建商品推荐任务")}>创建推荐任务</button></>}><div className="product-hero"><span><IconPackage size={40} /></span><div><Pill tone={selected?.status ? "green" : "red"}>{selected?.status ? "销售中" : "已下架"}</Pill><strong>会员价 ¥{selected?.price.toFixed(2)}</strong><p>库存 {selected?.stock.toLocaleString()} · 累计销量 {selected?.sales.toLocaleString()}</p></div></div><h3>销售表现</h3><div className="drawer-metrics"><div><small>近 30 天销量</small><strong>2,846</strong></div><div><small>复购率</small><strong>34.8%</strong></div><div><small>好评率</small><strong>98.2%</strong></div></div><h3>偏好人群</h3><div className="tag-cloud"><Pill>高价值会员</Pill><Pill tone="purple">新品偏好</Pill><Pill tone="orange">家庭用户</Pill></div></Drawer></section>;
}

function OrdersPage({ onToast }) {
  const [orders, setOrders] = useState(initialOrders);
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("全部状态");
  const [selected, setSelected] = useState(null);
  const [confirm, setConfirm] = useState(false);
  const rows = orders.filter((order) => (!query || `${order.id}${order.member}${order.store}`.includes(query)) && (status === "全部状态" || order.status === status));
  const advance = () => { const next = selected.status === "待付款" ? "待发货" : selected.status === "待发货" ? "配送中" : "已完成"; setOrders((current) => current.map((order) => order.id === selected.id ? { ...order, status: next } : order)); setSelected({ ...selected, status: next }); onToast(`订单状态已更新为“${next}”`); };
  return <section className="business-page"><PageHeader title="订单管理" subtitle="统一查看会员订单、履约状态、渠道和售后进度" actions={<><button className="outline-button" onClick={() => onToast("订单数据已同步")}><IconRefresh size={16} />同步订单</button><button className="outline-button" onClick={() => onToast("订单数据已导出")}><IconDatabaseExport size={16} />导出订单</button></>} /><StatCards items={[{ label: "今日订单", value: "2,380", note: "较昨日 +8.6%", icon: IconFileInvoice }, { label: "成交金额", value: "¥176万", note: "客单价 ¥73.9", icon: IconShoppingBag, tone: "green" }, { label: "待履约", value: "186", note: "待发货 128 单", icon: IconClock, tone: "orange" }, { label: "售后订单", value: "12", note: "退款中 8 单", icon: IconRefresh, tone: "purple" }]} /><SearchFilters query={query} onQuery={setQuery} placeholder="搜索订单号、会员或门店" onReset={() => { setQuery(""); setStatus("全部状态"); }} onSearch={() => onToast(`已找到 ${rows.length} 笔订单`)}><select value={status} onChange={(event) => setStatus(event.target.value)}><option>全部状态</option><option>待付款</option><option>待发货</option><option>配送中</option><option>已完成</option><option>退款中</option></select><select><option>全部渠道</option><option>小程序商城</option><option>门店收银</option><option>公众号商城</option></select></SearchFilters><section className="panel business-table-card"><div className="business-table-head"><div><h2>订单列表</h2><p>点击订单号查看商品与履约详情</p></div><span className="record-count">共 {rows.length} 笔</span></div><div className="table-scroll"><table><thead><tr><th>订单号</th><th>会员</th><th>订单金额</th><th>商品数</th><th>渠道</th><th>履约门店</th><th>状态</th><th>下单时间</th><th>操作</th></tr></thead><tbody>{rows.map((order) => <tr key={order.id}><td><button className="table-link" onClick={() => setSelected(order)}>{order.id}</button></td><td><strong>{order.member}</strong></td><td><strong>¥{order.amount.toFixed(2)}</strong></td><td>{order.items}</td><td>{order.channel}</td><td>{order.store}</td><td><Pill tone={order.status === "已完成" ? "green" : order.status === "退款中" ? "red" : order.status === "配送中" ? "purple" : "orange"}>{order.status}</Pill></td><td>{order.time}</td><td><button className="table-link" onClick={() => setSelected(order)}>详情</button></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered />}</div></section><Drawer open={!!selected} title={selected?.id || ""} subtitle={`${selected?.member || ""} · ${selected?.time || ""}`} onClose={() => setSelected(null)} footer={<>{selected?.status !== "已完成" && selected?.status !== "退款中" && <button className="primary-button" onClick={advance}>推进至下一状态</button>}<button className="outline-button" onClick={() => setConfirm(true)}>发起退款</button></>}><div className="order-status-line"><div className="is-done"><i><IconCheck size={13} /></i><span>订单创建</span></div><div className={selected?.status !== "待付款" ? "is-done" : ""}><i><IconCheck size={13} /></i><span>支付完成</span></div><div className={["配送中","已完成"].includes(selected?.status) ? "is-done" : ""}><i><IconCheck size={13} /></i><span>商品发出</span></div><div className={selected?.status === "已完成" ? "is-done" : ""}><i><IconCheck size={13} /></i><span>订单完成</span></div></div><h3>商品明细</h3><div className="order-items"><div><span><IconPackage size={18} /></span><strong>一鸣真鲜奶 950ml</strong><small>× 2</small><b>¥37.60</b></div><div><span><IconPackage size={18} /></span><strong>原味风味酸奶 200g</strong><small>× 4</small><b>¥35.60</b></div><div><span><IconPackage size={18} /></span><strong>经典奶香吐司</strong><small>× 3</small><b>¥38.40</b></div></div><h3>订单信息</h3><div className="detail-list"><div><span>订单金额</span><strong>¥{selected?.amount.toFixed(2)}</strong></div><div><span>销售渠道</span><strong>{selected?.channel}</strong></div><div><span>履约门店</span><strong>{selected?.store}</strong></div><div><span>会员</span><strong>{selected?.member}</strong></div></div></Drawer><ConfirmDialog open={confirm} title="确认发起退款？" text="退款申请将进入售后审核，订单状态会变更为退款中。" onClose={() => setConfirm(false)} onConfirm={() => { setOrders((current) => current.map((order) => order.id === selected.id ? { ...order, status: "退款中" } : order)); setSelected({ ...selected, status: "退款中" }); setConfirm(false); onToast("退款申请已提交"); }} /></section>;
}

function InsightTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return <div className="chart-tooltip"><strong>{label}</strong>{payload.map((item) => <span key={item.dataKey} style={{ color: item.color }}>{item.name}：{item.value}</span>)}</div>;
}

function InsightShell({ title, subtitle, stats, children, onToast, period, setPeriod }) {
  return <section className="business-page insight-page"><PageHeader title={title} subtitle={subtitle} actions={<><div className="segmented insight-period"><button className={period === "7" ? "is-active" : ""} onClick={() => setPeriod("7")}>近7天</button><button className={period === "30" ? "is-active" : ""} onClick={() => setPeriod("30")}>近30天</button><button className={period === "90" ? "is-active" : ""} onClick={() => setPeriod("90")}>近90天</button></div><button className="outline-button" onClick={() => onToast(`${title}报告已加入导出任务`)}><IconDatabaseExport size={16} />导出报告</button></>} /><StatCards items={stats} />{children}</section>;
}

function FansInsightPage({ onToast }) {
  const [period, setPeriod] = useState("7");
  return <InsightShell title="粉丝洞察" subtitle="分析公众号、小程序和社交渠道的粉丝增长、活跃与转化" period={period} setPeriod={setPeriod} onToast={onToast} stats={[{ label: "粉丝总数", value: "286,420", note: "净增长 8.2%", icon: IconUsers }, { label: "今日新增", value: "1,258", note: "取关 98 人", icon: IconUserCheck, tone: "green" }, { label: "活跃粉丝", value: "86,520", note: "活跃率 30.21%", icon: IconActivity, tone: "orange" }, { label: "会员转化率", value: "44.92%", note: "较上期 +2.8%", icon: IconTargetArrow, tone: "purple" }]}><div className="insight-layout"><section className="panel insight-main-chart"><div className="business-table-head"><div><h2>粉丝增长趋势</h2><p>新增、取关与活跃粉丝变化</p></div><div className="chart-legend"><span className="is-blue">新增粉丝</span><span className="is-red">取关</span><span className="is-green">活跃粉丝</span></div></div><div className="large-chart"><ResponsiveContainer width="100%" height="100%"><AreaChart data={fanTrend}><defs><linearGradient id="fanFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#2869f6" stopOpacity={.28}/><stop offset="100%" stopColor="#2869f6" stopOpacity={0}/></linearGradient></defs><CartesianGrid stroke="#edf1f7" vertical={false}/><XAxis dataKey="day" axisLine={false} tickLine={false}/><YAxis axisLine={false} tickLine={false}/><Tooltip content={<InsightTooltip />}/><Area name="新增粉丝" dataKey="new" stroke="#2869f6" fill="url(#fanFill)" strokeWidth={2}/><Line name="取关" dataKey="lost" stroke="#ef5b6d" strokeWidth={2}/></AreaChart></ResponsiveContainer></div></section><section className="panel insight-side"><div className="business-table-head"><div><h2>渠道构成</h2><p>粉丝来源占比</p></div></div><div className="insight-donut"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={[{name:"小程序",value:52},{name:"公众号",value:31},{name:"企业微信",value:17}]} dataKey="value" innerRadius={56} outerRadius={78} paddingAngle={3} stroke="none"><Cell fill="#2869f6"/><Cell fill="#13bda5"/><Cell fill="#7a63e8"/></Pie><Tooltip/></PieChart></ResponsiveContainer><strong>286,420<small>总粉丝数</small></strong></div><div className="channel-list"><div><i className="is-blue"/><span>小程序</span><strong>52%</strong></div><div><i className="is-green"/><span>公众号</span><strong>31%</strong></div><div><i className="is-purple"/><span>企业微信</span><strong>17%</strong></div></div></section></div><div className="insight-cards-row"><article className="panel"><h2>内容互动排行</h2><div className="ranking-list"><div><b>1</b><span>夏日新品会员尝鲜活动</span><strong>12.8%</strong></div><div><b>2</b><span>早餐营养搭配指南</span><strong>10.6%</strong></div><div><b>3</b><span>会员积分兑换提醒</span><strong>8.9%</strong></div></div></article><article className="panel"><h2>粉丝转化漏斗</h2><div className="funnel"><div style={{width:"100%"}}>内容触达 <strong>186,420</strong></div><div style={{width:"82%"}}>产生互动 <strong>92,860</strong></div><div style={{width:"63%"}}>进入商城 <strong>48,320</strong></div><div style={{width:"44%"}}>转化会员 <strong>21,706</strong></div></div></article><article className="panel ai-recommend-card"><IconSparkles size={23}/><h2>AI 增长建议</h2><p>小程序新粉的会员转化率最高，建议将公众号高互动粉丝导入小程序新人礼包链路，预计可提升转化 3.2%。</p><button onClick={() => onToast("已生成粉丝转化任务草稿")}>生成运营任务</button></article></div></InsightShell>;
}

function MemberInsightPage({ onToast }) {
  const [period, setPeriod] = useState("30");
  return <InsightShell title="会员洞察" subtitle="从生命周期、留存、价值和活跃度理解会员经营质量" period={period} setPeriod={setPeriod} onToast={onToast} stats={[{ label: "有效会员", value: "128,670", note: "本月新增 6,782", icon: IconUsers }, { label: "月活会员", value: "52,340", note: "活跃率 40.68%", icon: IconActivity, tone: "green" }, { label: "90 天留存", value: "81.2%", note: "较上期 +3.1%", icon: IconRefresh, tone: "orange" }, { label: "高价值会员", value: "18,620", note: "占比 14.47%", icon: IconTargetArrow, tone: "purple" }]}><div className="insight-layout"><section className="panel insight-main-chart"><div className="business-table-head"><div><h2>会员经营质量趋势</h2><p>活跃率、留存率与价值指数</p></div></div><div className="large-chart"><ResponsiveContainer width="100%" height="100%"><LineChart data={memberTrend}><CartesianGrid stroke="#edf1f7" vertical={false}/><XAxis dataKey="month" axisLine={false} tickLine={false}/><YAxis axisLine={false} tickLine={false}/><Tooltip content={<InsightTooltip />}/><Line name="活跃率" dataKey="active" stroke="#2869f6" strokeWidth={3}/><Line name="留存率" dataKey="retention" stroke="#13bda5" strokeWidth={3}/><Line name="价值指数" dataKey="value" stroke="#7a63e8" strokeWidth={3}/></LineChart></ResponsiveContainer></div></section><section className="panel insight-side lifecycle"><div className="business-table-head"><div><h2>生命周期分布</h2><p>当前会员阶段</p></div></div>{[["新会员",18.2,"blue"],["成长期",26.8,"green"],["成熟期",34.5,"purple"],["衰退期",12.6,"orange"],["流失期",7.9,"red"]].map(([label,value,tone])=><div className="lifecycle-row" key={label}><span>{label}</span><i><b className={`is-${tone}`} style={{width:`${value*2.2}%`}}/></i><strong>{value}%</strong></div>)}</section></div><div className="insight-cards-row"><article className="panel"><h2>价值人群迁移</h2><div className="migration-grid"><div><IconArrowUpRight/><strong>2,486</strong><span>升级为高价值</span></div><div><IconArrowDownRight/><strong>1,128</strong><span>价值下降</span></div><div><IconRefresh/><strong>86.4%</strong><span>价值稳定</span></div></div></article><article className="panel"><h2>会员等级结构</h2><div className="simple-bars">{[["普通卡",53],["银卡",20],["金卡",15],["白金卡",8],["钻石卡",4]].map(([label,value])=><div key={label}><span>{label}</span><i><b style={{width:`${value}%`}}/></i><strong>{value}%</strong></div>)}</div></article><article className="panel ai-recommend-card"><IconSparkles size={23}/><h2>AI 留存建议</h2><p>银卡会员的升级转化出现停滞，建议面向近 60 天消费 2 次以上人群配置成长加速任务。</p><button onClick={() => onToast("已生成会员成长任务草稿")}>创建成长任务</button></article></div></InsightShell>;
}

function SalesInsightPage({ onToast }) {
  const [period, setPeriod] = useState("7");
  return <InsightShell title="销售洞察" subtitle="分析会员销售额、订单、客单价、渠道和商品贡献" period={period} setPeriod={setPeriod} onToast={onToast} stats={[{ label: "今日销售额", value: "¥176万", note: "较昨日 +18.9%", icon: IconShoppingBag }, { label: "今日订单", value: "2,380", note: "转化率 12.6%", icon: IconFileInvoice, tone: "green" }, { label: "会员客单价", value: "¥73.9", note: "较非会员高 28%", icon: IconChartBar, tone: "orange" }, { label: "复购销售占比", value: "62.4%", note: "环比 +4.1%", icon: IconRefresh, tone: "purple" }]}><div className="insight-layout"><section className="panel insight-main-chart"><div className="business-table-head"><div><h2>销售与订单趋势</h2><p>销售额（万元）与订单量变化</p></div></div><div className="large-chart"><ResponsiveContainer width="100%" height="100%"><BarChart data={salesTrend}><CartesianGrid stroke="#edf1f7" vertical={false}/><XAxis dataKey="day" axisLine={false} tickLine={false}/><YAxis axisLine={false} tickLine={false}/><Tooltip content={<InsightTooltip />}/><Bar name="销售额（万元）" dataKey="sales" fill="#2869f6" radius={[5,5,0,0]}/></BarChart></ResponsiveContainer></div></section><section className="panel insight-side"><div className="business-table-head"><div><h2>渠道销售贡献</h2><p>销售额占比</p></div></div><div className="insight-donut"><ResponsiveContainer width="100%" height="100%"><PieChart><Pie data={[{name:"小程序",value:46},{name:"门店",value:38},{name:"公众号",value:11},{name:"其他",value:5}]} dataKey="value" innerRadius={56} outerRadius={78} paddingAngle={3} stroke="none"><Cell fill="#2869f6"/><Cell fill="#13bda5"/><Cell fill="#7a63e8"/><Cell fill="#f3a51a"/></Pie><Tooltip/></PieChart></ResponsiveContainer><strong>¥1,026万<small>近 7 天销售</small></strong></div><div className="channel-list"><div><i className="is-blue"/><span>小程序商城</span><strong>46%</strong></div><div><i className="is-green"/><span>门店收银</span><strong>38%</strong></div><div><i className="is-purple"/><span>公众号商城</span><strong>11%</strong></div></div></section></div><div className="insight-cards-row"><article className="panel"><h2>热销商品排行</h2><div className="ranking-list"><div><b>1</b><span>一鸣真鲜奶 950ml</span><strong>¥186万</strong></div><div><b>2</b><span>原味风味酸奶 200g</span><strong>¥142万</strong></div><div><b>3</b><span>经典奶香吐司</span><strong>¥98万</strong></div></div></article><article className="panel"><h2>门店销售排行</h2><div className="ranking-list"><div><b>1</b><span>杭州西湖店</span><strong>¥68.4万</strong></div><div><b>2</b><span>宁波鄞州店</span><strong>¥56.2万</strong></div><div><b>3</b><span>温州鹿城店</span><strong>¥49.8万</strong></div></div></article><article className="panel ai-recommend-card"><IconSparkles size={23}/><h2>AI 销售建议</h2><p>周末小程序客单价显著高于工作日，建议将高价值会员新品组合券安排在周五晚间触达。</p><button onClick={() => onToast("已生成销售提升任务草稿")}>生成提升方案</button></article></div></InsightShell>;
}

const domainConfigs = {
  "domain-marketing": {
    title: "营销管理", subtitle: "创建营销活动、优惠券和自动化触达任务", icon: IconSpeakerphone, tone: "blue",
    stats: [["执行中活动", "12", "本周新增 3 个"], ["已触达会员", "86,420", "触达率 82.6%"], ["优惠券核销率", "38.4%", "环比 +4.2%"], ["营销转化额", "¥286万", "投入产出比 4.8"]],
    modules: [["营销活动", "管理满减、拉新、召回和节日活动", "新建活动"], ["优惠券管理", "创建券模板、库存与发放规则", "创建优惠券"], ["自动化营销", "按会员事件自动触达与跟进", "新建自动化"], ["触达记录", "查看短信、企微和站内消息效果", "查看记录"]],
    tasks: [["夏日新品会员尝鲜", "高价值活跃会员", "执行中", "68.4%"], ["沉睡会员召回计划", "低活跃待唤醒会员", "执行中", "42.8%"], ["新会员首单礼", "近 30 天新会员", "已完成", "76.2%"]],
  },
  "domain-loyalty": {
    title: "忠诚度管理", subtitle: "管理会员等级、积分、权益与成长体系", icon: IconHeartHandshake, tone: "purple",
    stats: [["等级体系", "5 级", "钻石卡 5,097 人"], ["可用积分", "8,624万", "本月发放 426 万"], ["权益使用率", "62.8%", "环比 +6.1%"], ["成长会员", "24,680", "近 30 天升级 2,486 人"]],
    modules: [["会员等级", "配置升级条件、保级和降级规则", "配置等级"], ["积分商城", "管理积分商品和兑换订单", "管理商城"], ["会员权益", "配置各等级专属权益和次数", "配置权益"], ["成长任务", "用任务激励会员升级和复购", "创建任务"]],
    tasks: [["银卡升级加速任务", "银卡会员", "执行中", "54.6%"], ["钻石卡专属权益包", "钻石卡会员", "执行中", "81.2%"], ["积分到期提醒", "积分即将到期会员", "待执行", "0%"]],
  },
  "domain-scrm": {
    title: "社交SCRM", subtitle: "连接公众号、企业微信和社群，沉淀社交关系资产", icon: IconBrandWechat, tone: "green",
    stats: [["企微客户", "186,420", "净增长 6.8%"], ["活跃社群", "286", "本周新增 12 个"], ["今日互动", "18,650", "回复率 42.6%"], ["社交转化", "¥82.6万", "转化率 8.4%"]],
    modules: [["客户联系", "管理企微客户、跟进状态和员工归属", "查看客户"], ["社群管理", "管理群成员、群标签和群任务", "管理社群"], ["素材中心", "统一维护欢迎语、海报和内容素材", "管理素材"], ["会话分析", "分析响应效率、关键词和服务质量", "查看分析"]],
    tasks: [["新品体验群运营", "12 个社群", "执行中", "72.4%"], ["企业微信客户补标签", "18,420 位客户", "执行中", "86.8%"], ["社群沉默成员激活", "6,284 位成员", "待执行", "0%"]],
  },
  "domain-enterprise": {
    title: "企业管理", subtitle: "管理组织、门店、员工和数据权限", icon: IconBuildingStore, tone: "orange",
    stats: [["运营门店", "328", "正常营业 316 家"], ["企业员工", "2,846", "本月新增 68 人"], ["角色数量", "18", "自定义角色 12 个"], ["待审批", "9", "门店权限申请"]],
    modules: [["组织架构", "维护总部、区域、门店和部门层级", "管理组织"], ["门店管理", "配置门店资料、服务范围和状态", "管理门店"], ["员工管理", "管理员工账号、归属与在职状态", "管理员工"], ["角色权限", "按角色配置页面、数据和操作权限", "配置权限"]],
    tasks: [["华东区域门店资料补全", "32 家门店", "执行中", "78.1%"], ["新员工权限开通", "18 位员工", "待审批", "44.4%"], ["离职员工账号回收", "6 个账号", "已完成", "100%"]],
  },
  "domain-config": {
    title: "配置管理", subtitle: "维护系统参数、消息模板、字典和业务规则", icon: IconSettings, tone: "purple",
    stats: [["系统参数", "126", "今日变更 3 项"], ["消息模板", "48", "启用 42 个"], ["数据字典", "36", "字典项 682 个"], ["异常配置", "1", "短信签名待审核"]],
    modules: [["系统参数", "配置会员、订单和营销通用参数", "参数配置"], ["消息模板", "维护短信、站内信和企微模板", "管理模板"], ["数据字典", "统一管理业务枚举和基础数据", "管理字典"], ["任务调度", "查看自动任务、执行记录和异常", "查看任务"]],
    tasks: [["会员等级日终计算", "每日 02:00", "正常", "100%"], ["标签规则实时任务", "实时执行", "正常", "99.8%"], ["短信模板审核同步", "每 30 分钟", "异常", "62.0%"]],
  },
  "domain-dev": {
    title: "开发平台", subtitle: "管理开放接口、应用、密钥、Webhook 和调用日志", icon: IconCode, tone: "blue",
    stats: [["开放应用", "18", "启用 15 个"], ["今日调用", "286万", "成功率 99.96%"], ["Webhook", "32", "异常 1 个"], ["接口平均耗时", "86ms", "P95 142ms"]],
    modules: [["应用管理", "创建应用并配置接口访问范围", "新建应用"], ["API 文档", "查看会员、订单和营销开放接口", "查看文档"], ["Webhook", "配置业务事件回调和签名", "配置回调"], ["调用日志", "排查接口错误、延迟和限流", "查看日志"]],
    tasks: [["会员数据同步应用", "今日调用 86 万次", "正常", "99.99%"], ["订单回调 Webhook", "今日回调 12 万次", "正常", "99.95%"], ["旧版积分接口迁移", "截止 06-30", "执行中", "72.0%"]],
  },
};

function DomainOverviewPage({ pageId, onToast }) {
  const config = domainConfigs[pageId];
  const DomainIcon = config.icon;
  const [selectedModule, setSelectedModule] = useState(null);
  const [selectedTask, setSelectedTask] = useState(null);
  const moduleTitle = selectedModule?.[0] || selectedTask?.[0] || "";
  const moduleDescription = selectedModule?.[1] || selectedTask?.[1] || "";
  return <section className="business-page domain-overview"><PageHeader title={config.title} subtitle={config.subtitle} actions={<button className="outline-button" onClick={() => onToast(`${config.title}数据已刷新`)}><IconRefresh size={16}/>刷新数据</button>} /><div className="domain-hero panel"><span className={`domain-hero__icon is-${config.tone}`}><DomainIcon size={30}/></span><div><h2>{config.title}工作台</h2><p>所有核心能力已经接入统一会员数据与权限体系。</p></div><button className="primary-button" onClick={() => onToast(`已打开${config.title}操作指南`)}>查看操作指南</button></div><StatCards items={config.stats.map(([label,value,note],index)=>({label,value,note,icon:[IconClipboardData,IconUsers,IconChartBar,IconActivity][index],tone:[config.tone,"green","orange","purple"][index]}))}/><div className="domain-module-grid">{config.modules.map(([title,desc,action],index)=><article className="panel" key={title}><span className={`domain-module-icon is-${[config.tone,"green","orange","purple"][index]}`}><DomainIcon size={21}/></span><h2>{title}</h2><p>{desc}</p><button onClick={()=>setSelectedModule([title,desc,action])}>{action}<IconChevronRight size={15}/></button></article>)}</div><section className="panel business-table-card"><div className="business-table-head"><div><h2>重点任务</h2><p>当前模块正在执行或待处理的任务</p></div><button className="quiet-button" onClick={()=>onToast("已显示全部任务")}>查看全部</button></div><div className="table-scroll"><table><thead><tr><th>任务名称</th><th>目标对象</th><th>状态</th><th>完成度</th><th>操作</th></tr></thead><tbody>{config.tasks.map(([name,target,status,progress])=><tr key={name}><td><strong>{name}</strong></td><td>{target}</td><td><Pill tone={status==="正常"||status==="已完成"?"green":status==="异常"?"red":"orange"}>{status}</Pill></td><td><div className="task-progress"><i><b style={{width:progress}}/></i><strong>{progress}</strong></div></td><td><button className="table-link" onClick={()=>setSelectedTask([name,target,status,progress])}>查看</button></td></tr>)}</tbody></table></div></section><Drawer open={!!selectedModule || !!selectedTask} title={moduleTitle} subtitle={`${config.title} · 功能面板`} onClose={()=>{setSelectedModule(null);setSelectedTask(null);}} footer={<><button className="outline-button" onClick={()=>onToast(`${moduleTitle}配置已保存`)}>保存配置</button><button className="primary-button" onClick={()=>onToast(`${moduleTitle}已开始执行`)}>立即执行</button></>}><div className="drawer-insight"><IconSparkles size={19}/><p>{selectedModule ? moduleDescription : `目标：${moduleDescription}。当前状态为“${selectedTask?.[2]}”，完成度 ${selectedTask?.[3]}。`}</p></div><h3>功能配置</h3><div className="detail-list"><div><span>所属业务域</span><strong>{config.title}</strong></div><div><span>数据范围</span><strong>全部可见会员</strong></div><div><span>执行方式</span><strong>{selectedTask ? "按当前任务计划" : "手动或定时执行"}</strong></div><div><span>最近更新</span><strong>2026-06-15 16:30</strong></div></div><h3>可用操作</h3><div className="tag-cloud"><Pill>编辑规则</Pill><Pill tone="green">选择对象</Pill><Pill tone="orange">配置通知</Pill><Pill tone="purple">查看日志</Pill></div></Drawer></section>;
}

function DomainFeaturePage({ pageId, onToast }) {
  const config = FEATURE_PAGE_CONFIG[pageId];
  const FeatureIcon = config.icon;
  const exportOnly = config.action.includes("导出");
  const [records, setRecords] = useState(() => config.samples.map((name, index) => ({
    id: `${pageId}-${index + 1}`,
    name,
    owner: ["超级管理员", "会员运营组", "系统自动"][index % 3],
    scope: ["全部会员", "重点人群", "指定组织"][index % 3],
    status: ["已启用", "运行中", "待审核"][index % 3],
    enabled: index !== 2,
    updated: ["今天 14:26", "今天 10:08", "昨天 17:42"][index % 3],
  })));
  const [query, setQuery] = useState("");
  const [status, setStatus] = useState("全部状态");
  const [selected, setSelected] = useState(null);
  const [dialog, setDialog] = useState(false);
  const rows = useMemo(() => records.filter((record) => (!query || `${record.name}${record.owner}${record.scope}`.includes(query)) && (status === "全部状态" || record.status === status)), [query, records, status]);
  const primaryAction = () => exportOnly ? onToast(`${config.label}数据已加入导出任务`) : setDialog(true);
  const save = (values) => {
    const name = values.name || `${config.label} ${records.length + 1}`;
    setRecords((current) => [{ id: `${pageId}-${Date.now()}`, name, owner: values.owner || "超级管理员", scope: values.scope || "全部会员", status: "待审核", enabled: true, updated: "刚刚" }, ...current]);
    setDialog(false);
    onToast(`${config.label}“${name}”已保存`);
  };
  return <section className="business-page"><PageHeader title={config.label} subtitle={config.description} primaryLabel={config.action} primaryIcon={FeatureIcon} onPrimary={primaryAction} actions={<button className="outline-button" onClick={() => onToast(`${config.label}数据已刷新`)}><IconRefresh size={16}/>刷新数据</button>} /><StatCards items={[{ label: `${config.label}总数`, value: String(records.length + 12), note: "较上周新增 3 项", icon: FeatureIcon }, { label: "已启用", value: String(records.filter((record) => record.enabled).length + 8), note: "运行状态正常", icon: IconCheck, tone: "green" }, { label: "今日处理", value: "286", note: "完成率 96.8%", icon: IconActivity, tone: "orange" }, { label: "待处理", value: "3", note: "需要管理员关注", icon: IconClock, tone: "purple" }]} /><SearchFilters query={query} onQuery={setQuery} placeholder={`搜索${config.label}名称、负责人或范围`} onReset={() => { setQuery(""); setStatus("全部状态"); }} onSearch={() => onToast(`已找到 ${rows.length} 条${config.label}数据`)}><select value={status} onChange={(event) => setStatus(event.target.value)}><option>全部状态</option><option>已启用</option><option>运行中</option><option>待审核</option></select><select><option>全部负责人</option><option>超级管理员</option><option>会员运营组</option><option>系统自动</option></select></SearchFilters><section className="panel business-table-card"><div className="business-table-head"><div><h2>{config.label}列表</h2><p>数据来自 {config.domain}，点击名称查看详情和执行配置</p></div><span className="record-count">共 {rows.length} 条</span></div><div className="table-scroll"><table><thead><tr><th>名称</th><th>业务范围</th><th>负责人</th><th>状态</th><th>启用</th><th>更新时间</th><th>操作</th></tr></thead><tbody>{rows.map((record) => <tr key={record.id}><td><button className="table-link" onClick={() => setSelected(record)}>{record.name}</button></td><td>{record.scope}</td><td>{record.owner}</td><td><Pill tone={record.status === "已启用" ? "green" : record.status === "待审核" ? "orange" : "blue"}>{record.status}</Pill></td><td><Toggle checked={record.enabled} label={`${record.name}状态`} onChange={() => setRecords((current) => current.map((item) => item.id === record.id ? { ...item, enabled: !item.enabled, status: item.enabled ? "已停用" : "已启用" } : item))}/></td><td>{record.updated}</td><td><button className="table-link" onClick={() => setSelected(record)}>查看</button></td></tr>)}</tbody></table>{!rows.length && <EmptyFiltered/>}</div></section><FormDialog open={dialog} title={config.action} subtitle={`在${config.domain}中创建新的${config.label}配置`} onClose={() => setDialog(false)} onSave={save} fields={[{ key: "name", label: `${config.label}名称`, placeholder: `请输入${config.label}名称` }, { key: "owner", label: "负责人", type: "select", options: ["超级管理员", "会员运营组", "门店运营组"] }, { key: "scope", label: "业务范围", type: "select", options: ["全部会员", "重点人群", "指定组织"] }, { key: "description", label: "配置说明", type: "textarea", full: true, placeholder: "补充业务目标、执行规则和注意事项" }]} /><Drawer open={!!selected} title={selected?.name || ""} subtitle={`${config.domain} · ${config.group}`} onClose={() => setSelected(null)} footer={<><button className="outline-button" onClick={() => onToast(`${selected?.name}已复制`)}>复制配置</button><button className="primary-button" onClick={() => onToast(`${selected?.name}已执行`)}>立即执行</button></>}><div className="drawer-insight"><IconSparkles size={19}/><p>{config.description}。当前配置可继续编辑范围、规则、通知和执行计划。</p></div><h3>基础信息</h3><div className="detail-list"><div><span>业务范围</span><strong>{selected?.scope}</strong></div><div><span>负责人</span><strong>{selected?.owner}</strong></div><div><span>当前状态</span><strong>{selected?.status}</strong></div><div><span>最近更新</span><strong>{selected?.updated}</strong></div></div><h3>执行配置</h3><div className="tag-cloud"><Pill>编辑规则</Pill><Pill tone="green">选择对象</Pill><Pill tone="orange">配置通知</Pill><Pill tone="purple">查看记录</Pill></div></Drawer></section>;
}

export function BusinessPageRouter({ activePage, onToast, onAction }) {
  const props = { onToast, onAction };
  if (domainConfigs[activePage]) return <DomainOverviewPage pageId={activePage} onToast={onToast} />;
  if (activePage === "wechat-chat") return <WechatChatPage onToast={onToast} />;
  if (FEATURE_PAGE_CONFIG[activePage]) return <DomainFeaturePage key={activePage} pageId={activePage} onToast={onToast} />;
  switch (activePage) {
    case "high-value": return <HighValuePage {...props} />;
    case "logs": return <LogsPage {...props} />;
    case "segments": return <SegmentsPage {...props} />;
    case "tags": return <TagsPage {...props} />;
    case "tag-scenes": return <TagScenesPage {...props} />;
    case "tag-logs": return <TagLogsPage {...props} />;
    case "products": return <ProductsPage {...props} />;
    case "orders": return <OrdersPage {...props} />;
    case "fans": return <FansInsightPage {...props} />;
    case "member-insight": return <MemberInsightPage {...props} />;
    case "sales-insight": return <SalesInsightPage {...props} />;
    default: return null;
  }
}
