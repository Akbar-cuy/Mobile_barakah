import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";
import {
  type NearbyRequest,
  makeOverpassQuery,
  normalizeOverpassElements,
  parseNearbyRequest,
} from "./mosques_contract.ts";

// Server Overpass publik sering menolak atau melambat (429, 504). Dicoba
// berurutan; server pertama yang menjawab dengan data dipakai.
const OVERPASS_ENDPOINTS = [
  "https://overpass-api.de/api/interpreter",
  "https://overpass.private.coffee/api/interpreter",
  "https://overpass.kumi.systems/api/interpreter",
];
// Overpass menolak permintaan tanpa identitas yang jelas.
const USER_AGENT = "BarakahApp/1.0 (aplikasi ibadah mahasiswa; Supabase Edge Function)";
const REQUEST_TIMEOUT_MS = 12_000;
const MAX_RESPONSE_BYTES = 5 * 1024 * 1024;
const CACHE_TTL_MS = 5 * 60 * 1000;
const CACHE_MAX_ENTRIES = 100;

const UNAVAILABLE = () =>
  errorResponse(
    502,
    "mosque_source_unavailable",
    "Data masjid sementara tidak tersedia.",
  );

const cache = new Map<string, { at: number; items: unknown }>();

function cacheKey(input: NearbyRequest): string {
  // Dibulatkan agar pengguna yang berdekatan memakai hasil yang sama.
  return [
    input.lat.toFixed(3),
    input.lon.toFixed(3),
    input.radiusKm,
    input.query.toLowerCase(),
  ].join("|");
}

/** Mengambil elemen Overpass dari satu server, atau null bila gagal. */
async function queryEndpoint(url: string, query: string): Promise<unknown[] | null> {
  const host = new URL(url).host;
  try {
    const upstream = await fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        "Accept": "application/json",
        "User-Agent": USER_AGENT,
      },
      body: new URLSearchParams({ data: query }),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
    if (!upstream.ok) {
      console.error("Overpass endpoint rejected the request.", {
        host,
        status: upstream.status,
      });
      return null;
    }
    const length = Number(upstream.headers.get("content-length"));
    if (Number.isFinite(length) && length > MAX_RESPONSE_BYTES) {
      console.error("Overpass response too large.", { host, length });
      return null;
    }
    const payload: unknown = JSON.parse(await readLimitedBody(upstream));
    if (!payload || typeof payload !== "object") return null;
    const { elements, remark } = payload as { elements?: unknown; remark?: unknown };
    if (!Array.isArray(elements)) {
      // Overpass membalas 200 dengan "remark" bila kueri kehabisan waktu.
      console.error("Overpass returned no elements.", {
        host,
        remark: typeof remark === "string" ? remark.slice(0, 120) : undefined,
      });
      return null;
    }
    return elements;
  } catch (error) {
    console.error("Overpass request failed.", {
      host,
      errorType: error instanceof Error ? error.name : "unknown",
    });
    return null;
  }
}

async function nearby(req: Request, ctx: { url: URL }): Promise<Response> {
  const db = getAdminClient();
  const user = await requireUser(req, db);
  if (user instanceof Response) return user;

  const input = parseNearbyRequest(ctx.url);
  if (!input) {
    return badRequest("Koordinat, radius, atau pencarian tidak valid.");
  }

  const key = cacheKey(input);
  const hit = cache.get(key);
  if (hit && Date.now() - hit.at < CACHE_TTL_MS) {
    return json({ items: hit.items, cached: true });
  }

  const query = makeOverpassQuery(input);
  for (const endpoint of OVERPASS_ENDPOINTS) {
    const elements = await queryEndpoint(endpoint, query);
    if (elements === null) continue;
    const items = normalizeOverpassElements(elements, input);
    if (cache.size >= CACHE_MAX_ENTRIES) {
      const oldest = cache.keys().next().value;
      if (oldest !== undefined) cache.delete(oldest);
    }
    cache.set(key, { at: Date.now(), items });
    return json({ items });
  }
  return UNAVAILABLE();
}

async function readLimitedBody(response: Response): Promise<string> {
  if (!response.body) return "";
  const reader = response.body.getReader();
  const chunks: Uint8Array[] = [];
  let bytes = 0;
  try {
    while (true) {
      const { done, value } = await reader.read();
      if (done) break;
      bytes += value.byteLength;
      if (bytes > MAX_RESPONSE_BYTES) {
        await reader.cancel();
        throw new Error("Overpass response exceeded size limit.");
      }
      chunks.push(value);
    }
  } finally {
    reader.releaseLock();
  }
  const body = new Uint8Array(bytes);
  let offset = 0;
  for (const chunk of chunks) {
    body.set(chunk, offset);
    offset += chunk.byteLength;
  }
  return new TextDecoder().decode(body);
}

Deno.serve(serveRoutes({ "GET /mosques/nearby": nearby }, "mosques"));
