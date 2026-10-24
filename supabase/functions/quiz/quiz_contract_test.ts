import {
  parseQuestionRequest,
  parseQuizSubmission,
  scoreAnswers,
} from "./quiz_contract.ts";

function assert(condition: unknown, message = "assertion failed"): asserts condition {
  if (!condition) throw new Error(message);
}

const ids = Array.from({ length: 10 }, (_, index) =>
  "00000000-0000-4000-8000-" + String(index + 1).padStart(12, "0")
);

function submission() {
  return {
    id: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    category: "umum",
    score: 120,
    correct: 1,
    total: 10,
    avg_time: 2,
    created_at: "2026-10-24T00:00:00.000Z",
    answers: ids.map((question_id, index) => ({
      question_id,
      selected_index: index === 0 ? 2 : null,
      elapsed_ms: index === 0 ? 0 : 2_000,
    })),
  };
}

Deno.test("quiz question request validates category and version", () => {
  const parsed = parseQuestionRequest(
    new URL("https://example.test/quiz/questions?category=umum&version=3"),
  );
  assert(parsed?.category === "umum" && parsed.version === 3);
  assert(parseQuestionRequest(new URL("https://example.test/?category=other")) === null);
  assert(parseQuestionRequest(new URL("https://example.test/?category=umum&version=-1")) === null);
});

Deno.test("quiz attempt requires ten unique bounded answers", () => {
  assert(parseQuizSubmission(submission()) !== null);
  const invalid = submission();
  invalid.answers[9].question_id = invalid.answers[0].question_id;
  assert(parseQuizSubmission(invalid) === null);
  const tooLong = submission();
  tooLong.answers[0].elapsed_ms = 20_001;
  assert(parseQuizSubmission(tooLong) === null);
});

Deno.test("quiz score is recomputed from correct answers and speed", () => {
  const parsed = parseQuizSubmission(submission());
  assert(parsed !== null);
  const answers = new Map(ids.map((id, index) => [id, index === 0 ? 2 : 0]));
  const score = scoreAnswers(parsed.answers, answers);
  assert(score?.correct === 1 && score.score === 120 && score.avg_time === 1.8);
  assert(scoreAnswers(parsed.answers, new Map()) === null);
});
