create table public.game_saves (
  user_id uuid primary key references auth.users(id) on delete cascade,
  save_data jsonb not null,
  image_path text,
  updated_at timestamptz not null default now()
);

alter table public.game_saves enable row level security;
revoke all on table public.game_saves from public, anon;
grant select, insert, update on table public.game_saves to authenticated;

create policy "game_saves_select_own"
  on public.game_saves for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "game_saves_insert_own"
  on public.game_saves for insert to authenticated
  with check ((select auth.uid()) = user_id);

create policy "game_saves_update_own"
  on public.game_saves for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

insert into storage.buckets (id, name, public, file_size_limit)
values ('game-saves', 'game-saves', false, 8388608);

create policy "game_saves_storage_select_own"
  on storage.objects for select to authenticated
  using (bucket_id = 'game-saves' and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "game_saves_storage_insert_own"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'game-saves' and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "game_saves_storage_update_own"
  on storage.objects for update to authenticated
  using (bucket_id = 'game-saves' and (storage.foldername(name))[1] = (select auth.uid()::text))
  with check (bucket_id = 'game-saves' and (storage.foldername(name))[1] = (select auth.uid()::text));

create policy "game_saves_storage_delete_own"
  on storage.objects for delete to authenticated
  using (bucket_id = 'game-saves' and (storage.foldername(name))[1] = (select auth.uid()::text));
