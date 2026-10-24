-- Foto profil (FR-PRO-03). Bucket publik agar aplikasi dapat menampilkan
-- tautannya langsung. Penulisan hanya lewat Edge Function (peran service),
-- karena tidak ada kebijakan tulis untuk peran lain.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'avatars',
  'avatars',
  true,
  1048576,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;
