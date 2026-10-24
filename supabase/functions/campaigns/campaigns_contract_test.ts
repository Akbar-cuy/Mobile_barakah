import {
  campaignMatches,
  isCampaignId,
  parseCampaignFilter,
} from "./campaigns_contract.ts";

Deno.test("campaign filters are bounded and only accept supported parameters", () => {
  const parsed = parseCampaignFilter(
    new URL("https://example.test/campaigns?q=air&category=Air"),
  );
  assert(parsed?.query === "air" && parsed.category === "Air");
  assert(
    parseCampaignFilter(
      new URL("https://example.test/campaigns?unexpected=1"),
    ) === null,
  );
  assert(
    parseCampaignFilter(
      new URL(`https://example.test/campaigns?q=${"a".repeat(101)}`),
    ) === null,
  );
});

Deno.test("campaign matching is case insensitive and respects category", () => {
  const campaign = {
    title: "Air Bersih",
    description: "Sumur desa",
    category: "Air",
  };
  assert(campaignMatches(campaign, { query: "BERSIH", category: "Air" }));
  assert(!campaignMatches(campaign, { query: "bersih", category: "Masjid" }));
});

Deno.test("campaign ids must be UUIDs", () => {
  assert(isCampaignId("53a875cf-0f64-4a40-a7ca-3196d61d7264"));
  assert(!isCampaignId("air"));
});

function assert(
  condition: unknown,
  message = "assertion failed",
): asserts condition {
  if (!condition) throw new Error(message);
}
