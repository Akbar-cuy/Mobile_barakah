import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { json } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";

const BLOCK_COLUMNS =
  "idx, ts, donor_alias, campaign, amount, currency, amount_idr, rate_used, prev_hash, nonce, hash";
const PAGE_SIZE = 1000;

async function headForUser(db: ReturnType<typeof getAdminClient>, userId: string) {
  const { data, error } = await db.from("ledger_heads")
    .select("head_idx, head_hash")
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw new Error("Ledger head lookup failed.");
  return data;
}

async function getHead(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const head = await headForUser(db, auth.userId);
  return json({
    head_idx: head?.head_idx ?? null,
    head_hash: head?.head_hash ?? null,
    head: head ? { idx: head.head_idx, hash: head.head_hash } : null,
  });
}

async function list(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;

  const items: Record<string, unknown>[] = [];
  for (let from = 0; ; from += PAGE_SIZE) {
    const { data, error } = await db.from("ledger_blocks")
      .select(BLOCK_COLUMNS)
      .eq("user_id", auth.userId)
      .order("idx", { ascending: true })
      .range(from, from + PAGE_SIZE - 1);
    if (error) throw new Error("Ledger block query failed.");
    items.push(...(data ?? []));
    if (!data || data.length < PAGE_SIZE) break;
  }

  const head = await headForUser(db, auth.userId);
  return json({
    items,
    head_idx: head?.head_idx ?? null,
    head_hash: head?.head_hash ?? null,
    head: head ? { idx: head.head_idx, hash: head.head_hash } : null,
  });
}

Deno.serve(serveRoutes({
  "GET /ledger": list,
  "GET /ledger/verify": getHead,
}, "ledger"));
