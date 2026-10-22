// Fungsi kriptografi untuk autentikasi buatan sendiri (Web Crypto).
const encoder = new TextEncoder();

export const PBKDF2_ITERATIONS = 310_000;

function toB64(bytes: Uint8Array): string {
  let s = "";
  for (const b of bytes) s += String.fromCharCode(b);
  return btoa(s);
}

function fromB64(text: string): Uint8Array {
  const bin = atob(text);
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

export function toB64Url(bytes: Uint8Array): string {
  return toB64(bytes).replaceAll("+", "-").replaceAll("/", "_").replaceAll("=", "");
}

function fromB64Url(text: string): Uint8Array {
  const pad = "=".repeat((4 - (text.length % 4)) % 4);
  return fromB64(text.replaceAll("-", "+").replaceAll("_", "/") + pad);
}

export function randomToken(bytes = 32): string {
  return toB64Url(crypto.getRandomValues(new Uint8Array(bytes)));
}

export async function sha256Hex(text: string): Promise<string> {
  const digest = await crypto.subtle.digest("SHA-256", encoder.encode(text));
  return Array.from(new Uint8Array(digest))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

export function timingSafeEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let diff = 0;
  for (let i = 0; i < a.length; i++) diff |= a[i] ^ b[i];
  return diff === 0;
}

async function derive(
  password: string,
  salt: Uint8Array,
  iterations: number,
): Promise<Uint8Array> {
  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(password),
    "PBKDF2",
    false,
    ["deriveBits"],
  );
  const bits = await crypto.subtle.deriveBits(
    { name: "PBKDF2", hash: "SHA-256", salt: salt as BufferSource, iterations },
    key,
    256,
  );
  return new Uint8Array(bits);
}

// Format: pbkdf2$sha256$<iterasi>$<salt base64>$<hash base64>
export async function hashPassword(
  password: string,
  iterations = PBKDF2_ITERATIONS,
): Promise<string> {
  const salt = crypto.getRandomValues(new Uint8Array(16));
  const hash = await derive(password, salt, iterations);
  return `pbkdf2$sha256$${iterations}$${toB64(salt)}$${toB64(hash)}`;
}

export async function verifyPassword(
  password: string,
  stored: string,
): Promise<boolean> {
  const [scheme, algo, iter, salt, hash] = stored.split("$");
  if (scheme !== "pbkdf2" || algo !== "sha256") return false;
  const iterations = Number(iter);
  if (!Number.isInteger(iterations) || iterations < 1) return false;
  const actual = await derive(password, fromB64(salt), iterations);
  return timingSafeEqual(actual, fromB64(hash));
}

async function hmacKey(secret: string): Promise<CryptoKey> {
  return await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign", "verify"],
  );
}

export async function signJwt(
  payload: Record<string, unknown>,
  secret: string,
): Promise<string> {
  const header = toB64Url(encoder.encode(JSON.stringify({ alg: "HS256", typ: "JWT" })));
  const body = toB64Url(encoder.encode(JSON.stringify(payload)));
  const data = `${header}.${body}`;
  const sig = new Uint8Array(
    await crypto.subtle.sign("HMAC", await hmacKey(secret), encoder.encode(data)),
  );
  return `${data}.${toB64Url(sig)}`;
}

/** Mengembalikan isi token bila tanda tangan valid dan belum kedaluwarsa. */
export async function verifyJwt(
  token: string,
  secret: string,
): Promise<Record<string, unknown> | null> {
  const parts = token.split(".");
  if (parts.length !== 3) return null;
  const [header, body, sig] = parts;
  try {
    const head = JSON.parse(new TextDecoder().decode(fromB64Url(header)));
    if (head.alg !== "HS256") return null;
    const ok = await crypto.subtle.verify(
      "HMAC",
      await hmacKey(secret),
      fromB64Url(sig) as BufferSource,
      encoder.encode(`${header}.${body}`),
    );
    if (!ok) return null;
    const payload = JSON.parse(new TextDecoder().decode(fromB64Url(body)));
    if (typeof payload.exp !== "number" || payload.exp * 1000 <= Date.now()) {
      return null;
    }
    return payload;
  } catch {
    return null;
  }
}
