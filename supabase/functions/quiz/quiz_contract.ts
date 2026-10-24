export const QUIZ_CATEGORIES = [
  "rukun_iman",
  "sejarah_nabi",
  "fikih_dasar",
  "umum",
] as const;

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const QUIZ_MS = 20_000;

export type QuizAnswer = {
  question_id: string;
  selected_index: number | null;
  elapsed_ms: number;
};

export type QuizSubmission = {
  id: string;
  category: typeof QUIZ_CATEGORIES[number];
  score: number;
  correct: number;
  total: number;
  avg_time: number;
  created_at: string;
  answers: QuizAnswer[];
};

export function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

export function isQuizCategory(value: unknown): value is QuizSubmission["category"] {
  return typeof value === "string" &&
    QUIZ_CATEGORIES.includes(value as QuizSubmission["category"]);
}

export function parseQuestionRequest(url: URL): { category: QuizSubmission["category"]; version: number } | null {
  if ([...url.searchParams.keys()].some((key) => !["category", "version"].includes(key))) {
    return null;
  }
  const category = url.searchParams.get("category");
  const rawVersion = url.searchParams.get("version") ?? "0";
  if (!isQuizCategory(category) || !/^\d+$/.test(rawVersion)) return null;
  const version = Number(rawVersion);
  if (!Number.isSafeInteger(version) || version < 0) return null;
  return { category, version };
}

export function parseQuizSubmission(value: unknown): QuizSubmission | null {
  if (!isRecord(value)) return null;
  const { id, category, score, correct, total, avg_time, created_at, answers } = value;
  if (
    typeof id !== "string" || !UUID.test(id) || !isQuizCategory(category) ||
    !Number.isSafeInteger(score) || (score as number) < 0 || (score as number) > 2_500 ||
    !Number.isSafeInteger(correct) || (correct as number) < 0 || (correct as number) > 10 ||
    total !== 10 || typeof avg_time !== "number" || !Number.isFinite(avg_time) ||
    avg_time < 0 || avg_time > 20 || typeof created_at !== "string" ||
    Number.isNaN(Date.parse(created_at)) || !created_at.endsWith("Z") ||
    !Array.isArray(answers) || answers.length !== 10
  ) return null;

  const parsed: QuizAnswer[] = [];
  const ids = new Set<string>();
  for (const answer of answers) {
    if (!isRecord(answer)) return null;
    const questionId = answer.question_id;
    const selected = answer.selected_index;
    const elapsed = answer.elapsed_ms;
    if (
      typeof questionId !== "string" || !UUID.test(questionId) || ids.has(questionId) ||
      !(selected === null || (Number.isSafeInteger(selected) && (selected as number) >= 0 && (selected as number) <= 3)) ||
      !Number.isSafeInteger(elapsed) || (elapsed as number) < 0 || (elapsed as number) > QUIZ_MS
    ) return null;
    ids.add(questionId);
    parsed.push({
      question_id: questionId,
      selected_index: selected as number | null,
      elapsed_ms: elapsed as number,
    });
  }
  return {
    id,
    category,
    score: score as number,
    correct: correct as number,
    total,
    avg_time,
    created_at,
    answers: parsed,
  };
}

export type ScoredAttempt = { score: number; correct: number; avg_time: number };

export function scoreAnswers(
  answers: QuizAnswer[],
  answerById: Map<string, number>,
): ScoredAttempt | null {
  if (answers.length !== 10 || answerById.size !== 10) return null;
  let correct = 0;
  let score = 0;
  let elapsedTotal = 0;
  for (const answer of answers) {
    const answerIndex = answerById.get(answer.question_id);
    if (answerIndex === undefined) return null;
    elapsedTotal += answer.elapsed_ms;
    if (answer.selected_index === answerIndex) {
      correct++;
      score += 100 + Math.floor((QUIZ_MS - answer.elapsed_ms) / 1000);
    }
  }
  return { score, correct, avg_time: elapsedTotal / answers.length / 1000 };
}

export function sameScoredAttempt(
  row: Record<string, unknown>,
  userId: string,
  submission: QuizSubmission,
  calculated: ScoredAttempt,
): boolean {
  return row.user_id === userId && row.category === submission.category &&
    row.score === calculated.score && row.correct === calculated.correct &&
    row.total === 10 && typeof row.avg_time === "number" &&
    Math.abs(row.avg_time - calculated.avg_time) < 0.001 &&
    typeof row.created_at === "string" &&
    Date.parse(row.created_at) === Date.parse(submission.created_at);
}
