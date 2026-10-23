// Endpoint profil (PRD Tabel 13, bagian Profile).
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json, notFound, readJson } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";
import { requireUser } from "../_shared/auth.ts";

const COLUMNS = "id, name, username, email, avatar_url";

async function get(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const { data, error } = await db.from("users").select(COLUMNS).eq("id", auth.userId).maybeSingle();
  if (error) throw error;
  if (!data) return notFound();
  return json({ user: data });
}

async function update(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;

  const b = (await readJson<Record<string, unknown>>(req)) ?? {};
  const name = typeof b.name === "string" ? b.name.trim() : "";
  const username = typeof b.username === "string" ? b.username.trim().toLowerCase() : "";
  const avatar = typeof b.avatar_url === "string" && b.avatar_url.trim() !== ""
    ? b.avatar_url.trim()
    : null;

  if (!name) return badRequest("Nama lengkap wajib diisi.", "invalid_name");
  if (username.length < 3 || username.length > 30) {
    return badRequest("Nama pengguna harus 3 sampai 30 karakter.", "invalid_username");
  }
  if (avatar !== null && !/^https?:\/\/\S+$/i.test(avatar)) {
    return badRequest("Tautan foto harus diawali http atau https.", "invalid_avatar");
  }

  const taken = await db.from("users").select("id").eq("username", username).neq("id", auth.userId)
    .maybeSingle();
  if (taken.error) throw new Error("Username lookup failed.");
  if (taken.data) return errorResponse(409, "username_taken", "Nama pengguna sudah dipakai.");

  const { data, error } = await db
    .from("users")
    .update({ name, username, avatar_url: avatar })
    .eq("id", auth.userId)
    .select(COLUMNS)
    .single();
  if (error) {
    if (error.code === "23505") {
      return errorResponse(409, "username_taken", "Nama pengguna sudah dipakai.");
    }
    throw error;
  }
  return json({ user: data });
}

Deno.serve(serveRoutes({
  "GET /profile": get,
  "PUT /profile": update,
}, "profile"));
