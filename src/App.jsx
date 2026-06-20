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
import { useAppData } from "./data/useAppData.js";
import { DOMAIN_NAV, DOMAIN_NAVIGATION, DOMAIN_PAGES, PAGE_META } from "./navigationConfig.jsx";

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

function SummaryStrip({ data }) {
  const summary = data.summary;
  return (
    <section className="summary-strip">
      <MetricCard icon={IconUsers} label="会员总数" value={summary.totalMembers} delta={summary.totalDelta} color="blue" />
      <MetricCard icon={IconCalendar} label="昨日新增" value={summary.yesterdayNew} delta={summary.yesterdayDelta} color="green" />
      <MetricCard icon={IconCalendar} label="本月新增" value={summary.monthNew} delta={summary.monthDelta} color="orange" />
      <MetricCard icon={IconTrendingUp} label="本季新增" value={summary.quarterNew} delta={summary.quarterDelta} color="gold" />
      <div className="growth-metrics">
        <div><span>日环比增长率</span><strong>{summary.dailyGrowth}</strong></div>
        <div><span>月环比增长率</span><strong>{summary.monthlyGrowth}</strong></div>
        <div><span>季环比增长率</span><strong>{summary.quarterlyGrowth}</strong></div>
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

function TrendPanel({ period, onPeriod, onToast, data }) {
  const chartRows = period === "30" ? data.trends30 : data.trends90;
  const periodLabel = data.periodLabel;
  const periodSummary = data.periodSummary;
  const periodTotal = periodSummary.total;
  const comparison = periodSummary.comparison;
  const comparisonClass = comparison.startsWith("-") ? "negative" : "positive";
  const dailyAverage = periodSummary.dailyAverage;
  const peakMembers = periodSummary.peakMembers;
  const peakDay = periodSummary.peakDay;
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
          <button className="quiet-button"><IconCalendar size={16} /> {periodLabel}</button>
          <button className="outline-button" onClick={() => onToast("趋势图已加入导出任务")}><IconDatabaseExport size={16} /> 导出图表</button>
        </div>
      </div>
      <div className="trend-chart">
        <ResponsiveContainer width="100%" height="100%">
          <ComposedChart data={chartRows} margin={{ top: 14, right: 4, left: -22, bottom: 0 }}>
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
        <span>周期汇总（{periodLabel}）</span>
        <strong>新增会员 {periodTotal} 人</strong>
        <strong className={comparisonClass}>较上周期 {comparison}</strong>
        <span>日均新增 {dailyAverage} 人</span>
        <span>峰值 {peakMembers} 人（{peakDay}）</span>
      </div>
    </section>
  );
}

function LevelPanel({ data }) {
  const levelRows = data.levels;
  const totalLabel = data.totalMembersLabel;
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
              <Pie data={levelRows} dataKey="value" innerRadius={55} outerRadius={78} paddingAngle={2} stroke="none">
                {levelRows.map((entry) => <Cell key={entry.name} fill={entry.color} />)}
              </Pie>
              <Tooltip formatter={(value) => formatNumber(value)} />
            </PieChart>
          </ResponsiveContainer>
          <div className="donut-center"><span>总数</span><strong>{totalLabel}</strong></div>
        </div>
        <div className="legend-list">
          {levelRows.map((item) => (
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

function SourcePanel({ data }) {
  const rows = data.sourceRows;
  const total = data.sourceTotal;
  const periodLabel = data.periodLabel;
  return (
    <section className="panel source-panel">
      <div className="panel__head">
        <div><h2>会员注册来源分析</h2><p>{periodLabel}</p></div>
        <button className="quiet-button">近30天 <IconChevronDown size={14} /></button>
      </div>
      <div className="source-table source-table--header"><span>注册来源</span><span>注册人数</span><span>来源占比</span></div>
      {rows.map(([source, count, ratio, color]) => (
        <div className="source-table" key={source}>
          <strong>{source}</strong>
          <span>{count}</span>
          <div className="ratio-cell"><i className={`is-${color}`} style={{ width: `${ratio * 1.35}%` }} /><small>{ratio}%</small></div>
        </div>
      ))}
      <div className="source-total"><strong>合计</strong><strong>{total}</strong><strong>100%</strong></div>
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

function PortraitPanel({ data }) {
  const gender = data.portrait.gender;
  const active = data.portrait.active;
  const valueData = data.portrait.valueData;
  const city = data.portrait.city;
  const platform = data.portrait.platform;
  const ageRows = data.portraitBars;
  const dots = ["dot-blue", "dot-purple", "dot-green", "dot-teal"];
  return (
    <section className="panel portrait-panel">
      <div className="panel__head">
        <div><h2>用户画像</h2><p>核心人群特征与价值构成</p></div>
        <div className="panel-links"><button>近30天</button><button>查看全部画像 <IconChevronRight size={14} /></button></div>
      </div>
      <div className="portrait-grid">
        <article className="mini-card">
          <h3>性别比例</h3>
          <div className="mini-card__body"><MiniDonut data={gender} colors={["#2869f6", "#836ef4", "#12bda7"]} /><ul>{gender.map((item, index) => <li key={item.name}><i className={dots[index % dots.length]} />{item.name} <strong>{item.value}%</strong></li>)}</ul></div>
        </article>
        <article className="mini-card">
          <h3>年龄分布</h3>
          <div className="age-chart"><ResponsiveContainer width="100%" height="100%"><BarChart data={ageRows}><Bar dataKey="value" radius={[5, 5, 2, 2]}>{ageRows.map((entry, i) => <Cell key={entry.name} fill={["#8cb6ff", "#4e79f5", "#7466ec", "#9b8cf6", "#c5d3ff"][i]} />)}</Bar><XAxis dataKey="name" hide /><Tooltip /></BarChart></ResponsiveContainer></div>
          <div className="age-labels"><span>{ageRows[0]?.name || "暂无数据"}</span><strong>{ageRows[0]?.value ?? 0}%</strong></div>
        </article>
        <article className="mini-card">
          <h3>活跃度分析</h3>
          <div className="mini-card__body"><MiniDonut data={active} colors={["#21b467", "#15c3aa", "#8b76ec"]} /><ul>{active.map((item, index) => <li key={item.name}><i className={["dot-green", "dot-teal", "dot-purple"][index % 3]} />{item.name} <strong>{item.value}%</strong></li>)}</ul></div>
        </article>
        <article className="mini-card occupation-card">
          <h3>城市分布</h3>
          {city.map((item) => <div className="occupation-row" key={item.name}><span>{item.name}</span><i><b style={{ width: `${Math.min(item.value * 2, 100)}%` }} /></i><strong>{item.value}%</strong></div>)}
        </article>
        <article className="mini-card">
          <h3>价值分类</h3>
          <div className="mini-card__body"><MiniDonut data={valueData} colors={["#15a962", "#16bfaa", "#7f9bf6"]} /><ul>{valueData.map((item, index) => <li key={item.name}><i className={["dot-green", "dot-teal", "dot-blue"][index % 3]} />{item.name} <strong>{item.value}%</strong></li>)}</ul></div>
        </article>
        <article className="mini-card platform-card">
          <h3>平台分布</h3>
          <div className="platform-ring"><MiniDonut data={platform} colors={["#2869f6", "#12bda7", "#7384ee", "#f6a817"]} /></div>
          <ul>{platform.map((item, index) => <li key={item.name}><i className={["dot-blue", "dot-teal", "dot-purple", "dot-green"][index % 4]} />{item.name} <strong>{item.value}%</strong></li>)}</ul>
        </article>
      </div>
    </section>
  );
}

function ValueQuadrant({ data }) {
  const quadrant = data.valueQuadrant;
  const boxes = quadrant.boxes;
  return (
    <section className="panel quadrant-panel">
      <div className="panel__head panel__head--compact">
        <div><h2>会员价值分布象限</h2><p>截止日期：{quadrant.cutoffLabel} · {quadrant.compareLabel}</p></div>
        <div className="quadrant-totals"><span>上期会员数 <strong>{quadrant.previousMembers}</strong></span><span>当前会员数 <strong>{quadrant.currentMembers}</strong></span><span>当前消费额 <strong>{quadrant.salesTotal}</strong></span></div>
      </div>
      <div className="quadrant-grid">
        {boxes.map((box) => <article className={`quadrant-box is-${box.className}`} key={box.title}><div><span>{box.title}</span><strong>{box.value}</strong><small>{box.note}</small></div><p>上期会员数：{box.previous}<br />累计消费额：{box.spend}</p></article>)}
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

function Dashboard({ period, onPeriod, onToast, onAction, data }) {
  return (
    <>
      <SummaryStrip data={data} />
      <div className="dashboard-grid dashboard-grid--top">
        <TrendPanel period={period} onPeriod={onPeriod} onToast={onToast} data={data} />
        <LevelPanel data={data} />
      </div>
      <div className="dashboard-grid dashboard-grid--middle">
        <SourcePanel data={data} />
        <PortraitPanel data={data} />
      </div>
      <ValueQuadrant data={data} />
      <QuickActions onAction={onAction} />
    </>
  );
}

function FilterField({ label, placeholder, icon: Icon = IconSearch, value, onChange }) {
  return (
    <label className="filter-field"><span>{label}</span><div><Icon size={16} /><input placeholder={placeholder} value={value || ""} onChange={onChange} /></div></label>
  );
}

function MembersPage({ onToast, onAction, data }) {
  const [query, setQuery] = useState("");
  const [level, setLevel] = useState("全部等级");
  const [store, setStore] = useState("全部门店");
  const [selected, setSelected] = useState([]);
  const memberRows = data.members;
  const levelRows = data.dashboard.levels;
  const stores = data.filterOptions.stores;
  const totalLabel = data.dashboard.totalMembersLabel;
  const visible = useMemo(() => memberRows.filter((member) => {
    const hitText = !query || `${member.id}${member.name}${member.phone}${member.store}`.includes(query);
    const hitLevel = level === "全部等级" || member.level === level;
    const hitStore = store === "全部门店" || member.store === store;
    return hitText && hitLevel && hitStore;
  }), [query, level, store, memberRows]);
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
          <label className="filter-field"><span>会员等级</span><div><IconIdBadge2 size={16} /><select value={level} onChange={(event) => setLevel(event.target.value)}><option>全部等级</option>{levelRows.map((item) => <option key={item.name}>{item.name}</option>)}</select></div></label>
          <label className="filter-field"><span>注册日期</span><div><IconCalendar size={16} /><input value={data.filterOptions.registrationRange} readOnly /></div></label>
          <label className="filter-field"><span>归属门店</span><div><IconBuildingStore size={16} /><select value={store} onChange={(event) => setStore(event.target.value)}><option>全部门店</option>{stores.map((item) => <option key={item}>{item}</option>)}</select></div></label>
        </div>
        <div className="filter-actions"><button className="outline-button" onClick={() => { setQuery(""); setLevel("全部等级"); setStore("全部门店"); }}><IconRefresh size={16} /> 重置</button><button className="primary-button" onClick={() => onToast(`已找到 ${visible.length} 位会员`)}><IconSearch size={16} /> 查询</button><button className="text-button"><IconFilter size={16} /> 高级筛选条件</button></div>
      </section>
      <section className="panel member-table-panel">
        <div className="table-toolbar">
          <div><strong>会员数据</strong><span>共 {totalLabel} 位会员</span></div>
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

function AIPanel({ open, onToggle, onToast, onAction, data }) {
  const [tab, setTab] = useState("洞察");
  const [prompt, setPrompt] = useState("");
  const [fabPosition, setFabPosition] = useState(getInitialFabPosition);
  const dragState = useRef({ active: false, moved: false, suppressClick: false });
  const aiInsightCards = data.clawInsightCards.map((item, index) => ({
    ...item,
    icon: item.icon || [IconTrendingUp, IconActivity, IconTrendingDown][index] || IconSparkles,
  }));
  const aiSuggestionCards = data.clawSuggestionCards;
  const aiPromptChips = data.clawPromptTemplates.map((item) => item.prompt);
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
        {tab === "洞察" && <><h3>本期洞察</h3><div className="insight-list">{aiInsightCards.map(({ title, desc, tone, icon: Icon }) => <article className={`insight-card is-${tone}`} key={title}><span><Icon size={18} /></span><div><strong>{title}</strong><p>{desc}</p></div></article>)}</div></>}
        {tab === "建议" && <><h3>智能建议</h3><div className="suggestion-list">{aiSuggestionCards.map((item) => <article key={item.title}><strong>{item.title}</strong><p>{item.desc}</p><button onClick={() => item.action?.includes("配置") ? onToast("已打开等级权益配置") : onAction(item.action || "创建分群")}>{item.action || "去执行"}</button></article>)}</div></>}
        {tab === "问答" && <div className="qa-welcome"><IconMessageCircle size={36} /><h3>问我任何会员经营问题</h3><p>我会结合当前会员数据给出分析和下一步建议。</p></div>}
        <h3>你可以问我</h3>
        <div className="prompt-chips">{aiPromptChips.map((item) => <button key={item} onClick={() => setPrompt(item)}>{item}</button>)}</div>
      </div>
      <div className="ai-input"><input value={prompt} onChange={(event) => setPrompt(event.target.value)} placeholder="请输入问题，获取数据洞察..." /><button onClick={() => { if (prompt) { onToast("AI 正在生成洞察摘要"); setPrompt(""); } }}><IconSend2 size={18} /></button></div>
      <small className="ai-disclaimer">内容由 AI 生成，仅供参考</small>
    </aside>
  );
}

function ActionModal({ action, onClose, onToast, data }) {
  if (!action) return null;
  const isMember = action === "新增会员";
  const stores = data.filterOptions.stores;
  const levels = data.dashboard.levels.map((level) => level.name);
  const segments = data.segments.map((segment) => segment.name);
  return (
    <div className="modal-backdrop" role="presentation" onMouseDown={onClose}>
      <div className="modal" role="dialog" aria-modal="true" onMouseDown={(event) => event.stopPropagation()}>
        <div className="modal__head"><div><span className="modal-icon">{isMember ? <IconUserPlus size={21} /> : action === "创建分群" ? <IconUsersGroup size={21} /> : <IconBolt size={21} />}</span><div><h2>{action}</h2><p>{isMember ? "录入基础资料并创建会员档案" : "完成配置后即可提交执行"}</p></div></div><button className="icon-button" onClick={onClose}><IconX size={19} /></button></div>
        <div className="modal__body">
          {isMember ? <><label>会员名称<input placeholder="请输入会员名称" /></label><label>手机号码<input placeholder="请输入手机号码" /></label><label>归属门店<select>{stores.map((store) => <option key={store}>{store}</option>)}</select></label><label>初始等级<select>{levels.map((level) => <option key={level}>{level}</option>)}</select></label></> : <><label>任务名称<input placeholder={`请输入${action}任务名称`} /></label><label>目标会员<select>{segments.map((segment) => <option key={segment}>{segment}</option>)}</select></label><label className="modal__full">执行说明<textarea placeholder="补充本次任务的目标和说明" /></label></>}
        </div>
        <div className="modal__footer"><button className="outline-button" onClick={onClose}>取消</button><button className="primary-button" onClick={() => { onToast(`${action}任务已保存`); onClose(); }}>确认保存</button></div>
      </div>
    </div>
  );
}

function DatabaseState({ status, error, onRetry }) {
  const loading = status === "loading";
  return (
    <main className="database-state">
      <span><IconDatabaseExport size={30} /></span>
      <h1>{loading ? "正在连接 MySQL" : "MySQL 数据加载失败"}</h1>
      <p>{loading ? "系统只显示数据库实时数据，请稍候。" : error?.message || "请检查数据库和 API 配置。"}</p>
      {!loading && <button className="primary-button" onClick={onRetry}><IconRefresh size={16} />重新连接</button>}
    </main>
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
  const previousViewportWidth = useRef(window.innerWidth);
  const { data: appData, status: dataStatus, error: dataError, reload: reloadData } = useAppData();

  useEffect(() => {
    const handleResize = () => {
      const width = window.innerWidth;
      if (width <= 1060 && previousViewportWidth.current > 1060) setAiOpen(false);
      if (width <= 820 && previousViewportWidth.current > 820) setMobileNav(false);
      previousViewportWidth.current = width;
    };
    window.addEventListener("resize", handleResize);
    return () => window.removeEventListener("resize", handleResize);
  }, []);

  if (dataStatus !== "live" || !appData) {
    return <DatabaseState status={dataStatus} error={dataError} onRetry={reloadData} />;
  }

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
          {activePage === "dashboard" ? <Dashboard period={period} onPeriod={setPeriod} onToast={showToast} onAction={setAction} data={appData.dashboard} /> : activePage === "members" ? <MembersPage onToast={showToast} onAction={setAction} data={appData} /> : <BusinessPageRouter activePage={activePage} onToast={showToast} onAction={setAction} data={appData} />}
        </div>
      </main>
      <AIPanel open={aiOpen} onToggle={() => setAiOpen((value) => !value)} onToast={showToast} onAction={setAction} data={appData} />
      <ActionModal action={action} onClose={() => setAction("")} onToast={showToast} data={appData} />
      {toast && <div className="toast"><IconSparkles size={17} />{toast}</div>}
    </div>
  );
}
