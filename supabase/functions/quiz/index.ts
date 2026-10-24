import type { SupabaseClient } from "npm:@supabase/supabase-js@2";

import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json, readJson } from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import {
  isQuizCategory,
  parseQuestionRequest,
  parseQuizSubmission,
  sameScoredAttempt,
  scoreAnswers,
} from "./quiz_contract.ts";

async function questions(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const request = parseQuestionRequest(ctx.url);
  if (!request) return badRequest("Permintaan bank soal tidak valid.", "invalid_quiz_query");

  const { data, error } = await db.from("quiz_questions")
    .select("id, category, difficulty, question, options, answer_index, explanation, version")
    .eq("category", request.category)
    .order("difficulty", { ascending: true })
    .limit(500);
  if (error) throw new Error("Quiz question lookup failed.");
  const items = data ?? [];
  const version = items.reduce((max, item) => Math.max(max, item.version), 0);
  return json({
    version,
    items: request.version < version ? items : [],
  });
}

async function findAttempt(db: SupabaseClient, id: string) {
  return await db.from("quiz_attempts")
    .select("id, user_id, category, score, correct, total, avg_time, created_at")
    .eq("id", id)
    .maybeSingle();
}

async function attempts(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const submission = parseQuizSubmission(await readJson(req));
  if (!submission) return badRequest("Hasil kuis tidak valid.", "invalid_quiz_attempt");

  const existingResult = await findAttempt(db, submission.id);
  if (existingResult.error) throw new Error("Quiz attempt lookup failed.");
  if (existingResult.data) {
    const { data } = existingResult;
    const expectedAnswers = await loadAnswers(db, submission);
    if (!expectedAnswers) {
      return errorResponse(409, "quiz_attempt_conflict", "Id hasil kuis sudah digunakan dengan data berbeda.");
    }
    const calculated = scoreAnswers(submission.answers, expectedAnswers);
    if (
      calculated &&
      sameScoredAttempt(data, auth.userId, submission, calculated)
    ) {
      return json({ ok: true, duplicate: true, id: submission.id });
    }
    return errorResponse(409, "quiz_attempt_conflict", "Id hasil kuis sudah digunakan dengan data berbeda.");
  }

  const answerById = await loadAnswers(db, submission);
  if (!answerById) {
    return badRequest("Soal pada hasil kuis tidak cocok dengan bank soal.", "invalid_quiz_answers");
  }
  const calculated = scoreAnswers(submission.answers, answerById);
  if (
    !calculated ||
    calculated.score !== submission.score ||
    calculated.correct !== submission.correct ||
    Math.abs(calculated.avg_time - submission.avg_time) > 0.001
  ) {
    return badRequest("Skor kuis tidak cocok dengan jawaban.", "quiz_score_mismatch");
  }

  const { error } = await db.from("quiz_attempts").insert({
    id: submission.id,
    user_id: auth.userId,
    category: submission.category,
    score: calculated.score,
    correct: calculated.correct,
    total: 10,
    avg_time: calculated.avg_time,
    created_at: submission.created_at,
  });
  if (error?.code === "23505") {
    const retry = await findAttempt(db, submission.id);
    if (retry.error) throw new Error("Quiz attempt retry lookup failed.");
    if (
      retry.data &&
      sameScoredAttempt(retry.data, auth.userId, submission, calculated)
    ) {
      return json({ ok: true, duplicate: true, id: submission.id });
    }
    return errorResponse(409, "quiz_attempt_conflict", "Id hasil kuis sudah digunakan dengan data berbeda.");
  }
  if (error) throw new Error("Quiz attempt insert failed.");
  return json({ ok: true, duplicate: false, id: submission.id, ...calculated }, 201);
}

async function loadAnswers(
  db: SupabaseClient,
  submission: NonNullable<ReturnType<typeof parseQuizSubmission>>,
): Promise<Map<string, number> | null> {
  const ids = submission.answers.map((answer) => answer.question_id);
  const { data, error } = await db.from("quiz_questions")
    .select("id, answer_index")
    .eq("category", submission.category)
    .in("id", ids);
  if (error) throw new Error("Quiz answer verification failed.");
  if (!data || data.length !== 10) return null;
  return new Map(data.map((row) => [row.id as string, row.answer_index as number]));
}

async function leaderboard(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  if ([...ctx.url.searchParams.keys()].some((key) => key !== "category")) {
    return badRequest("Filter papan skor tidak valid.", "invalid_leaderboard_filter");
  }
  const category = ctx.url.searchParams.get("category");
  if (!isQuizCategory(category)) {
    return badRequest("Kategori kuis tidak valid.", "invalid_quiz_category");
  }
  const { data, error } = await db.from("quiz_attempts")
    .select("user_id, score, created_at")
    .eq("category", category)
    .order("score", { ascending: false })
    .order("created_at", { ascending: true })
    .limit(200);
  if (error) throw new Error("Quiz leaderboard lookup failed.");
  const bestByUser = new Map<string, { user_id: string; score: number; created_at: string }>();
  for (const row of data ?? []) {
    const previous = bestByUser.get(row.user_id);
    if (!previous || row.score > previous.score) {
      bestByUser.set(row.user_id, {
        user_id: row.user_id,
        score: row.score,
        created_at: row.created_at,
      });
    }
  }
  const scores = [...bestByUser.values()]
    .sort((a, b) => b.score - a.score || a.created_at.localeCompare(b.created_at))
    .slice(0, 10);
  if (scores.length === 0) return json({ items: [] });
  const { data: users, error: usersError } = await db.from("users")
    .select("id, name")
    .in("id", scores.map((score) => score.user_id));
  if (usersError) throw new Error("Quiz leaderboard names lookup failed.");
  const names = new Map((users ?? []).map((user) => [user.id, user.name]));
  return json({
    items: scores.map((score) => ({
      name: names.get(score.user_id) ?? "Pemain",
      score: score.score,
      created_at: score.created_at,
      is_me: score.user_id === auth.userId,
    })),
  });
}

Deno.serve(serveRoutes({
  "GET /quiz/questions": questions,
  "POST /quiz/attempts": attempts,
  "GET /quiz/leaderboard": leaderboard,
}, "quiz"));
