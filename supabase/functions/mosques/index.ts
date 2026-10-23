import { requireUser } from "../_shared/auth.ts";
import { getAdminClient } from "../_shared/db.ts";
import { errorResponse, json } from "../_shared/http.ts";
import { serveRoutes } from "../_shared/router.ts";

const MAX_RADIUS_KM = 10;
const OVERPASS_URL = "https://overpass-api.de/api/interpreter";

type OverpassElement = {
  type?: string;
  id?: number;
  lat?: number;
  lon?: number;
  center?: { lat?: number; lon?: number };
  tags?: Record<string, string>;
};

function numberParam(url: URL, key: string): number | null {
  const raw = url.searchParams.get(key);
  if (raw === null || raw.trim() === "") return null;
  const value = Number(raw);
  return Number.isFinite(value) ? value : null;
}

function distanceMeters(lat1: number, lon1: number, lat2: number, lon2: number) {
  const radians = (degrees: number) => degrees * Math.PI / 180;
  const dLat = radians(lat2 - lat1);
  const dLon = radians(lon2 - lon1);
  const a = Math.sin(dLat / 2) ** 2 +
    Math.cos(radians(lat1)) * Math.cos(radians(lat2)) *
      Math.sin(dLon / 2) ** 2;
  const bounded = Math.min(1, Math.max(0, a));
  return 6_371_000 * 2 *
    Math.atan2(Math.sqrt(bounded), Math.sqrt(1 - bounded));
}

function address(tags: Record<string, string> | undefined): string | undefined {
  if (!tags) return undefined;
  const parts = [
    tags["addr:street"],
    tags["addr:suburb"],
    tags["addr:city"],
    tags["addr:postcode"],
  ].filter((part) => typeof part === "string" && part.length > 0);
  return parts.length ? parts.join(", ") : undefined;
}

async function nearby(req: Request): Promise<Response> {
  const db = getAdminClient();
  const auth = await requireUser(req, db);
  if (auth instanceof Response) return auth;

  const url = new URL(req.url);
  const lat = numberParam(url, "lat");
  const lon = numberParam(url, "lng");
  const radius = numberParam(url, "radius");
  const query = (url.searchParams.get("q") ?? "").trim().toLocaleLowerCase();
  if (
    lat === null || lat < -90 || lat > 90 ||
    lon === null || lon < -180 || lon > 180 ||
    radius === null || radius <= 0 || radius > MAX_RADIUS_KM ||
    query.length > 100
  ) {
    return errorResponse(400, "invalid_location", "Koordinat, radius, atau pencarian tidak valid.");
  }

  const overpassQuery = [
    "[out:json][timeout:20];",
    "(",
    `node(around:${radius * 1000},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `way(around:${radius * 1000},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `relation(around:${radius * 1000},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `node(around:${radius * 1000},${lat},${lon})["building"="mosque"];`,
    `way(around:${radius * 1000},${lat},${lon})["building"="mosque"];`,
    `relation(around:${radius * 1000},${lat},${lon})["building"="mosque"];`,
    ");out center tags;",
  ].join("");

  let elements: OverpassElement[];
  try {
    const response = await fetch(OVERPASS_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        "User-Agent": "Barakah/2.0",
      },
      body: new URLSearchParams({ data: overpassQuery }),
      signal: AbortSignal.timeout(25_000),
    });
    if (!response.ok) {
      return errorResponse(
        502,
        "mosque_source_unavailable",
        "Data masjid sementara tidak tersedia.",
      );
    }
    const result = await response.json() as { elements?: OverpassElement[] };
    if (!Array.isArray(result.elements)) throw new Error("Invalid Overpass response.");
    elements = result.elements;
  } catch {
    return errorResponse(
      502,
      "mosque_source_unavailable",
      "Data masjid sementara tidak tersedia.",
    );
  }

  const items = elements.flatMap((element) => {
    const point = element.center ?? element;
    const elementLat = point.lat;
    const elementLon = point.lon;
    if (
      typeof element.id !== "number" ||
      typeof element.type !== "string" ||
      typeof elementLat !== "number" ||
      typeof elementLon !== "number"
    ) return [];
    const tags = element.tags;
    const name = tags?.name?.trim() || tags?.["name:id"]?.trim() ||
      "Masjid tanpa nama";
    const fullAddress = address(tags);
    if (
      query &&
      !name.toLocaleLowerCase().includes(query) &&
      !(fullAddress ?? "").toLocaleLowerCase().includes(query)
    ) return [];
    const distance = distanceMeters(lat, lon, elementLat, elementLon);
    if (distance > radius * 1000) return [];
    return [{
      osm_id: `${element.type}/${element.id}`,
      name,
      lat: elementLat,
      lon: elementLon,
      distance_m: distance,
      ...(fullAddress ? { address: fullAddress } : {}),
    }];
  }).sort((a, b) => a.distance_m - b.distance_m);

  return json({ items });
}

Deno.serve(serveRoutes({ "GET /mosques/nearby": nearby }, "mosques"));
