import { useEffect, useMemo, useState } from "react";
import {
  IconBolt,
  IconBuildingStore,
  IconChartBar,
  IconCheck,
  IconChevronRight,
  IconClipboardData,
  IconDatabaseExport,
  IconRefresh,
  IconSparkles,
  IconTargetArrow,
  IconUsersGroup,
} from "@tabler/icons-react";
import {
  Area,
  AreaChart,
  CartesianGrid,
  Line,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from "recharts";

const STAGE_ICONS = {
  company: IconBuildingStore,
  region: IconTargetArrow,
  store: IconBuildingStore,
  segment: IconUsersGroup,
  strategy: IconSparkles,
  task: IconBolt,
  review: IconChartBar,
};

const STATUS_TONES = {
  active: "blue",
  attention: "orange",
  recommended: "purple",
  running: "green",
  completed: "green",
};

function stageInstruction(stageId) {
  return {
    company: "先看公司整体会员资产是否健康",
    region: "比较区域价值规模与提升空间",
    store: "找到最值得优先投入的门店",
    segment: "锁定具体可运营的人群包",
    strategy: "选择模型推荐的价值提升动作",
    task: "明确负责人、渠道、节点和时间",
    review: "比较目标与实际，决定继续或调整",
  }[stageId] || "查看当前层级的价值结论";
}

function ModelTooltip({ active, payload, label }) {
  if (!active || !payload?.length) return null;
  return (
    <div className="chart-tooltip">
      <strong>{label}</strong>
      {payload.map((item) => <span key={item.dataKey} style={{ color: item.color }}>{item.name}：¥{Number(item.value).toLocaleString()}</span>)}
    </div>
  );
}

function EmptyModel() {
  return (
    <section className="business-page ltv-page">
      <div className="workspace-title"><div><h1>单客模型 / LTV</h1><p>数据库中尚未配置模型快照</p></div></div>
      <div className="panel business-empty"><IconDatabaseExport size={34}/><strong>暂无 LTV 模型数据</strong><p>请先执行数据库迁移后重新加载。</p></div>
    </section>
  );
}

export function LtvModelPage({ data, onToast }) {
  const model = data.ltvModel;
  const nodes = model?.nodes || [];
  const stages = model?.stages || [];
  const rootNode = useMemo(() => nodes.find((node) => node.type === "company" && node.parentId == null), [nodes]);
  const [stageIndex, setStageIndex] = useState(0);
  const [path, setPath] = useState([]);

  useEffect(() => {
    setStageIndex(0);
    setPath(rootNode ? [rootNode.id] : []);
  }, [model?.asOf, rootNode?.id]);

  if (!model || !stages.length || !nodes.length || !rootNode) return <EmptyModel/>;

  const stage = stages[stageIndex];
  const parentId = stageIndex === 0 ? null : path[stageIndex - 1];
  const candidates = nodes.filter((node) => node.type === stage.id && (stageIndex === 0 ? node.parentId == null : node.parentId === parentId));
  const selectedNode = candidates.find((node) => node.id === path[stageIndex]) || candidates[0];
  const metrics = selectedNode?.metrics || {};
  const kpis = Array.isArray(metrics.kpis) ? metrics.kpis : [];
  const details = Array.isArray(metrics.details) ? metrics.details : [];
  const trend = Array.isArray(metrics.trend) ? metrics.trend : [];
  const nextStage = stages[stageIndex + 1];

  const selectNode = (node) => {
    setPath((current) => {
      const next = current.slice(0, stageIndex);
      next[stageIndex] = node.id;
      return next;
    });
  };

  const openStage = (index) => {
    if (index > stageIndex || !path[index]) return;
    setStageIndex(index);
    setPath((current) => current.slice(0, index + 1));
  };

  const goNext = () => {
    if (!selectedNode) return;
    if (!nextStage) {
      onToast(metrics.verdict || "LTV 复盘结论已生成");
      return;
    }
    const children = nodes.filter((node) => node.type === nextStage.id && node.parentId === selectedNode.id);
    if (!children.length) {
      onToast(`MySQL 中尚未配置${selectedNode.name}的${nextStage.label}数据`);
      return;
    }
    setPath((current) => {
      const next = current.slice(0, stageIndex + 1);
      next[stageIndex] = selectedNode.id;
      next[stageIndex + 1] = children[0].id;
      return next;
    });
    setStageIndex((index) => index + 1);
  };

  const resetFlow = () => {
    setStageIndex(0);
    setPath([rootNode.id]);
    onToast("已返回公司级 LTV 总览");
  };

  const selectedPath = stages.slice(0, stageIndex + 1).map((item, index) => ({
    stage: item,
    node: nodes.find((node) => node.id === path[index]),
  })).filter((item) => item.node);

  return (
    <section className="business-page ltv-page">
      <div className="workspace-title">
        <div><h1>单客模型 / LTV</h1><p>从公司机会定位到策略执行与价值复盘，一条链路看清“呈现什么、怎么使用”</p></div>
        <div className="workspace-title__actions">
          <button className="outline-button" onClick={resetFlow}><IconRefresh size={16}/>重新演示</button>
          <button className="primary-button" onClick={() => onToast("LTV 演示摘要已加入导出任务")}><IconDatabaseExport size={16}/>导出演示摘要</button>
        </div>
      </div>

      <section className="ltv-answer panel">
        <div className="ltv-answer__intro">
          <span><IconSparkles size={22}/></span>
          <div><strong>2026-06-25 会议问题的产品化回答</strong><p>单客模型不是孤立的一张分数表，而是从发现机会到验证结果的经营决策链。</p></div>
        </div>
        <div className="ltv-answer__columns">
          <article><small>最终呈现是什么</small><strong>一条可下钻的 LTV 经营地图</strong><p>每一级都显示对象、关键指标、系统结论和下一步动作，最终落到任务与复盘。</p></article>
          <article><small>业务人员怎么用</small><strong>先找机会，再执行，再验证</strong><p>公司看方向、区域分资源、门店选人群、运营定策略、店长做任务、负责人看结果。</p></article>
        </div>
      </section>

      <section className="ltv-stage-rail" aria-label="LTV 下钻阶段">
        {stages.map((item, index) => {
          const StageIcon = STAGE_ICONS[item.id] || IconChartBar;
          const available = index <= stageIndex && Boolean(path[index]);
          return (
            <button
              className={`${index === stageIndex ? "is-active" : ""} ${index < stageIndex ? "is-complete" : ""}`}
              key={item.id}
              disabled={!available}
              onClick={() => openStage(index)}
              aria-current={index === stageIndex ? "step" : undefined}
            >
              <span>{index < stageIndex ? <IconCheck size={16}/> : <StageIcon size={17}/>}</span>
              <div><strong>{item.label}</strong><small>{item.prompt}</small></div>
              {index < stages.length - 1 && <IconChevronRight className="ltv-stage-rail__arrow" size={16}/>} 
            </button>
          );
        })}
      </section>

      <section className="panel ltv-workspace">
        <div className="ltv-breadcrumbs">
          {selectedPath.map(({ stage: pathStage, node }, index) => (
            <button key={pathStage.id} onClick={() => openStage(index)}>{node.name}{index < selectedPath.length - 1 && <IconChevronRight size={14}/>}</button>
          ))}
        </div>

        <div className="ltv-workspace__head">
          <div><span>第 {stageIndex + 1} 步 / 共 {stages.length} 步</span><h2>{stage.label}：{stageInstruction(stage.id)}</h2><p>{stage.prompt} · 数据快照 {model.asOf}</p></div>
          <div className="ltv-progress"><i><b style={{ width: `${((stageIndex + 1) / stages.length) * 100}%` }}/></i><strong>{Math.round(((stageIndex + 1) / stages.length) * 100)}%</strong></div>
        </div>

        <div className="ltv-stage-layout">
          <div className="ltv-options">
            <div className="ltv-section-title"><div><h3>选择{stage.label}</h3><p>点击对象查看本层结论，再继续下钻</p></div><span>{candidates.length} 个可选对象</span></div>
            <div className="ltv-option-list">
              {candidates.map((node) => {
                const nodeKpis = Array.isArray(node.metrics?.kpis) ? node.metrics.kpis : [];
                const active = selectedNode?.id === node.id;
                return (
                  <button className={`ltv-option ${active ? "is-active" : ""}`} key={node.id} onClick={() => selectNode(node)} aria-label={`选择${stage.label}：${node.name}`}>
                    <div className="ltv-option__head"><div><strong>{node.name}</strong><span className={`is-${STATUS_TONES[node.statusCode] || "blue"}`}>{node.status}</span></div><IconChevronRight size={18}/></div>
                    <p>{node.summary}</p>
                    <div className="ltv-option__metrics">{nodeKpis.slice(0, 3).map((kpi) => <span key={kpi.label}><small>{kpi.label}</small><strong>{kpi.value}</strong></span>)}</div>
                  </button>
                );
              })}
              {!candidates.length && <div className="business-empty"><IconDatabaseExport size={30}/><strong>本层暂无数据</strong><p>请在 MySQL 中补充子节点。</p></div>}
            </div>
          </div>

          <aside className="ltv-decision">
            <div className="ltv-decision__label"><IconSparkles size={17}/>当前选择</div>
            <h3>{selectedNode?.name}</h3>
            <p className="ltv-decision__summary">{selectedNode?.summary}</p>
            <div className="ltv-kpi-grid">{kpis.map((kpi) => <article key={kpi.label} className={`is-${kpi.tone || "blue"}`}><small>{kpi.label}</small><strong>{kpi.value}</strong><span>{kpi.note}</span></article>)}</div>
            <div className="ltv-explain"><div><span>最终呈现</span><p>{selectedNode?.questionText}</p></div><div><span>怎么使用</span><p>{selectedNode?.usageGuide}</p></div></div>
            {details.length > 0 && <div className="ltv-details">{details.map((detail) => <div key={detail.label}><span>{detail.label}</span><strong>{detail.value}</strong></div>)}</div>}
            <button className="primary-button ltv-next" onClick={goNext}>{nextStage ? `继续查看${nextStage.label}` : "生成复盘结论"}<IconChevronRight size={16}/></button>
          </aside>
        </div>

        {stage.id === "review" && selectedNode && (
          <div className="ltv-review">
            <section><div className="ltv-section-title"><div><h3>LTV 目标与实际</h3><p>策略前、执行中与复盘结果对比</p></div></div><div className="ltv-review__chart"><ResponsiveContainer width="100%" height="100%"><AreaChart data={trend}><defs><linearGradient id="ltvActualFill" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stopColor="#2869f6" stopOpacity={.24}/><stop offset="100%" stopColor="#2869f6" stopOpacity={0}/></linearGradient></defs><CartesianGrid stroke="#edf1f7" vertical={false}/><XAxis dataKey="period" axisLine={false} tickLine={false}/><YAxis axisLine={false} tickLine={false}/><Tooltip content={<ModelTooltip/>}/><Area name="实际 LTV" type="monotone" dataKey="ltv" stroke="#2869f6" fill="url(#ltvActualFill)" strokeWidth={3}/><Line name="目标 LTV" type="monotone" dataKey="target" stroke="#13bda5" strokeDasharray="6 5" strokeWidth={2}/></AreaChart></ResponsiveContainer></div></section>
            <aside><span><IconClipboardData size={20}/></span><div><small>复盘结论</small><h3>{metrics.verdict}</h3><p>这个结论会回写到策略库，成为下一轮模型推荐的依据。</p><button onClick={() => onToast("复盘结论已沉淀到 LTV 策略库")}>沉淀为可复用策略</button></div></aside>
          </div>
        )}
      </section>
    </section>
  );
}
