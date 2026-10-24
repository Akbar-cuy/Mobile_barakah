import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, json, notFound } from "../_shared/http.ts";
import { type RouteContext, serveRoutes } from "../_shared/router.ts";
import {
  campaignMatches,
  isCampaignId,
  parseCampaignFilter,
} from "./campaigns_contract.ts";

const COLUMNS = "id, title, description, category, target_idr, version";

async function list(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const filter = parseCampaignFilter(ctx.url);
  if (!filter) {
    return badRequest("Filter kampanye tidak valid.", "invalid_filter");
  }

  const { data, error } = await db.from("campaigns")
    .select(COLUMNS)
    .eq("active", true)
    .order("title", { ascending: true })
    .limit(200);
  if (error) throw new Error("Campaign lookup failed.");
  const items = (data ?? []).filter((row) => campaignMatches(row, filter));
  return json({ items });
}

async function detail(req: Request, ctx: RouteContext): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const id = ctx.params.id;
  if (!isCampaignId(id)) {
    return badRequest("Id kampanye tidak valid.", "invalid_campaign_id");
  }
  const { data, error } = await db.from("campaigns")
    .select(COLUMNS)
    .eq("id", id)
    .eq("active", true)
    .maybeSingle();
  if (error) throw new Error("Campaign lookup failed.");
  if (!data) return notFound("Kampanye tidak tersedia.");
  return json({ item: data });
}

Deno.serve(serveRoutes({
  "GET /campaigns": list,
  "GET /campaigns/:id": detail,
}, "campaigns"));
