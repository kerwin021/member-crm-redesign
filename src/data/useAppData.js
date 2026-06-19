import { useEffect, useMemo, useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE_URL || "";

function mergeObject(fallback, incoming) {
  if (!incoming || typeof incoming !== "object") return fallback;
  return { ...fallback, ...incoming };
}

export function mergeAppData(fallback, incoming) {
  if (!incoming || typeof incoming !== "object") return fallback;
  return {
    ...fallback,
    ...incoming,
    dashboard: mergeObject(fallback.dashboard, incoming.dashboard),
    businessStats: mergeObject(fallback.businessStats, incoming.businessStats),
  };
}

export function useAppData(fallbackData) {
  const [state, setState] = useState({ data: fallbackData, status: "loading", error: null });

  useEffect(() => {
    const controller = new AbortController();
    const timer = window.setTimeout(() => controller.abort(), 8000);

    fetch(`${API_BASE}/api/app-data`, {
      headers: { Accept: "application/json" },
      signal: controller.signal,
    })
      .then((response) => {
        if (!response.ok) throw new Error(`API ${response.status}`);
        return response.json();
      })
      .then((payload) => {
        setState({ data: mergeAppData(fallbackData, payload), status: "live", error: null });
      })
      .catch((error) => {
        if (error.name !== "AbortError") {
          setState({ data: fallbackData, status: "fallback", error });
        } else {
          setState({ data: fallbackData, status: "fallback", error });
        }
      })
      .finally(() => window.clearTimeout(timer));

    return () => {
      window.clearTimeout(timer);
      controller.abort();
    };
  }, [fallbackData]);

  return useMemo(() => state, [state]);
}
