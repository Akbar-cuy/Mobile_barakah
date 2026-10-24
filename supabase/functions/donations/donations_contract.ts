const DECIMAL = /^(?:0|[1-9]\d*)(?:\.\d+)?$/;
const MAX_AMOUNT = 1_000_000_000_000_000;
const UUID =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

export function isDonationUuid(value: string): boolean {
  return UUID.test(value);
}

export function isPositiveDonationDecimal(value: string): boolean {
  if (!DECIMAL.test(value)) return false;
  const amount = Number(value);
  return Number.isFinite(amount) && amount > 0 && amount <= MAX_AMOUNT;
}

export function isDonationAmountValid(
  amount: string,
  amountIdr: string,
  currency: string,
): boolean {
  if (
    !isPositiveDonationDecimal(amount) || !isPositiveDonationDecimal(amountIdr)
  ) return false;
  const amountScale = amount.split(".")[1]?.length ?? 0;
  const idrScale = amountIdr.split(".")[1]?.length ?? 0;
  return idrScale === 0 &&
    (currency === "IDR" ? amountScale === 0 : amountScale <= 2);
}

export function isZakatCampaign(title: string): boolean {
  return title === "Zakat Maal" || title === "Zakat Fitrah";
}
