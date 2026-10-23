import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { badRequest, errorResponse, json, readJson } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;
const HASH = /^[0-9a-f]{64}$/i;
const DECIMAL = /^(?:0|[1-9]\d*)(?:\.\d+)?$/;

type LedgerBlock = {
  idx: number;
  ts: string;
  donor_alias: string;
  campaign: string;
  amount: string;
  currency: string;
  amount_idr: string;
  rate_used: string;
  prev_hash: string;
  nonce: number;
  hash: string;
};

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function isBlock(value: unknown): value is LedgerBlock {
  if (!isRecord(value)) return false;
  const strings = [
    "ts", "donor_alias", "campaign", "amount", "currency", "amount_idr",
    "rate_used", "prev_hash", "hash",
  ];
  if (
    strings.some((key) => typeof value[key] !== "string") ||
    typeof value.idx !== "number" || typeof value.nonce !== "number"
  ) return false;
  if (
    !Number.isSafeInteger(value.idx) || value.idx < 0 ||
    !Number.isSafeInteger(value.nonce) || value.nonce < 0
  ) return false;
  const block: LedgerBlock = {
    idx: value.idx,
    ts: value.ts as string,
    donor_alias: value.donor_alias as string,
    campaign: value.campaign as string,
    amount: value.amount as string,
    currency: value.currency as string,
    amount_idr: value.amount_idr as string,
    rate_used: value.rate_used as string,
    prev_hash: value.prev_hash as string,
    nonce: value.nonce,
    hash: value.hash as string,
  };
  return Boolean(
    block.ts && !Number.isNaN(Date.parse(block.ts)) &&
    block.amount.length <= 40 && block.amount_idr.length <= 40 &&
    block.rate_used.length <= 40 &&
    block.donor_alias.length > 0 && block.donor_alias.length <= 80 &&
    block.campaign.length > 0 && block.campaign.length <= 120 &&
    !block.donor_alias.includes("|") && !block.campaign.includes("|") &&
    DECIMAL.test(block.amount) && DECIMAL.test(block.amount_idr) &&
    DECIMAL.test(block.rate_used) &&
    ["IDR", "USD", "SAR"].includes(block.currency) &&
    HASH.test(block.prev_hash) && HASH.test(block.hash)
  );
}

function validationError(message: string) {
  return badRequest(message, "invalid_donation");
}

function isPositiveDecimal(value: string): boolean {
  if (!DECIMAL.test(value)) return false;
  return /[1-9]/.test(value);
}

async function create(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;
  const body = await readJson<Record<string, unknown>>(req);
  if (!body || typeof body.id !== "string" || !UUID.test(body.id)) {
    return validationError("Id donasi tidak valid.");
  }
  if (!isBlock(body.block)) return validationError("Blok donasi tidak valid.");
  if (body.block.idx < 1) return validationError("Indeks blok donasi tidak valid.");
  if (
    body.genesis !== undefined &&
    (!isBlock(body.genesis) || body.genesis.idx !== 0)
  ) {
    return validationError("Blok genesis tidak valid.");
  }
  if (
    typeof body.campaign !== "string" ||
    body.campaign !== body.block.campaign ||
    typeof body.amount !== "string" || body.amount !== body.block.amount ||
    typeof body.currency !== "string" || body.currency !== body.block.currency ||
    typeof body.amount_idr !== "string" ||
    body.amount_idr !== body.block.amount_idr ||
    typeof body.rate_used !== "string" || body.rate_used !== body.block.rate_used ||
    typeof body.created_at !== "string" || body.created_at !== body.block.ts ||
    !isPositiveDecimal(body.block.amount) ||
    !isPositiveDecimal(body.block.amount_idr) ||
    !isPositiveDecimal(body.block.rate_used)
  ) {
    return validationError("Rincian donasi tidak sesuai dengan blok ledger.");
  }
  if (
    body.campaign_id !== undefined &&
    (typeof body.campaign_id !== "string" || !UUID.test(body.campaign_id))
  ) {
    return validationError("Id kampanye tidak valid.");
  }

  const { data, error } = await db.rpc("apply_donation", {
    p_user_id: auth.userId,
    p_donation: body,
  });
  if (error) {
    const message = error.message ?? "";
    if (message.includes("donation_id_conflict")) {
      return errorResponse(409, "donation_id_conflict", "Id donasi sudah digunakan.");
    }
    if (message.includes("ledger_conflict") || message.includes("genesis_conflict")) {
      return errorResponse(409, "ledger_conflict", "Rantai ledger berubah; sinkronkan dan coba lagi.");
    }
    if (
      message.includes("invalid_") || message.includes("missing_genesis")
    ) {
      return validationError("Blok ledger ditolak karena tidak valid.");
    }
    if (error.code === "23503") {
      return errorResponse(400, "campaign_not_found", "Kampanye tidak ditemukan.");
    }
    throw new Error("Donation transaction failed.");
  }
  return json(data);
}

Deno.serve(serveRoutes({ "POST /donations": create }, "donations"));
