import { useCallback, useEffect, useState } from "react";
import { DEMO_DATA } from "./demoData.js";

const API_BASE = import.meta.env.VITE_API_BASE_URL || "";
const PREVIEW_MODE = import.meta.env.VITE_SITES_PREVIEW === "true";

export function useAppData() {
  const [state, setState] = useState({ data: PREVIEW_MODE ? DEMO_DATA : null, status: PREVIEW_MODE ? "preview" : "loading", error: null });

  const load = useCallback(() => {
    if (PREVIEW_MODE) {
      setState({ data: DEMO_DATA, status: "preview", error: null });
      return () => {};
    }
    const controller = new AbortController();
    const timer = window.setTimeout(() => controller.abort(), 30000);
    setState((current) => ({ data: current.data, status: "loading", error: null }));

    fetch(`${API_BASE}/api/app-data`, {
      headers: { Accept: "application/json" },
      signal: controller.signal,
    })
      .then(async (response) => {
        const payload = await response.json().catch(() => ({}));
        if (!response.ok) throw new Error(payload.message || `API ${response.status}`);
        if (payload?.meta?.source !== "mysql") throw new Error("API response is not sourced from MySQL");
        return payload;
      })
      .then((payload) => setState({ data: payload, status: "live", error: null }))
      .catch((error) => {
        const message = error.name === "AbortError" ? "数据库请求超时" : error.message;
        setState({ data: null, status: "error", error: new Error(message) });
      })
      .finally(() => window.clearTimeout(timer));

    return () => {
      window.clearTimeout(timer);
      controller.abort();
    };
  }, []);

  useEffect(() => load(), [load]);

  return { ...state, reload: load };
}
