// Pengarah rute sederhana untuk Edge Function yang melayani beberapa path.
import { handleOptions } from "./cors.ts";
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

export function serveRoutes(routes: Record<string, RouteHandler>) {
  const compiled = Object.entries(routes).map(([p, h]) => compile(p, h));
  return async (req: Request): Promise<Response> => {
    const options = handleOptions(req);
    if (options) return options;

    const url = new URL(req.url);
    for (const r of compiled) {
      if (r.method !== req.method) continue;
      const match = r.regex.exec(url.pathname);
      if (!match) continue;
      const params: Record<string, string> = {};
      r.keys.forEach((k, i) => (params[k] = decodeURIComponent(match[i + 1])));
      try {
        return await r.handler(req, { params, url });
      } catch (e) {
        console.error(e);
        return serverError();
      }
    }
    return errorResponse(404, "route_not_found", "Endpoint tidak ditemukan.");
  };
}
