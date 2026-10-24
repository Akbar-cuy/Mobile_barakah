import {
  isDonationAmountValid,
  isDonationUuid,
  isPositiveDonationDecimal,
  isZakatCampaign,
} from "./donations_contract.ts";

Deno.test("donation amount contract rejects invalid and out-of-range values", () => {
  assert(isDonationAmountValid("500", "500", "IDR"));
  assert(isDonationAmountValid("10.25", "160000", "USD"));
  assert(!isDonationAmountValid("0", "1", "IDR"));
  assert(!isDonationAmountValid("-1", "1", "IDR"));
  assert(!isDonationAmountValid("1.01", "1", "IDR"));
  assert(!isDonationAmountValid("10.999", "1", "USD"));
  assert(!isPositiveDonationDecimal("1e100"));
  assert(!isPositiveDonationDecimal("1000000000000001"));
});

Deno.test("donations use UUID ids and only allow system zakat without a campaign id", () => {
  assert(isDonationUuid("53a875cf-0f64-4a40-a7ca-3196d61d7264"));
  assert(!isDonationUuid("donation-1"));
  assert(isZakatCampaign("Zakat Maal"));
  assert(!isZakatCampaign("Donasi Bebas"));
});

function assert(
  condition: unknown,
  message = "assertion failed",
): asserts condition {
  if (!condition) throw new Error(message);
}
