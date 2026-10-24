import {
  makeOverpassQuery,
  normalizeOverpassElements,
  parseNearbyRequest,
} from "./mosques_contract.ts";
import {
  assertEquals,
  assertNotEquals,
} from "https://deno.land/std@0.224.0/assert/mod.ts";

Deno.test("nearby request validates coordinates, radius and query keys", () => {
  assertEquals(
    parseNearbyRequest(
      new URL("https://x/mosques/nearby?lat=-6.2&lng=106.8&radius=5&q=central"),
    ),
    {
      lat: -6.2,
      lon: 106.8,
      radiusKm: 5,
      query: "central",
    },
  );
  assertEquals(
    parseNearbyRequest(new URL("https://x/?lat=91&lng=0&radius=5")),
    null,
  );
  assertEquals(
    parseNearbyRequest(new URL("https://x/?lat=0&lng=0&radius=11")),
    null,
  );
  assertEquals(
    parseNearbyRequest(new URL("https://x/?lat=0&lat=1&lng=0&radius=5")),
    null,
  );
  assertEquals(
    parseNearbyRequest(new URL("https://x/?lat=0&lng=0&radius=5&token=x")),
    null,
  );
});

Deno.test("Overpass results are validated, filtered, sorted and deduplicated", () => {
  const request = { lat: 0, lon: 0, radiusKm: 2, query: "raya" };
  const items = normalizeOverpassElements([
    { type: "node", id: 10, lat: 0.001, lon: 0, tags: { name: "Masjid Raya" } },
    {
      type: "way",
      id: 11,
      center: { lat: 0.00101, lon: 0 },
      tags: { name: "Masjid Raya" },
    },
    { type: "node", id: 12, lat: 0.02, lon: 0, tags: { name: "Masjid Raya" } },
    { type: "node", id: 13, lat: 0, lon: 0, tags: { name: "Masjid Lain" } },
    {
      type: "node",
      id: 14,
      lat: 0.00101,
      lon: 0,
      tags: { name: "Masjid Raya" },
    },
    null,
  ], request);
  assertEquals(items.length, 1);
  assertEquals(items[0].osm_id, "node/10");
  assertEquals(items[0].name, "Masjid Raya");
  assertEquals(normalizeOverpassElements([], request), []);
  let rejected = false;
  try {
    normalizeOverpassElements({}, request);
  } catch {
    rejected = true;
  }
  assertEquals(rejected, true);
});

Deno.test("Overpass query is built only from validated coordinates", () => {
  const query = makeOverpassQuery({
    lat: -6.2,
    lon: 106.8,
    radiusKm: 2,
    query: "",
  });
  assertNotEquals(query.includes("NaN"), true);
  assertEquals(query.includes("around:2000,-6.2,106.8"), true);
});
