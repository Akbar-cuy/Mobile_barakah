export type CampaignFilter = { query: string; category: string | null };

export function parseCampaignFilter(url: URL): CampaignFilter | null {
  const keys = [...url.searchParams.keys()];
  if (keys.some((key) => !["q", "category"].includes(key))) return null;
  if (
    url.searchParams.getAll("q").length > 1 ||
    url.searchParams.getAll("category").length > 1
  ) return null;
  const query = url.searchParams.get("q")?.trim() ?? "";
  const category = url.searchParams.get("category")?.trim() || null;
  if (query.length > 100 || (category?.length ?? 0) > 60) return null;
  return { query, category };
}

export function campaignMatches(
  campaign: { title: string; description: string; category: string },
  filter: CampaignFilter,
): boolean {
  const q = filter.query.toLocaleLowerCase();
  return (!filter.category || campaign.category === filter.category) &&
    (!q ||
      `${campaign.title} ${campaign.description}`.toLocaleLowerCase().includes(
        q,
      ));
}

export function isCampaignId(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}
