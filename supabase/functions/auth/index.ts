
import { serveRoutes } from "../_shared/router.ts";
import {
  badRequest,
  errorResponse,
  json,
  readJson,
  serverError,
  unauthorized,
} from "../_shared/http.ts";
import { getAdminClient } from "../_shared/db.ts";
import {
  hashPassword,
  verifyPassword,
  randomToken,
  sha256Hex,
  signJwt,
} from "../_shared/crypto.ts";

const ACCESS_TOKEN_SECONDS = 900;
const REFRESH_TOKEN_DAYS = 30;
const MAX_FAILED_ATTEMPTS = 5;
const LOCK_MINUTES = 15;

function getJwtSecret(): string {
  const secret = Deno.env.get("BARAKAH_JWT_SECRET");
  if (!secret) {
    throw new Error("BARAKAH_JWT_SECRET belum dikonfigurasi.");
  }
  return secret;
}

const routes = {
  "POST /auth/register": async (req: Request) => {
    const body = await readJson<{
      name?: string;
      email?: string;
      username?: string;
      password?: string;
    }>(req);

    if (!body) return badRequest("Body request tidak valid.");

    const name = body.name?.trim();
    const email = body.email?.trim().toLowerCase();
    const username = body.username?.trim();
    const password = body.password;

    if (!name || !email || !username || !password) {
      return badRequest("Nama, email, username, dan password wajib diisi.");
    }

    if (password.length < 8) {
      return badRequest("Password minimal 8 karakter.");
    }

    try {
      const db = getAdminClient();

      const { data: existing, error: lookupError } = await db
        .from("users")
        .select("id")
        .or(`email.eq.${email},username.eq.${username}`)
        .limit(1);

      if (lookupError) {
        console.error("Register lookup error:", lookupError);
        return serverError();
      }

      if (existing?.length) {
        return errorResponse(
          409,
          "user_exists",
          "Email atau username sudah digunakan.",
        );
      }

      const passwordHash = await hashPassword(password);

      const { data: user, error } = await db
        .from("users")
        .insert({
          name,
          email,
          username,
          password_hash: passwordHash,
        })
        .select("id, name, username, email, avatar_url")
        .single();

      if (error || !user) {
        console.error("Register database error:", error);
        return serverError();
      }

      return json({ user }, 201);
    } catch (error) {
      console.error("Register error:", error);
      return serverError();
    }
  },

  "POST /auth/login": async (req: Request) => {
    const body = await readJson<{
      identifier?: string;
      password?: string;
      device_id?: string;
    }>(req);

    if (!body) return badRequest("Body request tidak valid.");

    const identifier = body.identifier?.trim();
    const password = body.password;
    const deviceId = body.device_id?.trim();

    if (!identifier || !password || !deviceId) {
      return badRequest("Identifier, password, dan device_id wajib diisi.");
    }

    try {
      const db = getAdminClient();
      const normalized = identifier.toLowerCase();

      let { data: user, error: lookupError } = await db
        .from("users")
        .select(
          "id, name, username, email, avatar_url, password_hash, failed_attempts, locked_until",
        )
        .eq("email", normalized)
        .maybeSingle();

      if (lookupError) {
        console.error("Login lookup error:", lookupError);
        return serverError();
      }

      if (!user) {
        const result = await db
          .from("users")
          .select(
            "id, name, username, email, avatar_url, password_hash, failed_attempts, locked_until",
          )
          .eq("username", identifier)
          .maybeSingle();

        user = result.data;
        lookupError = result.error;

        if (lookupError) {
          console.error("Login username lookup error:", lookupError);
          return serverError();
        }
      }

      if (!user) {
        return unauthorized("Email/username atau password salah.");
      }

      if (
        user.locked_until &&
        new Date(user.locked_until).getTime() > Date.now()
      ) {
        return errorResponse(
          423,
          "account_locked",
          "Akun terkunci sementara. Silakan coba lagi nanti.",
        );
      }

      const passwordValid = await verifyPassword(
        password,
        user.password_hash,
      );

      if (!passwordValid) {
        const failedAttempts = (user.failed_attempts ?? 0) + 1;
        const isLocked = failedAttempts >= MAX_FAILED_ATTEMPTS;

        const { error: updateError } = await db
          .from("users")
          .update({
            failed_attempts: isLocked ? 0 : failedAttempts,
            locked_until: isLocked
              ? new Date(Date.now() + LOCK_MINUTES * 60_000).toISOString()
              : null,
          })
          .eq("id", user.id);

        if (updateError) {
          console.error("Login failed-attempt update error:", updateError);
        }

        if (isLocked) {
          return errorResponse(
            423,
            "account_locked",
            "Terlalu banyak percobaan gagal. Akun dikunci selama 15 menit.",
          );
        }

        return unauthorized("Email/username atau password salah.");
      }

      const { error: resetError } = await db
        .from("users")
        .update({
          failed_attempts: 0,
          locked_until: null,
        })
        .eq("id", user.id);

      if (resetError) {
        console.error("Login reset attempts error:", resetError);
        return serverError();
      }

      const nowSeconds = Math.floor(Date.now() / 1000);
      const sessionId = crypto.randomUUID();
      const refreshToken = randomToken(32);
      const refreshHash = await sha256Hex(refreshToken);
      const accessToken = await signJwt(
        {
          sub: user.id,
          sid: sessionId,
          device_id: deviceId,
          iat: nowSeconds,
          exp: nowSeconds + ACCESS_TOKEN_SECONDS,
        },
        getJwtSecret(),
      );

      const expiresAt = new Date(
        Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000,
      ).toISOString();

      const { error: sessionError } = await db
        .from("sessions")
        .insert({
          id: sessionId,
          user_id: user.id,
          device_id: deviceId,
          refresh_hash: refreshHash,
          expires_at: expiresAt,
        });

      if (sessionError) {
        console.error("Login session insert error:", sessionError);
        return serverError();
      }

      return json({
        access_token: accessToken,
        refresh_token: refreshToken,
        expires_in: ACCESS_TOKEN_SECONDS,
        user: {
          id: user.id,
          name: user.name,
          username: user.username,
          email: user.email,
          avatar_url: user.avatar_url,
        },
      });
    } catch (error) {
      console.error("Login error:", error);
      return serverError();
    }
  },
};

Deno.serve(serveRoutes(routes));
