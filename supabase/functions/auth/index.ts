import { requireUser, jwtSecret } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import {
  badRequest,
  errorResponse,
  json,
  notFound,
  readJson,
  serverError,
  unauthorized,
} from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import {
  hashPassword,
  randomToken,
  sha256Hex,
  signJwt,
  verifyPassword,
} from "../_shared/crypto.ts";

const ACCESS_TOKEN_SECONDS = 15 * 60;
const REFRESH_TOKEN_DAYS = 7;
const MAX_FAILED_ATTEMPTS = 5;
const LOCK_MINUTES = 15;
const EMAIL_PATTERN = /^\S+@\S+\.\S+$/;
const UUID_PATTERN =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function escapeLikePattern(value: string): string {
  return value.replace(/[\\%_]/g, "\\$&");
}

type User = {
  id: string;
  name: string;
  username: string;
  email: string;
  avatar_url: string | null;
};

function validatePassword(password: unknown): password is string {
  return typeof password === "string" &&
    /^(?=.*[A-Za-z])(?=.*\d).{8,}$/.test(password);
}

function publicUser(user: User) {
  return {
    id: user.id,
    name: user.name,
    username: user.username,
    email: user.email,
    avatar_url: user.avatar_url,
  };
}

async function issueSession(
  db: ReturnType<typeof getAdminClient>,
  user: User,
  deviceId: string,
) {
  const now = Math.floor(Date.now() / 1000);
  const sessionId = crypto.randomUUID();
  const refreshToken = randomToken(32);
  const refreshHash = await sha256Hex(refreshToken);
  const expiresAt = new Date(
    Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000,
  ).toISOString();

  const accessToken = await signJwt(
    {
      sub: user.id,
      sid: sessionId,
      device_id: deviceId,
      iss: "barakah",
      aud: "barakah-app",
      iat: now,
      exp: now + ACCESS_TOKEN_SECONDS,
    },
    jwtSecret(),
  );
  const { error } = await db.from("sessions").insert({
    id: sessionId,
    user_id: user.id,
    device_id: deviceId,
    refresh_hash: refreshHash,
    expires_at: expiresAt,
  });
  if (error) throw new Error("Session creation failed.");

  return {
    access_token: accessToken,
    refresh_token: refreshToken,
    expires_in: ACCESS_TOKEN_SECONDS,
    user: publicUser(user),
  };
}

async function findActiveSession(req: Request) {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  return { db, ...auth };
}

const routes = {
  "POST /auth/register": async (req: Request) => {
    const body = await readJson<Record<string, unknown>>(req);
    if (!body) return badRequest("Body request tidak valid.");

    const name = typeof body.name === "string" ? body.name.trim() : "";
    const email = typeof body.email === "string"
      ? body.email.trim().toLowerCase()
      : "";
    const username = typeof body.username === "string"
      ? body.username.trim().toLowerCase()
      : "";
    const password = body.password;

    if (!name || name.length > 120) {
      return badRequest("Nama lengkap wajib diisi dan maksimal 120 karakter.");
    }
    if (!EMAIL_PATTERN.test(email) || email.length > 254) {
      return badRequest("Format email tidak valid.", "invalid_email");
    }
    if (username.length < 3 || username.length > 30) {
      return badRequest("Nama pengguna harus 3 sampai 30 karakter.", "invalid_username");
    }
    if (!validatePassword(password)) {
      return badRequest(
        "Kata sandi minimal 8 karakter dan harus berisi huruf serta angka.",
        "invalid_password",
      );
    }

    const db = getAdminClient();
    const emailPattern = escapeLikePattern(email);
    const emailExists = await db.from("users").select("id")
      .ilike("email", emailPattern).maybeSingle();
    if (emailExists.error) throw new Error("Email lookup failed.");
    if (emailExists.data) {
      return errorResponse(409, "email_taken", "Email sudah digunakan.");
    }
    const usernameExists = await db.from("users").select("id")
      .ilike("username", escapeLikePattern(username)).maybeSingle();
    if (usernameExists.error) throw new Error("Username lookup failed.");
    if (usernameExists.data) {
      return errorResponse(409, "username_taken", "Nama pengguna sudah dipakai.");
    }

    const { data, error } = await db.from("users").insert({
      name,
      email,
      username,
      password_hash: await hashPassword(password),
    }).select("id, name, username, email, avatar_url").single();

    if (error) {
      if (error.code === "23505") {
        const duplicateEmail = error.message?.includes("email");
        return duplicateEmail
          ? errorResponse(409, "email_taken", "Email sudah digunakan.")
          : errorResponse(409, "username_taken", "Nama pengguna sudah dipakai.");
      }
      throw new Error("Account creation failed.");
    }
    return json({ user: data }, 201);
  },

  "POST /auth/login": async (req: Request) => {
    const body = await readJson<Record<string, unknown>>(req);
    if (!body) return badRequest("Body request tidak valid.");
    const identifier = typeof body.identifier === "string"
      ? body.identifier.trim()
      : "";
    const password = body.password;
    const deviceId = typeof body.device_id === "string"
      ? body.device_id.trim()
      : "";
    if (!identifier || typeof password !== "string" || !deviceId) {
      return badRequest("Identifier, kata sandi, dan device_id wajib diisi.");
    }
    if (deviceId.length > 128) return badRequest("device_id tidak valid.");

    const db = getAdminClient();
    const normalized = identifier.toLowerCase();
    const exactPattern = escapeLikePattern(normalized);
    const columns =
      "id, name, username, email, avatar_url, password_hash, failed_attempts, locked_until";
    const emailLookup = await db.from("users")
      .select(columns)
      .ilike("email", exactPattern)
      .maybeSingle();
    if (emailLookup.error) throw new Error("Login email lookup failed.");
    const usernameLookup = emailLookup.data
      ? null
      : await db.from("users")
        .select(columns)
        .ilike("username", exactPattern)
        .maybeSingle();
    if (usernameLookup?.error) throw new Error("Login username lookup failed.");
    const user = emailLookup.data ?? usernameLookup?.data;

    if (!user) return unauthorized("Email/username atau kata sandi salah.");
    if (user.locked_until && new Date(user.locked_until).getTime() > Date.now()) {
      return errorResponse(
        423,
        "account_locked",
        "Akun terkunci sementara. Silakan coba lagi nanti.",
      );
    }

    const valid = await verifyPassword(password, user.password_hash);
    if (!valid) {
      const failure = await db.rpc("record_failed_login", {
        p_user_id: user.id,
        p_max_attempts: MAX_FAILED_ATTEMPTS,
        p_lock_minutes: LOCK_MINUTES,
      });
      if (failure.error) throw new Error("Failed-login counter update failed.");
      if (failure.data) {
        return errorResponse(
          423,
          "account_locked",
          "Terlalu banyak percobaan gagal. Akun dikunci selama 15 menit.",
        );
      }
      return unauthorized("Email/username atau kata sandi salah.");
    }

    const reset = await db.from("users")
      .update({ failed_attempts: 0, locked_until: null })
      .eq("id", user.id);
    if (reset.error) throw new Error("Failed-login counter reset failed.");

    return json(await issueSession(db, user, deviceId));
  },

  "POST /auth/refresh": async (req: Request) => {
    const body = await readJson<Record<string, unknown>>(req);
    const refreshToken = typeof body?.refresh_token === "string"
      ? body.refresh_token
      : "";
    if (!refreshToken) return badRequest("Refresh token wajib diisi.");

    const db = getAdminClient();
    const oldHash = await sha256Hex(refreshToken);
    const lookup = await db.from("sessions")
      .select("id, user_id, device_id")
      .eq("refresh_hash", oldHash)
      .is("revoked_at", null)
      .gt("expires_at", new Date().toISOString())
      .maybeSingle();
    if (lookup.error) throw new Error("Refresh session lookup failed.");
    if (!lookup.data) return unauthorized("Refresh token tidak valid atau kedaluwarsa.");

    const userResult = await db.from("users")
      .select("id, name, username, email, avatar_url")
      .eq("id", lookup.data.user_id)
      .maybeSingle();
    if (userResult.error) throw new Error("Refresh user lookup failed.");
    if (!userResult.data) return unauthorized();

    const nextToken = randomToken(32);
    const nextHash = await sha256Hex(nextToken);
    const expiresAt = new Date(
      Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000,
    ).toISOString();
    const now = Math.floor(Date.now() / 1000);
    const accessToken = await signJwt(
      {
        sub: lookup.data.user_id,
        sid: lookup.data.id,
        device_id: lookup.data.device_id,
        iss: "barakah",
        aud: "barakah-app",
        iat: now,
        exp: now + ACCESS_TOKEN_SECONDS,
      },
      jwtSecret(),
    );
    const rotated = await db.from("sessions")
      .update({ refresh_hash: nextHash, expires_at: expiresAt })
      .eq("id", lookup.data.id)
      .eq("refresh_hash", oldHash)
      .is("revoked_at", null)
      .gt("expires_at", new Date().toISOString())
      .select("id")
      .maybeSingle();
    if (rotated.error) throw new Error("Refresh-token rotation failed.");
    if (!rotated.data) return unauthorized("Refresh token sudah digunakan atau dicabut.");

    return json({
      access_token: accessToken,
      refresh_token: nextToken,
      expires_in: ACCESS_TOKEN_SECONDS,
      user: publicUser(userResult.data),
    });
  },

  // Logout is authorized by the refresh token because Flutter clears secure
  // storage before sending the request. It is safe to retry while offline.
  "POST /auth/logout": async (req: Request) => {
    const body = await readJson<Record<string, unknown>>(req);
    const refreshToken = typeof body?.refresh_token === "string"
      ? body.refresh_token
      : "";
    if (!refreshToken) return badRequest("Refresh token wajib diisi.");
    const db = getAdminClient();
    const { error } = await db.from("sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("refresh_hash", await sha256Hex(refreshToken))
      .is("revoked_at", null);
    if (error) throw new Error("Session revocation failed.");
    return json({ ok: true });
  },

  "POST /auth/password": async (req: Request) => {
    const auth = await findActiveSession(req);
    if (auth instanceof Response) return auth;
    const body = await readJson<Record<string, unknown>>(req);
    const oldPassword = body?.old_password;
    const newPassword = body?.new_password;
    if (typeof oldPassword !== "string" || !validatePassword(newPassword)) {
      return badRequest("Kata sandi lama dan kata sandi baru yang valid wajib diisi.");
    }

    const account = await auth.db.from("users")
      .select("password_hash")
      .eq("id", auth.userId)
      .single();
    if (account.error) throw new Error("Password account lookup failed.");
    if (!await verifyPassword(oldPassword, account.data.password_hash)) {
      return unauthorized("Kata sandi lama tidak benar.", "invalid_old_password");
    }

    if (oldPassword === newPassword) {
      return badRequest("Kata sandi baru harus berbeda dari kata sandi lama.");
    }
    const newPasswordHash = await hashPassword(newPassword);
    const changed = await auth.db.rpc("change_password_and_revoke_sessions", {
      p_user_id: auth.userId,
      p_current_session_id: auth.sessionId,
      p_current_device_id: auth.deviceId,
      p_expected_password_hash: account.data.password_hash,
      p_password_hash: newPasswordHash,
    });
    if (changed.error?.message?.includes("password_changed")) {
      return errorResponse(
        409,
        "password_changed",
        "Kata sandi berubah saat permintaan diproses. Silakan masuk kembali.",
      );
    }
    if (changed.error) throw new Error("Password change transaction failed.");
    return json({ ok: true });
  },

  "POST /auth/biometric/enable": async (req: Request) => {
    const auth = await findActiveSession(req);
    if (auth instanceof Response) return auth;
    const body = await readJson<Record<string, unknown>>(req);
    const password = body?.password;
    const deviceId = typeof body?.device_id === "string" ? body.device_id : "";
    if (typeof password !== "string" || !deviceId) {
      return badRequest("Kata sandi dan device_id wajib diisi.");
    }
    if (deviceId !== auth.deviceId) {
      return errorResponse(403, "device_mismatch", "Perangkat tidak sesuai dengan sesi.");
    }

    const account = await auth.db.from("users")
      .select("password_hash")
      .eq("id", auth.userId)
      .single();
    if (account.error) throw new Error("Biometric account lookup failed.");
    if (!await verifyPassword(password, account.data.password_hash)) {
      return unauthorized("Kata sandi tidak benar.");
    }

    const token = randomToken(32);
    const revoked = await auth.db.from("device_tokens")
      .update({ revoked_at: new Date().toISOString() })
      .eq("user_id", auth.userId)
      .eq("device_id", deviceId)
      .is("revoked_at", null);
    if (revoked.error) throw new Error("Previous device token revocation failed.");
    const inserted = await auth.db.from("device_tokens").insert({
      user_id: auth.userId,
      device_id: deviceId,
      token_hash: await sha256Hex(token),
    });
    if (inserted.error) throw new Error("Device token creation failed.");
    return json({ device_token: token });
  },

  "POST /auth/biometric/login": async (req: Request) => {
    const body = await readJson<Record<string, unknown>>(req);
    const deviceId = typeof body?.device_id === "string" ? body.device_id : "";
    const deviceToken = typeof body?.device_token === "string"
      ? body.device_token
      : "";
    if (!deviceId || !deviceToken) {
      return badRequest("device_id dan device_token wajib diisi.");
    }

    const db = getAdminClient();
    const token = await db.from("device_tokens")
      .select("user_id")
      .eq("device_id", deviceId)
      .eq("token_hash", await sha256Hex(deviceToken))
      .is("revoked_at", null)
      .order("created_at", { ascending: false })
      .limit(1)
      .maybeSingle();
    if (token.error) throw new Error("Device token lookup failed.");
    if (!token.data) return unauthorized("Token biometrik tidak valid.");

    const user = await db.from("users")
      .select("id, name, username, email, avatar_url")
      .eq("id", token.data.user_id)
      .maybeSingle();
    if (user.error) throw new Error("Biometric user lookup failed.");
    if (!user.data) return unauthorized();
    return json(await issueSession(db, user.data, deviceId));
  },

  "DELETE /auth/biometric": async (req: Request, ctx: RouteContext) => {
    const auth = await findActiveSession(req);
    if (auth instanceof Response) return auth;
    const deviceId = ctx.url.searchParams.get("device_id");
    if (!deviceId || deviceId !== auth.deviceId) {
      return errorResponse(403, "device_mismatch", "Perangkat tidak sesuai dengan sesi.");
    }
    const { error } = await auth.db.from("device_tokens")
      .update({ revoked_at: new Date().toISOString() })
      .eq("user_id", auth.userId)
      .eq("device_id", deviceId)
      .is("revoked_at", null);
    if (error) throw new Error("Device token revocation failed.");
    return json({ ok: true });
  },

  "GET /auth/sessions": async (req: Request) => {
    const auth = await findActiveSession(req);
    if (auth instanceof Response) return auth;
    const { data, error } = await auth.db.from("sessions")
      .select("id, device_id, created_at")
      .eq("user_id", auth.userId)
      .is("revoked_at", null)
      .gt("expires_at", new Date().toISOString())
      .order("created_at", { ascending: false });
    if (error) throw new Error("Active sessions lookup failed.");
    return json({
      items: (data ?? []).map((session) => ({
        id: session.id,
        device: session.device_id,
        last_seen_at: session.created_at,
        current: session.id === auth.sessionId,
      })),
    });
  },

  "DELETE /auth/sessions/:id": async (req: Request, ctx: RouteContext) => {
    const auth = await findActiveSession(req);
    if (auth instanceof Response) return auth;
    const id = ctx.params.id;
    if (!UUID_PATTERN.test(id)) return badRequest("Id sesi tidak valid.");
    if (id === auth.sessionId) {
      return badRequest("Sesi perangkat ini tidak dapat dicabut dari sini.");
    }
    const { data, error } = await auth.db.from("sessions")
      .update({ revoked_at: new Date().toISOString() })
      .eq("id", id)
      .eq("user_id", auth.userId)
      .is("revoked_at", null)
      .select("id")
      .maybeSingle();
    if (error) throw new Error("Session revocation failed.");
    if (!data) return notFound("Sesi tidak ditemukan.");
    return json({ ok: true });
  },
};

Deno.serve(serveRoutes(routes, "auth"));
