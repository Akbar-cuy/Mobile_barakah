-- Make an AI reply uniquely addressable by its originating user message.
begin;

alter table public.chat_messages
  add column if not exists reply_to uuid
  references public.chat_messages(id) on delete cascade;

create unique index if not exists chat_messages_reply_to_uq
  on public.chat_messages (user_id, reply_to)
  where reply_to is not null;

commit;
