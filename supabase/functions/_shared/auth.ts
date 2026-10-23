import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { unauthorized } from "./http.ts";
import { verifyJwt } from "./crypto.ts";

export type AuthenticatedUser = {
  userId: string;
  sessionId: string;
  deviceId: string;
};

export function jwtSecret(): string {
  const secret = Deno.env.get("BARAKAH_JWT_SECRET");
  if (!secret) throw new Error("BARAKAH_JWT_SECRET belum dikonfigurasi.");
  return secret;
}

export async function requireUser(
  req: Request,
  db: SupabaseClient,
): Promise<AuthenticatedUser | Response> {
  const match = /^Bearer\s+([^\s]+)$/i.exec(
    req.headers.get("authorization") ?? "",
  );
  if (!match) return unauthorized();

  const claims = await verifyJwt(match[1], jwtSecret());
  if (!claims) return unauthorized();

  const userId = claims.sub;
  const sessionId = claims.sid;
  const deviceId = claims.device_id;
  if (
    typeof userId !== "string" ||
    typeof sessionId !== "string" ||
    typeof deviceId !== "string" ||
    claims.iss !== "barakah" ||
    claims.aud !== "barakah-app"
  ) {
    return unauthorized();
  }

  const { data, error } = await db
    .from("sessions")
    .select("id")
    .eq("id", sessionId)
    .eq("user_id", userId)
    .eq("device_id", deviceId)
    .is("revoked_at", null)
    .gt("expires_at", new Date().toISOString())
    .maybeSingle();

  if (error) throw new Error("Session validation failed.");
  if (!data) return unauthorized();

  return { userId, sessionId, deviceId };
}
