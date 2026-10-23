import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, json, readJson } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";

const COLUMNS = "osm_id, name, lat, lon";

function validCoordinates(lat: unknown, lon: unknown): lat is number {
  return typeof lat === "number" && Number.isFinite(lat) && lat >= -90 &&
    lat <= 90 && typeof lon === "number" && Number.isFinite(lon) &&
    lon >= -180 && lon <= 180;
}

async function list(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const { data, error } = await db.from("favorite_mosques")
    .select(COLUMNS)
    .eq("user_id", auth.userId)
    .order("name", { ascending: true });
  if (error) throw new Error("Favorite mosque query failed.");
  return json({ items: data ?? [] });
}

async function create(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const body = await readJson<Record<string, unknown>>(req);
  const osmId = typeof body?.osm_id === "string" ? body.osm_id.trim() : "";
  const name = typeof body?.name === "string" ? body.name.trim() : "";
  const lat = body?.lat;
  const lon = body?.lon;
  if (
    !osmId || osmId.length > 80 || !name || name.length > 200 ||
    !validCoordinates(lat, lon)
  ) {
    return badRequest("Data masjid favorit tidak valid.", "invalid_favorite");
  }

  const { data: inserted, error } = await db.from("favorite_mosques")
    .upsert({
      id: crypto.randomUUID(),
      user_id: auth.userId,
      osm_id: osmId,
      name,
      lat,
      lon,
    }, { onConflict: "user_id,osm_id", ignoreDuplicates: true })
    .select(COLUMNS)
    .maybeSingle();
  if (error) throw new Error("Favorite mosque save failed.");
  if (inserted) return json({ item: inserted });

  const existing = await db.from("favorite_mosques")
    .select(COLUMNS)
    .eq("user_id", auth.userId)
    .eq("osm_id", osmId)
    .single();
  if (existing.error) throw new Error("Favorite mosque lookup failed.");
  return json({ item: existing.data });
}

async function remove(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const osmId = new URL(req.url).searchParams.get("osm_id")?.trim() ?? "";
  if (!osmId || osmId.length > 80) {
    return badRequest("osm_id wajib diisi.", "invalid_osm_id");
  }
  const { error } = await db.from("favorite_mosques")
    .delete()
    .eq("user_id", auth.userId)
    .eq("osm_id", osmId);
  if (error) throw new Error("Favorite mosque delete failed.");
  return json({ ok: true });
}

Deno.serve(serveRoutes({
  "GET /favorites/mosques": list,
  "POST /favorites/mosques": create,
  "DELETE /favorites/mosques": remove,
}, "favorites"));
