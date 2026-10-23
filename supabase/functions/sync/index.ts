import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json, readJson } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";

const MAX_BATCH = 200;
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const SETTINGS_KEYS = new Set([
  "theme_mode",
  "notification_prefs",
  "tasbih_mode",
  "tasbih_sensitivity",
  "tasbih_vibrate",
  "tasbih_target",
]);

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isValidDateOnly(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const parsed = new Date(`${value}T00:00:00.000Z`);
  return !Number.isNaN(parsed.getTime()) && parsed.toISOString().slice(0, 10) === value;
}

function validChange(change: unknown): boolean {
  if (!isRecord(change) || !isRecord(change.payload)) return false;
  const { entity, op, payload } = change;
  if (entity === "tasbih_log") {
    if (!["create", "update", "delete"].includes(String(op))) return false;
    if (typeof payload.id !== "string" || !UUID.test(payload.id)) return false;
    if (op === "delete") return true;
    return typeof payload.log_date === "string" &&
      isValidDateOnly(payload.log_date) &&
      typeof payload.target === "number" &&
      Number.isSafeInteger(payload.target) && payload.target > 0 &&
      payload.target <= 2_147_483_647 &&
      typeof payload.count === "number" &&
      Number.isSafeInteger(payload.count) && payload.count >= 0 &&
      payload.count <= 2_147_483_647 &&
      ["app", "iot"].includes(String(payload.source));
  }
  if (entity === "setting") {
    if (!SETTINGS_KEYS.has(String(payload.key))) return false;
    if (op === "delete") return true;
    return op === "update" && typeof payload.value === "string" &&
      payload.value.length <= 10_000 &&
      typeof payload.updated_at === "string" &&
      /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?Z$/.test(payload.updated_at) &&
      !Number.isNaN(Date.parse(payload.updated_at));
  }
  return false;
}

async function push(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const body = await readJson<Record<string, unknown>>(req);
  if (
    !body || !Array.isArray(body.changes) ||
    body.changes.length > MAX_BATCH ||
    !body.changes.every(validChange)
  ) {
    return badRequest("Batch sinkronisasi tidak valid.", "invalid_sync_batch");
  }

  const { data, error } = await db.rpc("sync_push", {
    p_user_id: auth.userId,
    p_changes: body.changes,
  });
  if (error) {
    const message = error.message ?? "";
    if (message.includes("sync_id_conflict")) {
      return errorResponse(409, "sync_id_conflict", "Id data sudah digunakan akun lain.");
    }
    if (message.includes("unsupported_sync_entity")) {
      return badRequest("Jenis data belum didukung untuk sinkronisasi.");
    }
    if (message.startsWith("invalid_")) {
      return badRequest("Perubahan sinkronisasi tidak valid.");
    }
    throw new Error("Sync push transaction failed.");
  }
  return json(data);
}

async function pull(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const url = new URL(req.url);
  const since = url.searchParams.get("since");
  const sinceTime = since === null ? null : new Date(since);
  if (since !== null && Number.isNaN(sinceTime?.getTime())) {
    return badRequest("Parameter since harus berupa waktu ISO 8601.", "invalid_since");
  }

  const serverTime = new Date().toISOString();
  const sinceIso = sinceTime?.toISOString();
  const pageSize = 1000;
  const tasbihItems: Record<string, unknown>[] = [];
  const settingItems: Record<string, unknown>[] = [];

  for (let from = 0; ; from += pageSize) {
    let query = db.from("tasbih_logs")
      .select("id, log_date, target, count, source, updated_at")
      .eq("user_id", auth.userId);
    if (sinceIso) query = query.gte("updated_at", sinceIso);
    const { data, error } = await query
      .order("updated_at", { ascending: true })
      .range(from, from + pageSize - 1);
    if (error) throw new Error("Sync tasbih pull query failed.");
    tasbihItems.push(...(data ?? []));
    if (!data || data.length < pageSize) break;
  }

  for (let from = 0; ; from += pageSize) {
    let query = db.from("user_settings")
      .select("setting_key, setting_value, updated_at")
      .eq("user_id", auth.userId);
    if (sinceIso) query = query.gte("updated_at", sinceIso);
    const { data, error } = await query
      .order("updated_at", { ascending: true })
      .range(from, from + pageSize - 1);
    if (error) throw new Error("Sync settings pull query failed.");
    settingItems.push(...(data ?? []));
    if (!data || data.length < pageSize) break;
  }

  return json({
    server_time: serverTime,
    changes: [
      { entity: "tasbih_log", items: tasbihItems },
      { entity: "setting", items: settingItems },
    ],
  });
}

Deno.serve(serveRoutes({
  "POST /sync/push": push,
  "GET /sync/pull": pull,
}, "sync"));
