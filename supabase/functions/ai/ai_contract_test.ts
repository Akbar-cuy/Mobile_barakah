import { finalizeAnswer, REQUIRED_DISCLAIMER } from "./ai_contract.ts";

Deno.test("AI answer ends with the required disclaimer", () => {
  const answer = finalizeAnswer("Penjelasan fikih.");
  if (!answer.endsWith(REQUIRED_DISCLAIMER)) {
    throw new Error("Required disclaimer was not appended.");
  }
});

Deno.test("AI answer does not duplicate an existing disclaimer", () => {
  const original = `Penjelasan fikih.\n\n${REQUIRED_DISCLAIMER}`;
  if (finalizeAnswer(original) !== original) {
    throw new Error("Existing disclaimer was duplicated or changed.");
  }
});
