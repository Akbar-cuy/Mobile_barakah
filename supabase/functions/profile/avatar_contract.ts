// Validasi unggahan foto profil (FR-PRO-03). Murni, tanpa akses basis data.

export const MAX_AVATAR_BYTES = 1024 * 1024;

export type AvatarUpload = {
  contentType: "image/jpeg" | "image/png" | "image/webp";
  extension: "jpg" | "png" | "webp";
  bytes: Uint8Array;
};

const TYPES = {
  "image/jpeg": "jpg",
  "image/png": "png",
  "image/webp": "webp",
} as const;

function isRecord(v: unknown): v is Record<string, unknown> {
  return v !== null && typeof v === "object" && !Array.isArray(v);
}

/** Jenis gambar menurut byte pertamanya. Nama berkas dan header tidak dipercaya. */
export function sniffImageType(b: Uint8Array): keyof typeof TYPES | null {
  if (b.length >= 3 && b[0] === 0xff && b[1] === 0xd8 && b[2] === 0xff) {
    return "image/jpeg";
  }
  if (
    b.length >= 8 && b[0] === 0x89 && b[1] === 0x50 && b[2] === 0x4e &&
    b[3] === 0x47 && b[4] === 0x0d && b[5] === 0x0a && b[6] === 0x1a &&
    b[7] === 0x0a
  ) return "image/png";
  if (
    b.length >= 12 && b[0] === 0x52 && b[1] === 0x49 && b[2] === 0x46 &&
    b[3] === 0x46 && b[8] === 0x57 && b[9] === 0x45 && b[10] === 0x42 &&
    b[11] === 0x50
  ) return "image/webp";
  return null;
}

function decodeBase64(text: string): Uint8Array | null {
  if (!/^[A-Za-z0-9+/]+={0,2}$/.test(text) || text.length % 4 !== 0) {
    return null;
  }
  try {
    const bin = atob(text);
    const out = new Uint8Array(bin.length);
    for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
    return out;
  } catch {
    return null;
  }
}

export type AvatarResult =
  | { ok: true; upload: AvatarUpload }
  | { ok: false; code: "invalid_avatar" | "avatar_too_large"; message: string };

export function parseAvatarUpload(body: unknown): AvatarResult {
  const bad = (
    code: "invalid_avatar" | "avatar_too_large",
    message: string,
  ): AvatarResult => ({ ok: false, code, message });

  if (!isRecord(body) || typeof body.data !== "string") {
    return bad("invalid_avatar", "Data foto tidak ada.");
  }
  // Batas teks base64 sebelum didekode: 4/3 dari batas byte, plus sedikit sisa.
  if (body.data.length > Math.ceil(MAX_AVATAR_BYTES * 4 / 3) + 8) {
    return bad("avatar_too_large", "Foto terlalu besar. Maksimal 1 MB.");
  }
  const bytes = decodeBase64(body.data);
  if (!bytes || bytes.length === 0) {
    return bad("invalid_avatar", "Data foto tidak valid.");
  }
  if (bytes.length > MAX_AVATAR_BYTES) {
    return bad("avatar_too_large", "Foto terlalu besar. Maksimal 1 MB.");
  }
  const type = sniffImageType(bytes);
  if (!type) {
    return bad("invalid_avatar", "Format foto harus JPEG, PNG, atau WebP.");
  }
  // Jenis yang diklaim klien harus sama dengan isi berkas.
  if (body.content_type !== type) {
    return bad("invalid_avatar", "Jenis foto tidak sesuai dengan isinya.");
  }
  return { ok: true, upload: { contentType: type, extension: TYPES[type], bytes } };
}
