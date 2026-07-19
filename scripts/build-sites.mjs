import { build } from "vite";
import { mkdir, readdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = process.cwd();
const dist = resolve(root, "dist");

if (!process.env.VITE_API_BASE_URL) process.env.VITE_SITES_PREVIEW = "true";
await rm(dist, { recursive: true, force: true });
await build({ configFile: resolve(root, "vite.config.mjs") });

await mkdir(resolve(dist, "server"), { recursive: true });
const staticAssets = {
  "/": Buffer.from(await readFile(resolve(dist, "index.html"))).toString("base64"),
  "/index.html": Buffer.from(await readFile(resolve(dist, "index.html"))).toString("base64"),
};
for (const file of await readdir(resolve(dist, "assets"))) {
  staticAssets[`/assets/${file}`] = Buffer.from(await readFile(resolve(dist, "assets", file))).toString("base64");
}
const workerSource = `const staticAssets = ${JSON.stringify(staticAssets)};

const contentTypes = {
  html: "text/html; charset=utf-8",
  js: "text/javascript; charset=utf-8",
  css: "text/css; charset=utf-8",
  svg: "image/svg+xml",
  png: "image/png",
  jpg: "image/jpeg",
  jpeg: "image/jpeg",
  webp: "image/webp",
  woff2: "font/woff2",
};

const jsonHeaders = {
  "content-type": "application/json; charset=utf-8",
  "cache-control": "no-store",
  "access-control-allow-origin": "*",
  "access-control-allow-methods": "POST, OPTIONS",
  "access-control-allow-headers": "Content-Type",
};

function decode(value) {
  const binary = atob(value);
  const bytes = new Uint8Array(binary.length);
  for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);
  return bytes;
}

function responseFor(path) {
  const value = staticAssets[path] || staticAssets["/index.html"];
  const extension = path === "/" || path === "/index.html" ? "html" : path.split(".").pop()?.toLowerCase();
  return new Response(decode(value), { headers: { "content-type": contentTypes[extension] || "application/octet-stream", "cache-control": path === "/" || path === "/index.html" ? "no-cache" : "public, max-age=31536000, immutable" } });
}

function jsonResponse(body, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: jsonHeaders });
}

function normalizeKimiContent(content) {
  if (typeof content === "string") return content.trim();
  if (Array.isArray(content)) {
    return content.map((item) => {
      if (typeof item === "string") return item;
      if (item && typeof item === "object") return item.text || item.content || "";
      return "";
    }).filter(Boolean).join("\\n").trim();
  }
  return content ? String(content).trim() : "";
}

function buildKimiMessages(payload) {
  const context = payload.context || {};
  const contextSource = context.source || "unknown";
  const contextJson = JSON.stringify(context);
  const systemPrompt = "你是微智 Claw，定位是会员数据与 SCRM 经营分析助手。你必须优先基于用户当前系统提供的指标上下文回答；如果上下文不足，明确说明缺少哪些数据，不要编造具体数字。回答使用中文，结构清晰，包含：结论、数据依据、建议动作、下一步追问。建议动作要能被会员运营人员直接执行。当前上下文来源：" + contextSource + "。";
  const userPrompt = "分析范围：" + (payload.scope || "当前数据") + "\\n功能入口：" + (payload.tool || "智能问答") + "\\n当前指标上下文：" + contextJson + "\\n\\n用户问题：" + payload.question;
  return [
    { role: "system", content: systemPrompt },
    { role: "user", content: userPrompt },
  ];
}

async function handleKimiChat(request, env) {
  if (request.method === "OPTIONS") return new Response(null, { status: 204, headers: jsonHeaders });
  if (request.method !== "POST") return jsonResponse({ error: "method_not_allowed", message: "Only POST is supported" }, 405);

  let payload;
  try {
    payload = await request.json();
  } catch {
    return jsonResponse({ error: "invalid_json", message: "请求格式不是有效的 JSON" }, 400);
  }

  const question = String(payload.question || "").trim();
  if (!question) return jsonResponse({ error: "empty_question", message: "请输入要提问的内容" }, 400);
  if (question.length > 2000) return jsonResponse({ error: "question_too_long", message: "问题不能超过 2000 个字符" }, 400);

  const apiKey = env?.MOONSHOT_API_KEY || env?.KIMI_API_KEY;
  if (!apiKey) return jsonResponse({ error: "kimi_not_configured", message: "Kimi API 密钥未配置，请在 Sites 环境变量中设置 MOONSHOT_API_KEY" }, 503);

  const model = env?.KIMI_MODEL || "kimi-k2.6";
  const baseUrl = (env?.KIMI_BASE_URL || env?.MOONSHOT_BASE_URL || "https://api.moonshot.cn/v1").replace(/\\/$/, "");
  const requestBody = {
    model,
    messages: buildKimiMessages({ ...payload, question }),
    temperature: Number(env?.KIMI_TEMPERATURE || 0.3),
    max_tokens: Number(env?.KIMI_MAX_TOKENS || 1600),
  };
  const thinking = env?.KIMI_THINKING || "disabled";
  if (model.startsWith("kimi-k2") && (thinking === "enabled" || thinking === "disabled")) requestBody.thinking = { type: thinking };

  let upstream;
  try {
    upstream = await fetch(baseUrl + "/chat/completions", {
      method: "POST",
      headers: {
        Authorization: "Bearer " + apiKey,
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify(requestBody),
    });
  } catch (error) {
    return jsonResponse({ error: "kimi_network_error", message: "无法连接 Kimi API：" + error.message }, 502);
  }

  const upstreamPayload = await upstream.json().catch(() => ({}));
  if (!upstream.ok) {
    const message = upstreamPayload?.error?.message || "Kimi API 返回错误";
    return jsonResponse({ error: "kimi_api_error", message: "Kimi API 返回错误：" + message }, 502);
  }

  const choice = Array.isArray(upstreamPayload.choices) ? upstreamPayload.choices[0] : null;
  const answer = normalizeKimiContent(choice?.message?.content);
  if (!answer) return jsonResponse({ error: "kimi_empty_response", message: "Kimi API 未返回有效回答" }, 502);

  return jsonResponse({
    ok: true,
    answer,
    model: upstreamPayload.model || model,
    usage: upstreamPayload.usage || {},
    scope: payload.scope || "当前数据",
    tool: payload.tool || "智能问答",
    generatedAt: new Date().toISOString(),
    steps: [
      "读取当前页面指标上下文：" + (payload.scope || "当前数据"),
      "调用 Kimi 模型：" + (upstreamPayload.model || model),
      "生成结论、依据和可执行建议",
    ],
  });
}

const worker = {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/api/kimi/chat") return handleKimiChat(request, env);
    if (env?.ASSETS?.fetch) {
      try {
        const assetResponse = await env.ASSETS.fetch(request);
        if (assetResponse.status !== 404) return assetResponse;
      } catch {}
    }
    if (url.pathname.startsWith("/api/")) return new Response("Not found", { status: 404 });
    return responseFor(url.pathname);
  },
};

export default worker;
`;

await writeFile(resolve(dist, "server/index.js"), workerSource);

await mkdir(resolve(dist, ".openai"), { recursive: true });
await writeFile(
  resolve(dist, ".openai/hosting.json"),
  await readFile(resolve(root, ".openai/hosting.json")),
);
