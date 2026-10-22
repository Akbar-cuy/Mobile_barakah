// Endpoint saran dan kesan (PRD Tabel 13, bagian Feedback). Milik pengguna sendiri.
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json, notFound, readJson } from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import { requireUser } from "../_shared/auth.ts";

const COLUMNS = "id, rating, impression, suggestion, created_at, updated_at";
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

type Fields = { rating: number; impression: string; suggestion: string };

function validate(b: Record<string, unknown>): Fields | Response {
  const rating = Number(b.rating);
  const impression = typeof b.impression === "string" ? b.impression.trim() : "";
  const suggestion = typeof b.suggestion === "string" ? b.suggestion.trim() : "";
  if (!Number.isInteger(rating) || rating < 1 || rating > 5) {
    return badRequest("Penilaian harus 1 sampai 5 bintang.", "invalid_rating");
  }
  if (impression.length < 10 || impression.length > 500) {
    return badRequest("Kesan harus 10 sampai 500 karakter.", "invalid_impression");
  }
  if (suggestion.length < 10 || suggestion.length > 500) {
    return badRequest("Saran harus 10 sampai 500 karakter.", "invalid_suggestion");
  }
  return { rating, impression, suggestion };
}

async function list(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const { data, error } = await db
    .from("feedback")
    .select(COLUMNS)
    .eq("user_id", auth.userId)
    .order("created_at", { ascending: false });
  if (error) throw error;
  return json({ items: data ?? [] });
}

// Idempoten: id berasal dari klien, jadi kiriman ulang dari outbox tidak menggandakan data.
async function create(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;

  const b = (await readJson<Record<string, unknown>>(req)) ?? {};
  const id = typeof b.id === "string" ? b.id : "";
  if (!UUID.test(id)) return badRequest("Id tidak valid.", "invalid_id");
  const fields = validate(b);
  if (fields instanceof Response) return fields;

  const existing = await db.from("feedback").select("id, user_id").eq("id", id).maybeSingle();
  if (existing.data) {
    if (existing.data.user_id !== auth.userId) {
      return errorResponse(409, "id_conflict", "Id sudah dipakai.");
    }
    const { data, error } = await db
      .from("feedback")
      .update({ ...fields, updated_at: new Date().toISOString() })
      .eq("id", id)
      .eq("user_id", auth.userId)
      .select(COLUMNS)
      .single();
    if (error) throw error;
    return json({ item: data });
  }

  const { data, error } = await db
    .from("feedback")
    .insert({ id, user_id: auth.userId, ...fields })
    .select(COLUMNS)
    .single();
  if (error) throw error;
  return json({ item: data }, 201);
}

async function update(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;

  const fields = validate((await readJson<Record<string, unknown>>(req)) ?? {});
  if (fields instanceof Response) return fields;

  const { data, error } = await db
    .from("feedback")
    .update({ ...fields, updated_at: new Date().toISOString() })
    .eq("id", ctx.params.id)
    .eq("user_id", auth.userId)
    .select(COLUMNS)
    .maybeSingle();
  if (error) throw error;
  if (!data) return notFound();
  return json({ item: data });
}

async function remove(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const { data, error } = await db
    .from("feedback")
    .delete()
    .eq("id", ctx.params.id)
    .eq("user_id", auth.userId)
    .select("id");
  if (error) throw error;
  if (!data || data.length === 0) return notFound();
  return json({});
}

Deno.serve(serveRoutes({
  "GET /feedback": list,
  "POST /feedback": create,
  "PUT /feedback/:id": update,
  "DELETE /feedback/:id": remove,
}));
