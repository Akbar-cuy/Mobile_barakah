export const RATE_CURRENCIES = ["USD", "IDR", "SAR"] as const;
export type RateCurrency = typeof RATE_CURRENCIES[number];

export type NormalizedRates = {
  base: "USD";
  rates: Record<RateCurrency, number>;
  updatedAt: string;
  sourceDates: Record<RateCurrency, string>;
};

export function isRatesRequestValid(url: URL): boolean {
  const params = [...url.searchParams.entries()];
  return !(
    params.some(([key]) => key !== "base") ||
    url.searchParams.getAll("base").length > 1 ||
    (url.searchParams.has("base") && url.searchParams.get("base") !== "USD")
  );
}

export function normalizeProviderRates(payload: unknown): NormalizedRates {
  if (!Array.isArray(payload)) {
    throw new Error("Rates provider response invalid.");
  }
  const rates: Partial<Record<RateCurrency, number>> = {};
  const sourceDates: Partial<Record<RateCurrency, string>> = {};

  for (const row of payload) {
    if (!row || typeof row !== "object") continue;
    const item = row as Record<string, unknown>;
    if (item.base !== "USD" || typeof item.quote !== "string") continue;
    if (!(RATE_CURRENCIES as readonly string[]).includes(item.quote)) continue;
    const quote = item.quote as RateCurrency;
    const rate = item.rate;
    const date = item.date;
    const parsedDate =
      typeof date === "string" && /^\d{4}-\d{2}-\d{2}$/.test(date)
        ? new Date(`${date}T00:00:00Z`)
        : null;
    if (
      typeof rate !== "number" || !Number.isFinite(rate) || rate <= 0 ||
      typeof date !== "string" || !parsedDate ||
      Number.isNaN(parsedDate.getTime()) ||
      parsedDate.toISOString().slice(0, 10) !== date
    ) {
      throw new Error("Rates provider response invalid.");
    }
    if (!sourceDates[quote] || date > sourceDates[quote]!) {
      rates[quote] = rate;
      sourceDates[quote] = date;
    }
  }

  if (rates.USD !== undefined && rates.USD !== 1) {
    throw new Error("Rates provider response invalid.");
  }
  if (
    RATE_CURRENCIES.some((currency) =>
      currency !== "USD" && rates[currency] === undefined
    )
  ) {
    throw new Error("Rates provider response incomplete.");
  }
  const quoteDates = Object.values(sourceDates);
  const updatedAt = quoteDates.sort()[0];
  if (!updatedAt) throw new Error("Rates provider response incomplete.");
  rates.USD = 1;
  sourceDates.USD = updatedAt;
  const finalRates = rates as Record<RateCurrency, number>;
  const finalDates = sourceDates as Record<RateCurrency, string>;
  return { base: "USD", rates: finalRates, updatedAt, sourceDates: finalDates };
}
