import { isSameScore, parseGameScore } from "./games_contract.ts";

function assert(condition: unknown, message = "assertion failed"): asserts condition {
  if (!condition) throw new Error(message);
}

Deno.test("direction game scores are bounded and timestamped", () => {
  const parsed = parseGameScore({
    id: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    game: "direction",
    score: 800,
    created_at: "2026-10-24T00:00:00.000Z",
  });
  assert(parsed?.score === 800);
  assert(parseGameScore({
    id: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    game: "direction",
    score: 1_126,
    created_at: "2026-10-24T00:00:00.000Z",
  }) === null);
});

Deno.test("duplicate score ids require the same owner and payload", () => {
  const score = parseGameScore({
    id: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    game: "direction",
    score: 500,
    created_at: "2026-10-24T00:00:00.000Z",
  });
  assert(score !== null);
  assert(isSameScore({
    user_id: "user",
    game: "direction",
    score: 500,
    created_at: "2026-10-24T00:00:00+00:00",
  }, "user", score));
  assert(!isSameScore({
    user_id: "other",
    game: "direction",
    score: 500,
    created_at: "2026-10-24T00:00:00Z",
  }, "user", score));
});
