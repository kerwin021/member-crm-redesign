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
await writeFile(
  resolve(dist, "server/index.js"),
  `const staticAssets = ${JSON.stringify(staticAssets)};\n\nconst contentTypes = {\n  html: "text/html; charset=utf-8",\n  js: "text/javascript; charset=utf-8",\n  css: "text/css; charset=utf-8",\n  svg: "image/svg+xml",\n  png: "image/png",\n  jpg: "image/jpeg",\n  jpeg: "image/jpeg",\n  webp: "image/webp",\n  woff2: "font/woff2",\n};\n\nfunction decode(value) {\n  const binary = atob(value);\n  const bytes = new Uint8Array(binary.length);\n  for (let index = 0; index < binary.length; index += 1) bytes[index] = binary.charCodeAt(index);\n  return bytes;\n}\n\nfunction responseFor(path) {\n  const value = staticAssets[path] || staticAssets["/index.html"];\n  const extension = path === "/" || path === "/index.html" ? "html" : path.split(".").pop()?.toLowerCase();\n  return new Response(decode(value), { headers: { "content-type": contentTypes[extension] || "application/octet-stream", "cache-control": path === "/" || path === "/index.html" ? "no-cache" : "public, max-age=31536000, immutable" } });\n}\n\nconst worker = {\n  async fetch(request, env) {\n    if (env?.ASSETS?.fetch) {\n      try {\n        const assetResponse = await env.ASSETS.fetch(request);\n        if (assetResponse.status !== 404) return assetResponse;\n      } catch {}\n    }\n    const url = new URL(request.url);\n    if (url.pathname.startsWith("/api/")) return new Response("Not found", { status: 404 });\n    return responseFor(url.pathname);\n  },\n};\n\nexport default worker;\n`,
);

await mkdir(resolve(dist, ".openai"), { recursive: true });
await writeFile(
  resolve(dist, ".openai/hosting.json"),
  await readFile(resolve(root, ".openai/hosting.json")),
);
