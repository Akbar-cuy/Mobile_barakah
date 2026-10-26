export type NearbyRequest = {
  lat: number;
  lon: number;
  radiusKm: number;
  query: string;
};

export type MosqueItem = {
  osm_id: string;
  name: string;
  lat: number;
  lon: number;
  distance_m: number;
  address?: string;
};

export type OverpassElement = {
  type?: unknown;
  id?: unknown;
  lat?: unknown;
  lon?: unknown;
  center?: { lat?: unknown; lon?: unknown };
  tags?: unknown;
};

const MAX_RADIUS_KM = 10;
const ALLOWED_QUERY_KEYS = new Set(["lat", "lng", "radius", "q"]);

export function parseNearbyRequest(url: URL): NearbyRequest | null {
  const keys = [...url.searchParams.keys()];
  if (keys.some((key) => !ALLOWED_QUERY_KEYS.has(key))) return null;
  for (const key of ["lat", "lng", "radius", "q"]) {
    if (url.searchParams.getAll(key).length > 1) return null;
  }
  const lat = parseFinite(url.searchParams.get("lat"));
  const lon = parseFinite(url.searchParams.get("lng"));
  const radiusKm = parseFinite(url.searchParams.get("radius"));
  const query = (url.searchParams.get("q") ?? "").trim();
  if (
    lat === null || lat < -90 || lat > 90 ||
    lon === null || lon < -180 || lon > 180 ||
    radiusKm === null || radiusKm <= 0 || radiusKm > MAX_RADIUS_KM ||
    query.length > 100
  ) return null;
  return { lat, lon, radiusKm, query };
}

export function normalizeOverpassElements(
  elements: unknown,
  request: NearbyRequest,
): MosqueItem[] {
  if (!Array.isArray(elements)) throw new Error("Invalid Overpass response.");
  const uniqueIds = new Set<string>();
  const items: MosqueItem[] = [];
  const query = request.query.toLocaleLowerCase();

  for (const value of elements as OverpassElement[]) {
    if (!value || typeof value !== "object") continue;
    if (!(["node", "way", "relation"] as unknown[]).includes(value.type)) {
      continue;
    }
    if (!Number.isSafeInteger(value.id) || (value.id as number) <= 0) continue;
    const tags = asStringRecord(value.tags);
    const name = tags.name?.trim() || tags["name:id"]?.trim() ||
      "Masjid tanpa nama";
    const fullAddress = address(tags);
    if (
      query && !name.toLocaleLowerCase().includes(query) &&
      !(fullAddress ?? "").toLocaleLowerCase().includes(query)
    ) continue;

    const lat = finiteCoordinate(value.center?.lat ?? value.lat, -90, 90);
    const lon = finiteCoordinate(value.center?.lon ?? value.lon, -180, 180);
    if (lat === null || lon === null) continue;
    const distance = distanceMeters(request.lat, request.lon, lat, lon);
    if (distance > request.radiusKm * 1000) continue;

    const type = value.type as string;
    const osmId = `${type}/${value.id}`;
    if (uniqueIds.has(osmId)) continue;
    uniqueIds.add(osmId);
    items.push({
      osm_id: osmId,
      name,
      lat,
      lon,
      distance_m: distance,
      ...(fullAddress ? { address: fullAddress } : {}),
    });
  }

  items.sort((a, b) => a.distance_m - b.distance_m);
  const deduplicated: MosqueItem[] = [];
  for (const item of items) {
    const normalizedName = item.name.toLocaleLowerCase().trim();
    const duplicate = normalizedName !== "masjid tanpa nama" &&
      deduplicated.some((existing) =>
        existing.name.toLocaleLowerCase().trim() === normalizedName &&
        distanceMeters(existing.lat, existing.lon, item.lat, item.lon) <= 20
      );
    if (!duplicate) deduplicated.push(item);
  }
  return deduplicated;
}

const PHOTON_URL = "https://photon.komoot.io/api/";
const PHOTON_LIMIT = 50;

/**
 * Alamat pencarian Photon (cadangan bila semua server Overpass gagal).
 * Photon tidak punya filter radius, jadi dipakai kotak batas (bbox) di sekitar
 * titik; penyaringan jarak sebenarnya tetap dilakukan normalizeOverpassElements.
 */
export function makePhotonUrl(request: NearbyRequest): string {
  const dLat = request.radiusKm / 111.32;
  const cosLat = Math.max(0.01, Math.cos(request.lat * Math.PI / 180));
  const dLon = request.radiusKm / (111.32 * cosLat);
  const clamp = (v: number, min: number, max: number) =>
    Math.min(max, Math.max(min, v));
  const bbox = [
    clamp(request.lon - dLon, -180, 180),
    clamp(request.lat - dLat, -90, 90),
    clamp(request.lon + dLon, -180, 180),
    clamp(request.lat + dLat, -90, 90),
  ].map((v) => v.toFixed(5)).join(",");
  const params = new URLSearchParams({
    q: request.query || "masjid",
    lat: String(request.lat),
    lon: String(request.lon),
    osm_tag: "amenity:place_of_worship",
    bbox,
    limit: String(PHOTON_LIMIT),
  });
  return `${PHOTON_URL}?${params.toString()}`;
}

const PHOTON_TYPES: Record<string, string> = {
  N: "node",
  W: "way",
  R: "relation",
};

/**
 * Mengubah GeoJSON Photon menjadi bentuk elemen Overpass supaya memakai
 * normalizeOverpassElements yang sama (jarak, duplikat, pencarian nama).
 * Mengembalikan null bila bentuk respons tidak dikenali.
 */
export function photonToElements(payload: unknown): OverpassElement[] | null {
  if (!payload || typeof payload !== "object") return null;
  const features = (payload as { features?: unknown }).features;
  if (!Array.isArray(features)) return null;
  const elements: OverpassElement[] = [];
  for (const feature of features) {
    if (!feature || typeof feature !== "object") continue;
    const { geometry, properties } = feature as {
      geometry?: { coordinates?: unknown };
      properties?: Record<string, unknown>;
    };
    const coords = geometry?.coordinates;
    if (!Array.isArray(coords) || coords.length < 2) continue;
    if (!properties || typeof properties !== "object") continue;
    const type = PHOTON_TYPES[String(properties.osm_type)];
    const id = properties.osm_id;
    if (!type || typeof id !== "number") continue;
    const tags: Record<string, string> = {};
    const put = (key: string, value: unknown) => {
      if (typeof value === "string" && value.trim()) tags[key] = value.trim();
    };
    put("name", properties.name);
    put("addr:street", properties.street);
    put("addr:suburb", properties.district);
    put("addr:city", properties.city);
    put("addr:postcode", properties.postcode);
    elements.push({ type, id, lon: coords[0], lat: coords[1], tags });
  }
  return elements;
}

export function makeOverpassQuery(request: NearbyRequest): string {
  const radius = request.radiusKm * 1000;
  const lat = request.lat;
  const lon = request.lon;
  return [
    "[out:json][timeout:15];",
    "(",
    `node(around:${radius},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `way(around:${radius},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `relation(around:${radius},${lat},${lon})["amenity"="place_of_worship"]["religion"="muslim"];`,
    `node(around:${radius},${lat},${lon})["building"="mosque"];`,
    `way(around:${radius},${lat},${lon})["building"="mosque"];`,
    `relation(around:${radius},${lat},${lon})["building"="mosque"];`,
    ");out center tags;",
  ].join("");
}

function parseFinite(raw: string | null): number | null {
  if (raw === null || raw.trim() === "") return null;
  const value = Number(raw);
  return Number.isFinite(value) ? value : null;
}

function finiteCoordinate(
  value: unknown,
  min: number,
  max: number,
): number | null {
  if (
    typeof value !== "number" || !Number.isFinite(value) || value < min ||
    value > max
  ) {
    return null;
  }
  return value;
}

function asStringRecord(value: unknown): Record<string, string> {
  if (!value || typeof value !== "object" || Array.isArray(value)) return {};
  return Object.fromEntries(
    Object.entries(value).filter((entry): entry is [string, string] =>
      typeof entry[1] === "string"
    ),
  );
}

function address(tags: Record<string, string>): string | undefined {
  const parts = [
    tags["addr:street"],
    tags["addr:suburb"],
    tags["addr:city"],
    tags["addr:postcode"],
  ].filter((part) => typeof part === "string" && part.length > 0);
  return parts.length ? parts.join(", ") : undefined;
}

function distanceMeters(
  lat1: number,
  lon1: number,
  lat2: number,
  lon2: number,
) {
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