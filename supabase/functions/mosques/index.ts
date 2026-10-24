import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";
import {
  makeOverpassQuery,
  normalizeOverpassElements,
  parseNearbyRequest,
} from "./mosques_contract.ts";

const OVERPASS_URL = "https://overpass-api.de/api/interpreter";
const REQUEST_TIMEOUT_MS = 25_000;
const MAX_RESPONSE_BYTES = 5 * 1024 * 1024;

async function nearby(req: Request, ctx: { url: URL }): Promise<Response> {
  const db = getAdminClient();
  const user = await requireUser(req, db);
  if (user instanceof Response) return user;

  const input = parseNearbyRequest(ctx.url);
  if (!input) {
    return badRequest("Koordinat, radius, atau pencarian tidak valid.");
  }

  try {
    const upstream = await fetch(OVERPASS_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
        "Accept": "application/json",
      },
      body: new URLSearchParams({ data: makeOverpassQuery(input) }),
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
    if (!upstream.ok) {
      return errorResponse(
        502,
        "mosque_source_unavailable",
        "Data masjid sementara tidak tersedia.",
      );
    }
    const contentLength = Number(upstream.headers.get("content-length"));
    if (Number.isFinite(contentLength) && contentLength > MAX_RESPONSE_BYTES) {
      return errorResponse(
        502,
        "mosque_source_unavailable",
        "Data masjid sementara tidak tersedia.",
      );
    }
    const body = await readLimitedBody(upstream);
    let payload: unknown;
    try {
      payload = JSON.parse(body);
    } catch {
      return errorResponse(
        502,
        "mosque_source_unavailable",
        "Data masjid sementara tidak tersedia.",
      );
    }
    if (!payload || typeof payload !== "object" || !("elements" in payload)) {
      return errorResponse(
        502,
        "mosque_source_unavailable",
        "Data masjid sementara tidak tersedia.",
      );
    }
    const items = normalizeOverpassElements(
      (payload as { elements: unknown }).elements,
      input,
    );
    return json({ items });
  } catch (error) {
    console.error("Overpass request failed.", {
      errorType: error instanceof Error ? error.name : "unknown",
    });
    return errorResponse(
      502,
      "mosque_source_unavailable",
      "Data masjid sementara tidak tersedia.",
    );
  }
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
