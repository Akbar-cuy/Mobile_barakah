import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, json, readJson } from "../_shared/http.ts";
import { randomToken, sha256Hex } from "../_shared/crypto.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

async function register(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const body = await readJson<Record<string, unknown>>(req);
  const name = typeof body?.name === "string" ? body.name.trim() : "";
  if (!name || name.length > 60) {
    return badRequest("Nama perangkat wajib diisi dan maksimal 60 karakter.", "invalid_device_name");
  }

  const token = randomToken(32);
  const { data, error } = await db.from("iot_devices")
    .insert({
      user_id: auth.userId,
      name,
      key_hash: await sha256Hex(token),
    })
    .select("id, name")
    .single();
  if (error) throw new Error("IoT device registration failed.");
  return json({
    device: data,
    device_token: token,
  }, 201);
}

async function revoke(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  if (!UUID.test(ctx.params.id)) {
    return badRequest("Id perangkat tidak valid.", "invalid_device_id");
  }

  const { error } = await db.from("iot_devices")
    .update({ revoked_at: new Date().toISOString() })
    .eq("id", ctx.params.id)
    .eq("user_id", auth.userId)
    .is("revoked_at", null);
  if (error) throw new Error("IoT device revocation failed.");
  return json({ ok: true });
}

Deno.serve(serveRoutes({
  "POST /iot/devices": register,
  "DELETE /iot/devices/:id": revoke,
}, "iot"));
