// Pengarah rute sederhana untuk Edge Function yang melayani beberapa path.
import { corsHeaders, handleOptions } from "./cors.ts";
import { errorResponse, serverError } from "./http.ts";

export type RouteContext = { params: Record<string, string>; url: URL };
export type RouteHandler = (req: Request, ctx: RouteContext) => Promise<Response>;

type Compiled = { method: string; regex: RegExp; keys: string[]; handler: RouteHandler };

function compile(pattern: string, handler: RouteHandler): Compiled {
  const [method, path] = pattern.split(" ");
  const keys: string[] = [];
  const source = path
    .split("/")
    .map((seg) => {
      if (seg.startsWith(":")) {
        keys.push(seg.slice(1));
        return "([^/]+)";
      }
      return seg.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    })
    .join("/");
  return { method, regex: new RegExp(`^${source}/?$`), keys, handler };
}

export function serveRoutes(
  routes: Record<string, RouteHandler>,
  functionName?: string,
) {
  const compiled = Object.entries(routes).map(([p, h]) => compile(p, h));
  return async (req: Request): Promise<Response> => {
    const options = handleOptions(req);
    if (options) return options;

    const url = new URL(req.url);
    let path = url.pathname;
    const gatewayPrefix = functionName
      ? `/functions/v1/${functionName}`
      : null;
    if (gatewayPrefix && path.startsWith(gatewayPrefix)) {
      path = path.slice("/functions/v1".length) || `/${functionName}`;
    } else if (
      functionName &&
      path !== `/${functionName}` &&
      !path.startsWith(`/${functionName}/`)
    ) {
      path = `/${functionName}${path === "/" ? "" : path}`;
    }

    const pathMatches = compiled.filter((route) => route.regex.test(path));
    for (const r of compiled) {
      if (r.method !== req.method) continue;
      const match = r.regex.exec(path);
      if (!match) continue;
      const params: Record<string, string> = {};
      r.keys.forEach((k, i) => (params[k] = decodeURIComponent(match[i + 1])));
      try {
        return await r.handler(req, { params, url });
      } catch (error) {
        console.error("Edge function request failed.", {
          method: req.method,
          functionName,
          errorType: error instanceof Error ? error.name : "unknown",
        });
        return serverError();
      }
    }
    if (pathMatches.length > 0) {
      const allow = [...new Set(pathMatches.map((route) => route.method))].join(", ");
      return new Response(
        JSON.stringify({
          error: {
            code: "method_not_allowed",
            message: "Metode HTTP tidak diizinkan untuk endpoint ini.",
          },
        }),
        {
          status: 405,
          headers: {
            ...corsHeaders,
            "Allow": `${allow}, OPTIONS`,
            "Access-Control-Allow-Methods": `${allow}, OPTIONS`,
            "Content-Type": "application/json",
          },
        },
      );
    }
    return errorResponse(404, "route_not_found", "Endpoint tidak ditemukan.");
  };
}
