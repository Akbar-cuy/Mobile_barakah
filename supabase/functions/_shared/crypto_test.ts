import {
  hashPassword,
  signJwt,
  verifyJwt,
  verifyPassword,
} from "./crypto.ts";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

Deno.test("password hashes verify only the original password", async () => {
  const encoded = await hashPassword("ValidPass123");
  assert(await verifyPassword("ValidPass123", encoded), "password did not verify");
  assert(!await verifyPassword("WrongPass123", encoded), "wrong password verified");
  assert(!await verifyPassword("ValidPass123", "not-a-password-hash"), "malformed hash verified");
});

Deno.test("JWT verification checks signature, expiry, issuer, and audience", async () => {
  const secret = "test-only-barakah-signing-key";
  const now = Math.floor(Date.now() / 1000);
  const claims = {
    sub: "user-id",
    sid: "session-id",
    device_id: "device-id",
    iss: "barakah",
    aud: "barakah-app",
    iat: now,
    exp: now + 60,
  };
  const valid = await signJwt(claims, secret);
  assert(await verifyJwt(valid, secret), "valid JWT was rejected");
  const [header, payload, signature] = valid.split(".");
  const changedSignature = `${signature.startsWith("A") ? "B" : "A"}${signature.slice(1)}`;
  assert(
    !await verifyJwt(`${header}.${payload}.${changedSignature}`, secret),
    "tampered JWT was accepted",
  );

  const expired = await signJwt({ ...claims, exp: now - 1 }, secret);
  assert(!await verifyJwt(expired, secret), "expired JWT was accepted");
  const wrongIssuer = await signJwt({ ...claims, iss: "other" }, secret);
  assert(!await verifyJwt(wrongIssuer, secret), "JWT with wrong issuer was accepted");
  const wrongAudience = await signJwt({ ...claims, aud: "other" }, secret);
  assert(!await verifyJwt(wrongAudience, secret), "JWT with wrong audience was accepted");
});
