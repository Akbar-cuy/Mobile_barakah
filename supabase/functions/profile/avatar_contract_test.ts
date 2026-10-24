import assert from "node:assert/strict";
import { MAX_AVATAR_BYTES, parseAvatarUpload, sniffImageType } from "./avatar_contract.ts";

function b64(bytes: number[]): string {
  return btoa(String.fromCharCode(...bytes));
}
const JPEG = [0xff, 0xd8, 0xff, 0xe0, 1, 2, 3];
const PNG = [0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0, 0];
const WEBP = [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50, 1];

Deno.test("jenis gambar dikenali dari byte pertama", () => {
  assert.equal(sniffImageType(new Uint8Array(JPEG)), "image/jpeg");
  assert.equal(sniffImageType(new Uint8Array(PNG)), "image/png");
  assert.equal(sniffImageType(new Uint8Array(WEBP)), "image/webp");
  assert.equal(sniffImageType(new Uint8Array([0x47, 0x49, 0x46, 0x38])), null);
  assert.equal(sniffImageType(new Uint8Array([])), null);
});

Deno.test("unggahan valid diterima", () => {
  const r = parseAvatarUpload({ content_type: "image/png", data: b64(PNG) });
  assert.ok(r.ok);
  if (r.ok) {
    assert.equal(r.upload.extension, "png");
    assert.equal(r.upload.bytes.length, PNG.length);
  }
});

Deno.test("jenis yang diklaim harus sama dengan isi", () => {
  const r = parseAvatarUpload({ content_type: "image/png", data: b64(JPEG) });
  assert.equal(r.ok, false);
});

Deno.test("bukan gambar ditolak", () => {
  const html = Array.from(new TextEncoder().encode("<script>alert(1)</script>"));
  const r = parseAvatarUpload({ content_type: "image/jpeg", data: b64(html) });
  assert.equal(r.ok, false);
});

Deno.test("base64 rusak atau kosong ditolak", () => {
  for (const data of ["", "%%%", "abc", "abcd=="]) {
    assert.equal(parseAvatarUpload({ content_type: "image/png", data }).ok, false, data);
  }
  assert.equal(parseAvatarUpload(null).ok, false);
  assert.equal(parseAvatarUpload({ content_type: "image/png" }).ok, false);
  assert.equal(parseAvatarUpload({ content_type: "image/png", data: 5 }).ok, false);
});

Deno.test("lebih dari 1 MB ditolak", () => {
  const big = new Uint8Array(MAX_AVATAR_BYTES + 1);
  big.set(JPEG);
  let bin = "";
  for (let i = 0; i < big.length; i += 8192) {
    bin += String.fromCharCode(...big.subarray(i, i + 8192));
  }
  const r = parseAvatarUpload({ content_type: "image/jpeg", data: btoa(bin) });
  assert.equal(r.ok, false);
  if (!r.ok) assert.equal(r.code, "avatar_too_large");
});
