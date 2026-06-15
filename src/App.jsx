import { useEffect, useMemo, useRef, useState } from "react";
import {
  IconActivity,
  IconAdjustmentsHorizontal,
  IconBell,
  IconBolt,
  IconBrain,
  IconBuildingStore,
  IconCalendar,
  IconChartBar,
  IconChartDonut,
  IconChevronDown,
  IconChevronLeft,
  IconChevronRight,
  IconClipboardData,
  IconDatabaseExport,
  IconDiscount2,
  IconFileText,
  IconFilter,
  IconHome,
  IconIdBadge2,
  IconLanguage,
  IconMenu2,
  IconMessageCircle,
  IconPackage,
  IconPlus,
  IconRefresh,
  IconSearch,
  IconSend2,
  IconSettings,
  IconSparkles,
  IconTag,
  IconTargetArrow,
  IconTrendingDown,
  IconTrendingUp,
  IconUserCircle,
  IconUserPlus,
  IconUsers,
  IconUsersGroup,
  IconX,
} from "@tabler/icons-react";
import {
  Bar,
  BarChart,
  CartesianGrid,
  Cell,
  ComposedChart,
  Line,
  Pie,
  PieChart,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";
import { BusinessPageRouter } from "./BusinessPages.jsx";
import { DOMAIN_NAV, DOMAIN_NAVIGATION, DOMAIN_PAGES, PAGE_META } from "./navigationConfig.jsx";

const trends30 = [
  { day: "05-15", members: 520, rate: 9 },
  { day: "05-18", members: 910, rate: 13 },
  { day: "05-21", members: 430, rate: 6 },
  { day: "05-24", members: 1280, rate: 16 },
  { day: "05-27", members: 780, rate: 12 },
  { day: "05-30", members: 1620, rate: 21 },
  { day: "06-02", members: 940, rate: 14 },
  { day: "06-05", members: 1780, rate: 23 },
  { day: "06-08", members: 1140, rate: 18 },
  { day: "06-11", members: 760, rate: 10 },
  { day: "06-14", members: 1258, rate: 12.31 },
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

const portraitBars = [
  { name: "18-24", value: 14 },
  { name: "25-34", value: 40 },
  { name: "35-44", value: 27 },
  { name: "45-54", value: 12 },
  { name: "55+", value: 7 },
];

const sourceRows = [
  ["小程序商城", "12,456", 46.37, "blue"],
  ["门店扫码注册", "6,782", 25.24, "green"],
  ["公众号", "4,215", 15.68, "orange"],
  ["员工邀请", "2,156", 8.03, "purple"],
  ["其他渠道", "1,234", 4.58, "gray"],
];

const members = [
  { id: "M202606130021", name: "林晓然", phone: "138****3026", store: "杭州西湖店", level: "钻石卡", source: "小程序商城", date: "2026-06-13", status: "活跃" },
  { id: "M202606120118", name: "周子墨", phone: "186****7913", store: "宁波鄞州店", level: "金卡", source: "门店扫码", date: "2026-06-12", status: "活跃" },
  { id: "M202606110086", name: "陈安宁", phone: "157****6088", store: "温州鹿城店", level: "银卡", source: "公众号", date: "2026-06-11", status: "待唤醒" },
  { id: "M202606100035", name: "吴嘉言", phone: "139****4251", store: "杭州滨江店", level: "普通卡", source: "员工邀请", date: "2026-06-10", status: "活跃" },
  { id: "M202606090242", name: "沈清禾", phone: "177****1638", store: "绍兴越城店", level: "白金卡", source: "小程序商城", date: "2026-06-09", status: "冻结" },
  { id: "M202606080157", name: "许星遥", phone: "159****8332", store: "台州椒江店", level: "金卡", source: "门店扫码", date: "2026-06-08", status: "活跃" },
];

function formatNumber(value) {
  return new Intl.NumberFormat("zh-CN").format(value);
}

function Logo({ compact = false }) {
  return (
    <div className={`brand ${compact ? "brand--compact" : ""}`} aria-label="IS 微智">
      <span className="brand__is">IS</span>
      {!compact && <span className="brand__cn">微智</span>}
    </div>
  );
}

function Sidebar({ activeDomain, activePage, collapsed, mobileOpen, onNavigate, onToggle, onClose }) {
  const navigation = DOMAIN_NAVIGATION[activeDomain];
  return (
    <>
      <div className={`mobile-shade ${mobileOpen ? "is-visible" : ""}`} onClick={onClose} />
      <aside className={`sidebar ${collapsed ? "is-collapsed" : ""} ${mobileOpen ? "is-mobile-open" : ""}`}>
        <div className="sidebar__brand">
          <Logo compact={collapsed} />
          <button className="icon-button sidebar__mobile-close" onClick={onClose} aria-label="关闭菜单"><IconX size={20} /></button>
        </div>
        <nav className="sidebar__nav" aria-label={`${activeDomain}主导航`} key={activeDomain}>
          <button className={`nav-row nav-row--home ${activePage === navigation.home.id ? "is-active" : ""}`} onClick={() => onNavigate(navigation.home.id)}>
            <IconHome size={18} />
            {!collapsed && <span>{navigation.home.label}</span>}
          </button>
          {navigation.groups.map((group) => (
            <section className="nav-group" key={group.label}>
              {!collapsed && <h3>{group.label}</h3>}
              {group.items.map((item) => {
                const Icon = item.icon;
                const selected = activePage === item.id;
                return (
                  <button className={`nav-row ${selected ? "is-active" : ""}`} key={item.id} onClick={() => onNavigate(item.id)} title={collapsed ? item.label : undefined}>
                    <Icon size={17} />
                    {!collapsed && <span>{item.label}</span>}
                    {!collapsed && item.expandable && <IconChevronDown className="nav-row__chevron" size={15} />}
                  </button>
                );
              })}
            </section>
          ))}
        </nav>
        <div className="sidebar__bottom">
          <button className="nav-row" onClick={onToggle}>
            <IconChevronLeft className={collapsed ? "is-rotated" : ""} size={17} />
            {!collapsed && <span>收起菜单</span>}
          </button>
          {!collapsed && <IconSettings size={17} />}
        </div>
      </aside>
    </>
  );
}

function Header({ activeDomain, onDomain, onMenu, onToast }) {
  return (
    <header className="topbar">
      <div className="topbar__left">
        <button className="icon-button mobile-menu" onClick={onMenu} aria-label="打开菜单"><IconMenu2 size={22} /></button>
        <div className="topbar__domains" role="navigation" aria-label="业务域导航">
          {DOMAIN_NAV.map((item) => (
            <button key={item} className={activeDomain === item ? "is-active" : ""} onClick={() => onDomain(item)}>{item}</button>
          ))}
        </div>
      </div>
      <div className="topbar__tools">
        <label className="global-search">
          <IconSearch size={17} />
          <input placeholder="搜索内容、页面、用户、订单等..." onKeyDown={(event) => event.key === "Enter" && onToast(`正在搜索“${event.currentTarget.value || "全部内容"}”`)} />
        </label>
        <button className="tool-button"><IconLanguage size={18} /><span>简体中文</span><IconChevronDown size={14} /></button>
        <button className="icon-button" onClick={() => onToast("当前没有新的系统通知")} aria-label="通知"><IconBell size={19} /></button>
        <button className="profile-button"><span className="avatar">超</span><span>超级管理员</span><IconChevronDown size={14} /></button>
      </div>
    </header>
  );
}

function MetricCard({ icon: Icon, label, value, delta, color }) {
  return (
    <article className="metric-card">
      <span className={`metric-card__icon is-${color}`}><Icon size={21} /></span>
      <div>
        <span className="metric-card__label">{label}</span>
        <strong>{value}</strong>
        <small>较昨日 <span>↑ {delta}</span></small>
      </div>
    </article>
  );
}

function SummaryStrip() {
  return (
    <section className="summary-strip">
      <MetricCard icon={IconUsers} label="会员总数" value="128,670" delta="2.35%" color="blue" />
      <MetricCard icon={IconCalendar} label="昨日新增" value="1,258" delta="8.42%" color="green" />
      <MetricCard icon={IconCalendar} label="本月新增" value="6,782" delta="12.31%" color="orange" />
      <MetricCard icon={IconTrendingUp} label="本季新增" value="18,934" delta="15.62%" color="gold" />
      <div className="growth-metrics">
        <div><span>日环比增长率</span><strong>+2.35%</strong></div>
        <div><span>月环比增长率</span><strong>+12.31%</strong></div>
        <div><span>季环比增长率</span><strong>+15.62%</strong></div>
      </div>
    </section>
  );
}

function ChartTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="chart-tooltip">
      <strong>{label}</strong>
      {payload.map((item) => <span key={item.dataKey} style={{ color: item.color }}>{item.name}：{item.value}{item.dataKey === "rate" ? "%" : " 人"}</span>)}
    </div>
  );
}

function TrendPanel({ period, onPeriod, onToast }) {
  const data = period === "30" ? trends30 : trends90;
  return (
    <section className="panel trend-panel">
      <div className="panel__head panel__head--wrap">
        <div>
          <h2>用户增量分析</h2>
          <p>单位：人 · 对比会员增量与环比增长率</p>
        </div>
        <div className="panel-actions">
          <div className="segmented">
            <button className={period === "30" ? "is-active" : ""} onClick={() => onPeriod("30")}>近30天</button>
            <button className={period === "90" ? "is-active" : ""} onClick={() => onPeriod("90")}>近90天</button>
          </div>
          <button className="quiet-button"><IconCalendar size={16} /> 2026-05-15 至 2026-06-14</button>
          <button className="outline-button" onClick={() => onToast("趋势图已加入导出任务")}><IconDatabaseExport size={16} /> 导出图表</button>
        </div>
      </div>
      <div className="trend-chart">
        <ResponsiveContainer width="100%" height="100%">
          <ComposedChart data={data} margin={{ top: 14, right: 4, left: -22, bottom: 0 }}>
            <CartesianGrid stroke="#edf1f8" vertical={false} />
            <XAxis dataKey="day" tickLine={false} axisLine={false} tick={{ fill: "#8792a8", fontSize: 13 }} />
            <YAxis yAxisId="left" tickLine={false} axisLine={false} tick={{ fill: "#8792a8", fontSize: 13 }} />
            <YAxis yAxisId="right" orientation="right" tickLine={false} axisLine={false} tickFormatter={(v) => `${v}%`} tick={{ fill: "#8792a8", fontSize: 13 }} />
            <Tooltip content={<ChartTooltip />} />
            <Bar yAxisId="left" name="会员增量" dataKey="members" fill="#3976f6" radius={[4, 4, 0, 0]} maxBarSize={20} />
            <Line yAxisId="right" name="环比增长率" type="monotone" dataKey="rate" stroke="#13bca5" strokeWidth={2.5} dot={{ r: 3, fill: "#fff", strokeWidth: 2 }} activeDot={{ r: 5 }} />
          </ComposedChart>
        </ResponsiveContainer>
      </div>
      <div className="trend-summary">
        <span>周期汇总（2026-05-15 至 2026-06-14）</span>
        <strong>新增会员 26,843 人</strong>
        <strong className="positive">较上周期 +12.31%</strong>
        <span>日均新增 1,790 人</span>
        <span>峰值 2,356 人（06-06）</span>
      </div>
    </section>
  );
}

function LevelPanel() {
  return (
    <section className="panel level-panel">
      <div className="panel__head">
        <div><h2>会员等级分布</h2><p>当前有效会员等级结构</p></div>
        <button className="text-button">查看详情 <IconChevronRight size={15} /></button>
      </div>
      <div className="level-panel__content">
        <div className="donut-wrap">
          <ResponsiveContainer width="100%" height="100%">
            <PieChart>
              <Pie data={levels} dataKey="value" innerRadius={55} outerRadius={78} paddingAngle={2} stroke="none">
                {levels.map((entry) => <Cell key={entry.name} fill={entry.color} />)}
              </Pie>
              <Tooltip formatter={(value) => formatNumber(value)} />
            </PieChart>
          </ResponsiveContainer>
          <div className="donut-center"><span>总数</span><strong>128,670</strong></div>
        </div>
        <div className="legend-list">
          {levels.map((item) => (
            <div key={item.name}>
              <span className="legend-dot" style={{ background: item.color }} />
              <span>{item.name}</span>
              <strong>{formatNumber(item.value)}</strong>
              <small>{item.ratio}</small>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

function SourcePanel() {
  return (
    <section className="panel source-panel">
      <div className="panel__head">
        <div><h2>会员注册来源分析</h2><p>2026-05-15 至 2026-06-14</p></div>
        <button className="quiet-button">近30天 <IconChevronDown size={14} /></button>
      </div>
      <div className="source-table source-table--header"><span>注册来源</span><span>注册人数</span><span>来源占比</span></div>
      {sourceRows.map(([source, count, ratio, color]) => (
        <div className="source-table" key={source}>
          <strong>{source}</strong>
          <span>{count}</span>
          <div className="ratio-cell"><i className={`is-${color}`} style={{ width: `${ratio * 1.35}%` }} /><small>{ratio}%</small></div>
        </div>
      ))}
      <div className="source-total"><strong>合计</strong><strong>26,843</strong><strong>100%</strong></div>
    </section>
  );
}

function MiniDonut({ data, colors }) {
  return (
    <div className="mini-donut">
      <ResponsiveContainer width="100%" height="100%">
        <PieChart><Pie data={data} dataKey="value" innerRadius={28} outerRadius={42} paddingAngle={2} stroke="none">{data.map((item, i) => <Cell key={item.name} fill={colors[i]} />)}</Pie></PieChart>
      </ResponsiveContainer>
    </div>
  );
}

function PortraitPanel() {
  const gender = [{ name: "男", value: 61.32 }, { name: "女", value: 38.68 }];
  const active = [{ name: "高活跃", value: 32.45 }, { name: "中活跃", value: 41.23 }, { name: "低活跃", value: 26.32 }];
  const valueData = [{ name: "高价值", value: 18.62 }, { name: "中价值", value: 43.28 }, { name: "低价值", value: 38.1 }];
  return (
    <section className="panel portrait-panel">
      <div className="panel__head">
        <div><h2>用户画像</h2><p>核心人群特征与价值构成</p></div>
        <div className="panel-links"><button>近30天</button><button>查看全部画像 <IconChevronRight size={14} /></button></div>
      </div>
      <div className="portrait-grid">
        <article className="mini-card">
          <h3>性别比例</h3>
          <div className="mini-card__body"><MiniDonut data={gender} colors={["#2869f6", "#836ef4"]} /><ul><li><i className="dot-blue" />男 <strong>61.32%</strong></li><li><i className="dot-purple" />女 <strong>38.68%</strong></li></ul></div>
        </article>
        <article className="mini-card">
          <h3>年龄分布</h3>
          <div className="age-chart"><ResponsiveContainer width="100%" height="100%"><BarChart data={portraitBars}><Bar dataKey="value" radius={[5, 5, 2, 2]}>{portraitBars.map((entry, i) => <Cell key={entry.name} fill={["#8cb6ff", "#4e79f5", "#7466ec", "#9b8cf6", "#c5d3ff"][i]} />)}</Bar><XAxis dataKey="name" hide /><Tooltip /></BarChart></ResponsiveContainer></div>
          <div className="age-labels"><span>25-34</span><strong>39.75%</strong></div>
        </article>
        <article className="mini-card">
          <h3>活跃度分析</h3>
          <div className="mini-card__body"><MiniDonut data={active} colors={["#21b467", "#15c3aa", "#8b76ec"]} /><ul><li><i className="dot-green" />高活跃 <strong>32.45%</strong></li><li><i className="dot-teal" />中活跃 <strong>41.23%</strong></li><li><i className="dot-purple" />低活跃 <strong>26.32%</strong></li></ul></div>
        </article>
        <article className="mini-card occupation-card">
          <h3>职业分布</h3>
          {["企业职员", "个体经营", "学生", "自由职业"].map((item, index) => <div className="occupation-row" key={item}><span>{item}</span><i><b style={{ width: `${[78, 42, 31, 24][index]}%` }} /></i><strong>{[42.18, 18.72, 12.35, 8.96][index]}%</strong></div>)}
        </article>
        <article className="mini-card">
          <h3>价值分类</h3>
          <div className="mini-card__body"><MiniDonut data={valueData} colors={["#15a962", "#16bfaa", "#7f9bf6"]} /><ul><li><i className="dot-green" />高价值 <strong>18.62%</strong></li><li><i className="dot-teal" />中价值 <strong>43.28%</strong></li><li><i className="dot-blue" />低价值 <strong>38.10%</strong></li></ul></div>
        </article>
        <article className="mini-card platform-card">
          <h3>平台分布</h3>
          <div className="platform-ring"><MiniDonut data={[{ name: "小程序", value: 72 }, { name: "公众号", value: 18 }, { name: "APP", value: 10 }]} colors={["#2869f6", "#12bda7", "#7384ee"]} /></div>
          <ul><li><i className="dot-blue" />微信小程序 <strong>72.45%</strong></li><li><i className="dot-teal" />公众号 <strong>18.37%</strong></li><li><i className="dot-purple" />APP <strong>9.18%</strong></li></ul>
        </article>
      </div>
    </section>
  );
}

function ValueQuadrant() {
  const boxes = [
    { title: "重要保持", value: "8,342人", note: "24%", className: "keep" },
    { title: "重要发展", value: "6,175人", note: "18%", className: "grow" },
    { title: "一般保持", value: "7,856人", note: "30.36%", className: "normal" },
    { title: "低价值挽回", value: "3,470人", note: "13.46%", className: "winback" },
  ];
  return (
    <section className="panel quadrant-panel">
      <div className="panel__head panel__head--compact">
        <div><h2>会员价值分布象限</h2><p>截止日期：2026-06-14 · 对比周期 2026-05-15 至 2026-06-14</p></div>
        <div className="quadrant-totals"><span>上月会员数 <strong>22,356</strong></span><span>本月会员数 <strong>25,843</strong></span><span>本月消费额 <strong>1,562,748 元</strong></span></div>
      </div>
      <div className="quadrant-grid">
        {boxes.map((box) => <article className={`quadrant-box is-${box.className}`} key={box.title}><div><span>{box.title}</span><strong>{box.value}</strong><small>{box.note}</small></div><p>上月会员数：{box.className === "keep" ? "7,125" : "5,246"}<br />近 X 天消费额：842,635 元</p></article>)}
      </div>
      <div className="quadrant-axis"><span>低</span><span>消费金额</span><span>高</span></div>
    </section>
  );
}

function QuickActions({ onAction }) {
  const actions = [
    [IconUserPlus, "新增会员", "blue"],
    [IconUsersGroup, "创建分群", "green"],
    [IconDiscount2, "发放优惠券", "purple"],
    [IconDatabaseExport, "导出数据", "orange"],
  ];
  return (
    <section className="quick-actions">
      <strong>快捷操作</strong>
      {actions.map(([Icon, label, color]) => <button key={label} onClick={() => onAction(label)}><span className={`is-${color}`}><Icon size={18} /></span>{label}</button>)}
    </section>
  );
}

function Dashboard({ period, onPeriod, onToast, onAction }) {
  return (
    <>
      <SummaryStrip />
      <div className="dashboard-grid dashboard-grid--top">
        <TrendPanel period={period} onPeriod={onPeriod} onToast={onToast} />
        <LevelPanel />
      </div>
      <div className="dashboard-grid dashboard-grid--middle">
        <SourcePanel />
        <PortraitPanel />
      </div>
      <ValueQuadrant />
      <QuickActions onAction={onAction} />
    </>
  );
}

function FilterField({ label, placeholder, icon: Icon = IconSearch, value, onChange }) {
  return (
    <label className="filter-field"><span>{label}</span><div><Icon size={16} /><input placeholder={placeholder} value={value || ""} onChange={onChange} /></div></label>
  );
}

function MembersPage({ onToast, onAction }) {
  const [query, setQuery] = useState("");
  const [level, setLevel] = useState("全部等级");
  const [selected, setSelected] = useState([]);
  const visible = useMemo(() => members.filter((member) => {
    const hitText = !query || `${member.id}${member.name}${member.phone}${member.store}`.includes(query);
    const hitLevel = level === "全部等级" || member.level === level;
    return hitText && hitLevel;
  }), [query, level]);
  const allSelected = visible.length > 0 && visible.every((item) => selected.includes(item.id));
  const toggleAll = () => setSelected(allSelected ? selected.filter((id) => !visible.some((item) => item.id === id)) : [...new Set([...selected, ...visible.map((item) => item.id)])]);
  const toggleOne = (id) => setSelected((current) => current.includes(id) ? current.filter((item) => item !== id) : [...current, id]);
  return (
    <section className="members-page">
      <div className="page-title-row">
        <div><h1>会员列表</h1><p>统一查看、筛选与维护会员资料</p></div>
        <button className="primary-button" onClick={() => onAction("新增会员")}><IconPlus size={17} /> 新增会员</button>
      </div>
      <section className="panel filter-panel">
        <div className="filter-grid">
          <FilterField label="快速搜索" placeholder="会员编码、名称、手机号或门店" value={query} onChange={(event) => setQuery(event.target.value)} />
          <label className="filter-field"><span>会员等级</span><div><IconIdBadge2 size={16} /><select value={level} onChange={(event) => setLevel(event.target.value)}><option>全部等级</option>{levels.map((item) => <option key={item.name}>{item.name}</option>)}</select></div></label>
          <label className="filter-field"><span>注册日期</span><div><IconCalendar size={16} /><input value="2026-06-01 至 2026-06-14" readOnly /></div></label>
          <label className="filter-field"><span>归属门店</span><div><IconBuildingStore size={16} /><select><option>全部门店</option><option>杭州西湖店</option><option>宁波鄞州店</option></select></div></label>
        </div>
        <div className="filter-actions"><button className="outline-button" onClick={() => { setQuery(""); setLevel("全部等级"); }}><IconRefresh size={16} /> 重置</button><button className="primary-button" onClick={() => onToast(`已找到 ${visible.length} 位会员`)}><IconSearch size={16} /> 查询</button><button className="text-button"><IconFilter size={16} /> 高级筛选条件</button></div>
      </section>
      <section className="panel member-table-panel">
        <div className="table-toolbar">
          <div><strong>会员数据</strong><span>共 128,670 位会员</span></div>
          <div className="toolbar-actions"><button onClick={() => onToast("导入模板已准备下载")}>导入</button><button onClick={() => onToast("会员数据已加入导出任务")}>导出</button><button disabled={!selected.length} onClick={() => onToast(`已为 ${selected.length} 位会员创建发券任务`)}>券发放</button><button disabled={!selected.length}>等级变更</button></div>
        </div>
        <div className="table-scroll">
          <table>
            <thead><tr><th><input type="checkbox" checked={allSelected} onChange={toggleAll} /></th><th>会员信息</th><th>手机号码</th><th>归属门店</th><th>会员等级</th><th>会员来源</th><th>注册日期</th><th>状态</th><th>操作</th></tr></thead>
            <tbody>{visible.map((member) => <tr key={member.id}><td><input type="checkbox" checked={selected.includes(member.id)} onChange={() => toggleOne(member.id)} /></td><td><div className="member-cell"><span>{member.name.slice(0, 1)}</span><div><strong>{member.name}</strong><small>{member.id}</small></div></div></td><td>{member.phone}</td><td>{member.store}</td><td><span className={`level-pill is-${member.level}`}>{member.level}</span></td><td>{member.source}</td><td>{member.date}</td><td><span className={`status-pill is-${member.status}`}>{member.status}</span></td><td><button className="table-link" onClick={() => onToast(`正在查看 ${member.name} 的会员详情`)}>查看</button></td></tr>)}</tbody>
          </table>
          {!visible.length && <div className="empty-state"><IconUsers size={38} /><strong>没有匹配的会员</strong><p>调整筛选条件后再试一次</p></div>}
        </div>
        <div className="table-footer"><span>已选择 <strong>{selected.length}</strong> 项</span><div><button disabled><IconChevronLeft size={16} /></button><button className="is-current">1</button><button>2</button><button>3</button><button><IconChevronRight size={16} /></button></div><span>10 条 / 页</span></div>
      </section>
    </section>
  );
}

const insightCards = [
  { title: "新增趋势上升", desc: "本月新增会员 6,782 人，较上月 ↑ 12.31%，主要增长来自小程序商城。", tone: "green", icon: IconTrendingUp },
  { title: "高价值会员占比偏低", desc: "高价值会员占 18.62%，低于行业均值 25%，建议加强会员分层运营。", tone: "orange", icon: IconActivity },
  { title: "会员活跃度下降", desc: "低活跃会员占比 26.32%，较上周期 ↑ 3.18%，建议触达唤醒。", tone: "purple", icon: IconTrendingDown },
];

const DEFAULT_FAB_SIZE = { width: 118, height: 42 };

function clampFabPosition(x, y, width = DEFAULT_FAB_SIZE.width, height = DEFAULT_FAB_SIZE.height) {
  if (typeof window === "undefined") return { x, y };
  return {
    x: Math.min(Math.max(8, x), Math.max(8, window.innerWidth - width - 8)),
    y: Math.min(Math.max(8, y), Math.max(8, window.innerHeight - height - 8)),
  };
}

function getInitialFabPosition() {
  if (typeof window === "undefined") return { x: 20, y: 20 };
  return clampFabPosition(window.innerWidth - DEFAULT_FAB_SIZE.width - 20, window.innerHeight - DEFAULT_FAB_SIZE.height - 20);
}

function AIPanel({ open, onToggle, onToast, onAction }) {
  const [tab, setTab] = useState("洞察");
  const [prompt, setPrompt] = useState("");
  const [fabPosition, setFabPosition] = useState(getInitialFabPosition);
  const dragState = useRef({ active: false, moved: false, suppressClick: false });
  const moveFab = (clientX, clientY) => {
    const state = dragState.current;
    if (!state.active) return;
    const dx = clientX - state.startX;
    const dy = clientY - state.startY;
    if (Math.abs(dx) + Math.abs(dy) > 4) state.moved = true;
    setFabPosition(clampFabPosition(state.startLeft + dx, state.startTop + dy, state.width, state.height));
  };
  const finishFabDrag = () => {
    const state = dragState.current;
    if (!state.active) return;
    dragState.current = { active: false, moved: false, suppressClick: state.moved };
  };
  useEffect(() => {
    const handleResize = () => setFabPosition((position) => clampFabPosition(position.x, position.y));
    const handleMouseMove = (event) => moveFab(event.clientX, event.clientY);
    const handleMouseUp = () => finishFabDrag();
    const handleTouchMove = (event) => {
      const touch = event.touches[0];
      if (!touch || !dragState.current.active) return;
      event.preventDefault();
      moveFab(touch.clientX, touch.clientY);
    };
    const handleTouchEnd = () => finishFabDrag();
    window.addEventListener("resize", handleResize);
    window.addEventListener("mousemove", handleMouseMove);
    window.addEventListener("mouseup", handleMouseUp);
    window.addEventListener("touchmove", handleTouchMove, { passive: false });
    window.addEventListener("touchend", handleTouchEnd);
    window.addEventListener("touchcancel", handleTouchEnd);
    return () => {
      window.removeEventListener("resize", handleResize);
      window.removeEventListener("mousemove", handleMouseMove);
      window.removeEventListener("mouseup", handleMouseUp);
      window.removeEventListener("touchmove", handleTouchMove);
      window.removeEventListener("touchend", handleTouchEnd);
      window.removeEventListener("touchcancel", handleTouchEnd);
    };
  }, []);
  const startFabDrag = (clientX, clientY, rect) => {
    dragState.current = {
      active: true,
      moved: false,
      suppressClick: false,
      startX: clientX,
      startY: clientY,
      startLeft: rect.left,
      startTop: rect.top,
      width: rect.width,
      height: rect.height,
    };
  };
  const handleFabMouseDown = (event) => {
    if (event.button !== undefined && event.button !== 0) return;
    startFabDrag(event.clientX, event.clientY, event.currentTarget.getBoundingClientRect());
  };
  const handleFabTouchStart = (event) => {
    const touch = event.touches[0];
    if (!touch) return;
    startFabDrag(touch.clientX, touch.clientY, event.currentTarget.getBoundingClientRect());
  };
  const handleFabClick = (event) => {
    if (dragState.current.suppressClick) {
      dragState.current.suppressClick = false;
      event.preventDefault();
      return;
    }
    onToggle();
  };
  if (!open) return <button className="ai-fab" type="button" aria-label="打开 AI 洞察" style={{ left: `${fabPosition.x}px`, top: `${fabPosition.y}px` }} onMouseDown={handleFabMouseDown} onTouchStart={handleFabTouchStart} onClick={handleFabClick}><IconSparkles size={21} /><span>AI 洞察</span></button>;
  return (
    <aside className="ai-panel">
      <div className="ai-panel__head"><div><span className="ai-logo"><IconBrain size={21} /></span><strong>AI 助手</strong></div><div><button className="icon-button" onClick={onToggle}><IconChevronRight size={19} /></button></div></div>
      <div className="ai-tabs">{["洞察", "建议", "问答"].map((item) => <button className={tab === item ? "is-active" : ""} key={item} onClick={() => setTab(item)}>{item}</button>)}</div>
      <div className="ai-panel__body">
        {tab === "洞察" && <><h3>本期洞察</h3><div className="insight-list">{insightCards.map(({ title, desc, tone, icon: Icon }) => <article className={`insight-card is-${tone}`} key={title}><span><Icon size={18} /></span><div><strong>{title}</strong><p>{desc}</p></div></article>)}</div></>}
        {tab === "建议" && <><h3>智能建议</h3><div className="suggestion-list"><article><strong>针对重要发展会员</strong><p>推送成长型会员礼包，提升升级效率。</p><button onClick={() => onAction("发放优惠券")}>去执行</button></article><article><strong>优化会员等级权益</strong><p>升级银卡 / 金卡权益激励，促进成长。</p><button onClick={() => onToast("已打开等级权益配置")}>去配置</button></article><article><strong>沉睡会员唤醒计划</strong><p>基于最后活跃时间触达，提升复购。</p><button onClick={() => onAction("创建分群")}>去创建</button></article></div></>}
        {tab === "问答" && <div className="qa-welcome"><IconMessageCircle size={36} /><h3>问我任何会员经营问题</h3><p>我会结合当前会员数据给出分析和下一步建议。</p></div>}
        <h3>你可以问我</h3>
        <div className="prompt-chips">{["本月新增会员来源占比如何？", "近 7 天新增趋势怎么样？", "高价值会员的消费特征是什么？", "哪些渠道带来的会员质量最高？"].map((item) => <button key={item} onClick={() => setPrompt(item)}>{item}</button>)}</div>
      </div>
      <div className="ai-input"><input value={prompt} onChange={(event) => setPrompt(event.target.value)} placeholder="请输入问题，获取数据洞察..." /><button onClick={() => { if (prompt) { onToast("AI 正在生成洞察摘要"); setPrompt(""); } }}><IconSend2 size={18} /></button></div>
      <small className="ai-disclaimer">内容由 AI 生成，仅供参考</small>
    </aside>
  );
}

function ActionModal({ action, onClose, onToast }) {
  if (!action) return null;
  const isMember = action === "新增会员";
  return (
    <div className="modal-backdrop" role="presentation" onMouseDown={onClose}>
      <div className="modal" role="dialog" aria-modal="true" onMouseDown={(event) => event.stopPropagation()}>
        <div className="modal__head"><div><span className="modal-icon">{isMember ? <IconUserPlus size={21} /> : action === "创建分群" ? <IconUsersGroup size={21} /> : <IconBolt size={21} />}</span><div><h2>{action}</h2><p>{isMember ? "录入基础资料并创建会员档案" : "完成配置后即可提交执行"}</p></div></div><button className="icon-button" onClick={onClose}><IconX size={19} /></button></div>
        <div className="modal__body">
          {isMember ? <><label>会员名称<input placeholder="请输入会员名称" /></label><label>手机号码<input placeholder="请输入手机号码" /></label><label>归属门店<select><option>杭州西湖店</option><option>宁波鄞州店</option></select></label><label>初始等级<select><option>普通卡</option><option>银卡</option></select></label></> : <><label>任务名称<input placeholder={`请输入${action}任务名称`} /></label><label>目标会员<select><option>高价值活跃会员</option><option>近 30 天新增会员</option><option>低活跃待唤醒会员</option></select></label><label className="modal__full">执行说明<textarea placeholder="补充本次任务的目标和说明" /></label></>}
        </div>
        <div className="modal__footer"><button className="outline-button" onClick={onClose}>取消</button><button className="primary-button" onClick={() => { onToast(`${action}任务已保存`); onClose(); }}>确认保存</button></div>
      </div>
    </div>
  );
}

export function App() {
  const [activeDomain, setActiveDomain] = useState("用户数据");
  const [activePage, setActivePage] = useState("dashboard");
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const [mobileNav, setMobileNav] = useState(false);
  const [aiOpen, setAiOpen] = useState(() => window.innerWidth > 1060);
  const [period, setPeriod] = useState("30");
  const [toast, setToast] = useState("");
  const [action, setAction] = useState("");
  const toastTimeout = useRef(null);

  const showToast = (message) => {
    setToast(message);
    window.clearTimeout(toastTimeout.current);
    toastTimeout.current = window.setTimeout(() => setToast(""), 2600);
  };

  const navigate = (id) => {
    setActivePage(id);
    setMobileNav(false);
  };

  const currentMeta = PAGE_META[activePage] || { title: "功能页面", group: activeDomain, domain: activeDomain };

  return (
    <div className={`app-shell ${sidebarCollapsed ? "sidebar-collapsed" : ""} ${aiOpen ? "ai-open" : ""}`}>
      <Sidebar activeDomain={activeDomain} activePage={activePage} collapsed={sidebarCollapsed} mobileOpen={mobileNav} onNavigate={navigate} onToggle={() => setSidebarCollapsed((value) => !value)} onClose={() => setMobileNav(false)} />
      <Header activeDomain={activeDomain} onDomain={(domain) => { setActiveDomain(domain); setActivePage(DOMAIN_PAGES[domain]); setMobileNav(false); showToast(`已切换至${domain}`); }} onMenu={() => setMobileNav(true)} onToast={showToast} />
      <main className="main-area">
        <div className="breadcrumb"><span /><strong>{currentMeta.group}</strong>{activePage !== DOMAIN_PAGES[activeDomain] && <><IconChevronRight size={14} /><span>{currentMeta.title}</span></>}</div>
        <div className="content-scroll">
          {activePage === "dashboard" ? <Dashboard period={period} onPeriod={setPeriod} onToast={showToast} onAction={setAction} /> : activePage === "members" ? <MembersPage onToast={showToast} onAction={setAction} /> : <BusinessPageRouter activePage={activePage} onToast={showToast} onAction={setAction} />}
        </div>
      </main>
      <AIPanel open={aiOpen} onToggle={() => setAiOpen((value) => !value)} onToast={showToast} onAction={setAction} />
      <ActionModal action={action} onClose={() => setAction("")} onToast={showToast} />
      {toast && <div className="toast"><IconSparkles size={17} />{toast}</div>}
    </div>
  );
}
