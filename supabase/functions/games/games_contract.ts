const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const MAX_DIRECTION_SCORE = 1_125;

export type GameScore = {
  id: string;
  game: "direction";
  score: number;
  created_at: string;
};

export function parseGameScore(value: unknown): GameScore | null {
  if (value === null || typeof value !== "object" || Array.isArray(value)) return null;
  const body = value as Record<string, unknown>;
  if (
    typeof body.id !== "string" || !UUID.test(body.id) ||
    body.game !== "direction" ||
    !Number.isSafeInteger(body.score) || (body.score as number) < 0 ||
    (body.score as number) > MAX_DIRECTION_SCORE ||
    typeof body.created_at !== "string" ||
    Number.isNaN(Date.parse(body.created_at)) || !body.created_at.endsWith("Z")
  ) return null;
  return {
    id: body.id,
    game: "direction",
    score: body.score as number,
    created_at: body.created_at,
  };
}

export function isSameScore(
  row: Record<string, unknown>,
  userId: string,
  score: GameScore,
): boolean {
  return row.user_id === userId && row.game === score.game &&
    row.score === score.score && typeof row.created_at === "string" &&
    Date.parse(row.created_at) === Date.parse(score.created_at);
}
