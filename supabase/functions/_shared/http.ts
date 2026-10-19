// Bentuk respons yang seragam (PRD FR-API-01 dan FR-API-02).
import { corsHeaders } from "./cors.ts";

export function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

export function errorResponse(
  status: number,
  code: string,
  message: string,
  extra: Record<string, unknown> = {},
): Response {
  return json({ error: { code, message, ...extra } }, status);
}

export const badRequest = (message: string, code = "bad_request") =>
  errorResponse(400, code, message);
export const unauthorized = (
  message = "Sesi berakhir. Silakan masuk kembali.",
  code = "unauthorized",
) => errorResponse(401, code, message);
export const notFound = (message = "Data tidak ditemukan.") =>
  errorResponse(404, "not_found", message);
export const serverError = (message = "Terjadi gangguan di server.") =>
  errorResponse(500, "server_error", message);

export async function readJson<T = Record<string, unknown>>(
  req: Request,
): Promise<T | null> {
  try {
    return (await req.json()) as T;
  } catch {
    return null;
  }
}
