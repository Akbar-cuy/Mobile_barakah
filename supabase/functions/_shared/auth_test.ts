import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { requireUser } from "./auth.ts";
import { signJwt } from "./crypto.ts";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

Deno.test("protected requests require a valid token and active matching session", async () => {
  const secret = "test-only-barakah-session-key";
  const previousSecret = Deno.env.get("BARAKAH_JWT_SECRET");
  Deno.env.set("BARAKAH_JWT_SECRET", secret);
  try {
    const now = Math.floor(Date.now() / 1000);
    const token = await signJwt({
      sub: "user-id",
      sid: "session-id",
      device_id: "device-id",
      iss: "barakah",
      aud: "barakah-app",
      iat: now,
      exp: now + 60,
    }, secret);

    const fakeClient = (active: boolean) => ({
      from: (table: string) => {
        if (table !== "sessions") throw new Error("Unexpected table.");
        type QueryMock = {
          select(): QueryMock;
          eq(): QueryMock;
          is(): QueryMock;
          gt(): QueryMock;
          maybeSingle(): Promise<{ data: { id: string } | null; error: null }>;
        };
        const query: QueryMock = {
          select() {
            return query;
          },
          eq() {
            return query;
          },
          is() {
            return query;
          },
          gt() {
            return query;
          },
          async maybeSingle() {
            return { data: active ? { id: "session-id" } : null, error: null };
          },
        };
        return query;
      },
    } as unknown as SupabaseClient);

    const request = new Request("https://example.test/profile", {
      headers: { Authorization: `Bearer ${token}` },
    });
    const accepted = await requireUser(request, fakeClient(true));
    assert(!(accepted instanceof Response), "active session was rejected");
    assert(accepted.userId === "user-id", "wrong user identity returned");

    const revoked = await requireUser(request, fakeClient(false));
    assert(revoked instanceof Response && revoked.status === 401, "inactive session was accepted");

    const missing = await requireUser(
      new Request("https://example.test/profile"),
      fakeClient(true),
    );
    assert(missing instanceof Response && missing.status === 401, "missing token was accepted");

    const expiredToken = await signJwt({
      sub: "user-id",
      sid: "session-id",
      device_id: "device-id",
      iss: "barakah",
      aud: "barakah-app",
      iat: now - 120,
      exp: now - 60,
    }, secret);
    const expired = await requireUser(
      new Request("https://example.test/profile", {
        headers: { Authorization: `Bearer ${expiredToken}` },
      }),
      fakeClient(true),
    );
    assert(expired instanceof Response && expired.status === 401, "expired token was accepted");
  } finally {
    if (previousSecret === undefined) Deno.env.delete("BARAKAH_JWT_SECRET");
    else Deno.env.set("BARAKAH_JWT_SECRET", previousSecret);
  }
});
