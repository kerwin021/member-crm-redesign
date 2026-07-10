import { build } from "vite";
import { mkdir, readFile, rm, writeFile } from "node:fs/promises";
import { resolve } from "node:path";

const root = process.cwd();
const dist = resolve(root, "dist");

await rm(dist, { recursive: true, force: true });
await build({ configFile: resolve(root, "vite.config.mjs") });

await mkdir(resolve(dist, "server"), { recursive: true });
await writeFile(
  resolve(dist, "server/index.js"),
  `const worker = {\n  async fetch(request, env) {\n    return env.ASSETS.fetch(request);\n  },\n};\n\nexport default worker;\n`,
);

await mkdir(resolve(dist, ".openai"), { recursive: true });
await writeFile(
  resolve(dist, ".openai/hosting.json"),
  await readFile(resolve(root, ".openai/hosting.json")),
);
