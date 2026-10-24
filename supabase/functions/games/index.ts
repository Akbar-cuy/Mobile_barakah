import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { errorResponse, json, readJson } from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import { isSameScore, parseGameScore } from "./games_contract.ts";

async function findScore(db: SupabaseClient, id: string) {
  return await db.from("game_scores")
    .select("id, user_id, game, score, created_at")
    .eq("id", id)
    .maybeSingle();
}

async function createScore(req: Request, _ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const score = parseGameScore(await readJson(req));
  if (!score) {
    return errorResponse(400, "invalid_game_score", "Skor permainan tidak valid.");
  }
  const existing = await findScore(db, score.id);
  if (existing.error) throw new Error("Game score lookup failed.");
  if (existing.data) {
    if (isSameScore(existing.data, auth.userId, score)) {
      return json({ ok: true, duplicate: true, id: score.id });
    }
    return errorResponse(409, "game_score_conflict", "Id skor sudah digunakan dengan data berbeda.");
  }
  const { error } = await db.from("game_scores").insert({
    id: score.id,
    user_id: auth.userId,
    game: score.game,
    score: score.score,
    created_at: score.created_at,
  });
  if (error?.code === "23505") {
    const retry = await findScore(db, score.id);
    if (retry.error) throw new Error("Game score retry lookup failed.");
    if (retry.data && isSameScore(retry.data, auth.userId, score)) {
      return json({ ok: true, duplicate: true, id: score.id });
    }
    return errorResponse(409, "game_score_conflict", "Id skor sudah digunakan dengan data berbeda.");
  }
  if (error) throw new Error("Game score insert failed.");
  return json({ ok: true, duplicate: false, id: score.id }, 201);
}

Deno.serve(serveRoutes({
  "POST /games/scores": createScore,
}, "games"));
