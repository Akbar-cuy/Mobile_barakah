import { serveRoutes } from "./router.ts";

function assert(condition: unknown, message: string): asserts condition {
  if (!condition) throw new Error(message);
}

Deno.test("router normalizes the Supabase gateway prefix and rejects wrong methods", async () => {
  const handler = serveRoutes({
    "GET /auth/status": async () =>
      new Response(JSON.stringify({ ok: true }), {
        headers: { "Content-Type": "application/json" },
      }),
  }, "auth");

  const response = await handler(
    new Request("https://example.test/functions/v1/auth/status"),
  );
  assert(response.status === 200, "gateway path was not routed");
  assert((await response.json()).ok === true, "route response was not preserved");

  const wrongMethod = await handler(
    new Request("https://example.test/functions/v1/auth/status", {
      method: "POST",
    }),
  );
  assert(wrongMethod.status === 405, "unsupported method was not rejected");
  assert(
    wrongMethod.headers.get("Access-Control-Allow-Methods")?.includes("GET"),
    "allowed method was not reported",
  );
});
