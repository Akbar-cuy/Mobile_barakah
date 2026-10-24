// Authenticated Barakah exchange-rate endpoint. The public data source does
// not require an API key; responses are cached in the existing rate_cache table.
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json } from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import { requireUser } from "../_shared/auth.ts";
import {
  isRatesRequestValid,
  type NormalizedRates,
  normalizeProviderRates,
  RATE_CURRENCIES,
  type RateCurrency,
} from "./rates_contract.ts";

const PROVIDER_URL = "https://api.frankfurter.dev/v2/rates";
const CACHE_TTL_MS = 20 * 60 * 60 * 1000;
const PROVIDER_TIMEOUT_MS = 8_000;

type CacheRow = {
  quote: string;
  rate: number;
  fetched_at: string;
  source_date: string | null;
};

type CachedRates = NormalizedRates & { fetchedAt: number };

async function getCache(
  db: ReturnType<typeof getAdminClient>,
): Promise<CachedRates | null> {
  const { data, error } = await db
    .from("rate_cache")
    .select("quote, rate, fetched_at, source_date")
    .eq("base", "USD")
    .in("quote", [...RATE_CURRENCIES]);
  if (error) throw new Error("Rate cache lookup failed.");
  if (!data || data.length < RATE_CURRENCIES.length) return null;

  const rates: Partial<Record<RateCurrency, number>> = {};
  const sourceDates: Partial<Record<RateCurrency, string>> = {};
  const fetchedTimes: number[] = [];
  for (const raw of data as CacheRow[]) {
    if (!(RATE_CURRENCIES as readonly string[]).includes(raw.quote)) continue;
    const quote = raw.quote as RateCurrency;
    if (!Number.isFinite(raw.rate) || raw.rate <= 0 || !raw.source_date) {
      return null;
    }
    const fetchedAt = Date.parse(raw.fetched_at);
    if (!Number.isFinite(fetchedAt)) return null;
    rates[quote] = raw.rate;
    sourceDates[quote] = raw.source_date;
    fetchedTimes.push(fetchedAt);
  }
  if (
    RATE_CURRENCIES.some((currency) => rates[currency] === undefined) ||
    rates.USD !== 1
  ) return null;

  const finalRates = rates as Record<RateCurrency, number>;
  const finalDates = sourceDates as Record<RateCurrency, string>;
  const updatedAt = RATE_CURRENCIES.map((currency) => finalDates[currency])
    .sort()[0];
  return {
    base: "USD",
    rates: finalRates,
    sourceDates: finalDates,
    updatedAt,
    fetchedAt: Math.min(...fetchedTimes),
  };
}

function toResponse(data: CachedRates | NormalizedRates, stale: boolean) {
  return {
    base: data.base,
    rates: data.rates,
    updated_at: data.updatedAt,
    stale,
    provider: "Frankfurter",
  };
}

async function fetchProviderRates(): Promise<NormalizedRates> {
  const url = new URL(PROVIDER_URL);
  url.searchParams.set("base", "USD");
  url.searchParams.set(
    "quotes",
    RATE_CURRENCIES.filter((currency) => currency !== "USD").join(","),
  );
  const response = await fetch(url, {
    signal: AbortSignal.timeout(PROVIDER_TIMEOUT_MS),
    headers: { Accept: "application/json" },
  });
  if (!response.ok) {
    throw new Error(`Rates provider returned ${response.status}.`);
  }
  return normalizeProviderRates(await response.json());
}

async function updateCache(
  db: ReturnType<typeof getAdminClient>,
  data: NormalizedRates,
): Promise<void> {
  const fetchedAt = new Date().toISOString();
  const rows = RATE_CURRENCIES.map((quote) => ({
    base: "USD",
    quote,
    rate: data.rates[quote],
    fetched_at: fetchedAt,
    source_date: data.sourceDates[quote],
  }));
  const { error } = await db.from("rate_cache").upsert(rows, {
    onConflict: "base,quote",
  });
  if (error) throw new Error("Rate cache update failed.");
}

async function getRates(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  if (!isRatesRequestValid(ctx.url)) {
    return badRequest("Base kurs yang didukung adalah USD.", "invalid_base");
  }

  const cached = await getCache(db);
  if (cached && Date.now() - cached.fetchedAt < CACHE_TTL_MS) {
    return json(toResponse(cached, false));
  }

  try {
    const latest = await fetchProviderRates();
    await updateCache(db, latest);
    return json(toResponse(latest, false));
  } catch {
    if (cached) return json(toResponse(cached, true));
    return errorResponse(
      503,
      "rates_unavailable",
      "Kurs tidak tersedia saat ini. Silakan coba lagi.",
    );
  }
}

Deno.serve(serveRoutes({
  "GET /rates": getRates,
}, "rates"));
