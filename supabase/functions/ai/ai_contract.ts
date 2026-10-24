export const REQUIRED_DISCLAIMER =
  "Ini informasi umum. Untuk kasus yang spesifik, tanyakan kepada ulama atau ustadz.";

export function finalizeAnswer(answer: string): string {
  const trimmed = answer.trim();
  if (!trimmed || trimmed.endsWith(REQUIRED_DISCLAIMER)) return trimmed;
  return `${trimmed}\n\n${REQUIRED_DISCLAIMER}`;
}
