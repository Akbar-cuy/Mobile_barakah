import {
  isRatesRequestValid,
  normalizeProviderRates,
} from "./rates_contract.ts";

Deno.test("rates endpoint accepts only the USD base query", () => {
  assert(isRatesRequestValid(new URL("https://example.test/rates")));
  assert(isRatesRequestValid(new URL("https://example.test/rates?base=USD")));
  assert(!isRatesRequestValid(new URL("https://example.test/rates?base=EUR")));
  assert(
    !isRatesRequestValid(new URL("https://example.test/rates?base=USD&x=1")),
  );
  assert(
    !isRatesRequestValid(
      new URL("https://example.test/rates?base=USD&base=USD"),
    ),
  );
});

Deno.test("provider response is normalized and reports the oldest quote date", () => {
  const normalized = normalizeProviderRates([
    { base: "USD", quote: "IDR", rate: 16000, date: "2026-10-23" },
    { base: "USD", quote: "SAR", rate: 3.75, date: "2026-10-24" },
  ]);

  assert(normalized.rates.USD === 1, "USD identity rate was not normalized");
  assert(normalized.rates.IDR === 16000, "IDR rate was not preserved");
  assert(
    normalized.updatedAt === "2026-10-23",
    "oldest quote date was not used",
  );
});

Deno.test("provider response rejects incomplete, nonfinite, or impossible data", () => {
  const incomplete = [
    { base: "USD", quote: "IDR", rate: 16000, date: "2026-10-24" },
  ];
  const nonfinite = [
    { base: "USD", quote: "IDR", rate: Number.NaN, date: "2026-10-24" },
    { base: "USD", quote: "SAR", rate: 3.75, date: "2026-10-24" },
  ];
  const invalidDate = [
    { base: "USD", quote: "IDR", rate: 16000, date: "2026-02-31" },
    { base: "USD", quote: "SAR", rate: 3.75, date: "2026-10-24" },
  ];

  for (const payload of [incomplete, nonfinite, invalidDate]) {
    let rejected = false;
    try {
      normalizeProviderRates(payload);
    } catch {
      rejected = true;
    }
    assert(rejected, "invalid provider rates were accepted");
  }
});

function assert(
  condition: unknown,
  message = "assertion failed",
): asserts condition {
  if (!condition) throw new Error(message);
}
