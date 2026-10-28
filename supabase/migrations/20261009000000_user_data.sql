-- Dados do usuário do Oz (ver docs/arquitetura.md, seção 4).
-- Os IDs são gerados no app; a escrita é idempotente por upsert no id.

-- Preenche server_updated_at com o relógio do servidor em toda gravação:
-- é o cursor do "o que mudou desde X?" da sincronização.
create function public.touch_server_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.server_updated_at := now();
  return new;
end;
$$;

-- Leitura sempre passa por esta função; a plataforma para nutricionistas
-- só precisará trocá-la, sem reescrever as policies.
create function public.can_read_user(target uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select target = (select auth.uid());
$$;

create table public.profiles (
  id                uuid primary key references auth.users on delete cascade,
  name              text not null check (length(trim(name)) > 0),
  goal              text not null check (goal in ('lose', 'maintain', 'gain')),
  gender            text not null check (gender in ('male', 'female')),
  birth_date        date not null,
  activity_level    text not null check (activity_level in
                      ('sedentary', 'light', 'moderate', 'heavy', 'athlete')),
  height_cm         numeric not null check (height_cm between 100 and 250),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now()
);

create table public.nutrition_goals (
  id                uuid primary key,
  user_id           uuid not null default auth.uid() references auth.users on delete cascade,
  calories          int not null check (calories > 0),
  carbs_g           numeric not null check (carbs_g >= 0),
  protein_g         numeric not null check (protein_g >= 0),
  fat_g             numeric not null check (fat_g >= 0),
  effective_from    date not null,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  unique (user_id, effective_from)
);

create table public.weight_entries (
  id                uuid primary key,
  user_id           uuid not null default auth.uid() references auth.users on delete cascade,
  measured_on       date not null,
  weight_kg         numeric not null check (weight_kg between 30 and 300),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now(),
  unique (user_id, measured_on)
);

create table public.meals (
  id                uuid primary key,
  user_id           uuid not null default auth.uid() references auth.users on delete cascade,
  type              text not null check (type in ('breakfast', 'lunch', 'dinner', 'snack')),
  eaten_at          timestamptz not null,
  local_date        date not null,
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now()
);

-- food_id não tem chave estrangeira: o catálogo TACO vive no app e o item
-- guarda uma cópia do alimento.
create table public.meal_items (
  id                uuid primary key,
  user_id           uuid not null default auth.uid() references auth.users on delete cascade,
  meal_id           uuid not null references public.meals on delete cascade,
  food_id           text,
  position          int not null check (position >= 0),
  food_name         text not null,
  food_emoji        text not null,
  kcal_100g         numeric not null check (kcal_100g >= 0),
  carbs_100g        numeric not null check (carbs_100g >= 0),
  protein_100g      numeric not null check (protein_100g >= 0),
  fat_100g          numeric not null check (fat_100g >= 0),
  portion_unit      text not null,
  portion_grams     numeric not null check (portion_grams > 0),
  quantity          numeric not null check (quantity > 0),
  created_at        timestamptz not null,
  updated_at        timestamptz not null,
  deleted_at        timestamptz,
  server_updated_at timestamptz not null default now()
);

-- Índices do pull ("mudou desde X") e das consultas por usuário.
create index nutrition_goals_sync on public.nutrition_goals (user_id, server_updated_at);
create index weight_entries_sync on public.weight_entries (user_id, server_updated_at);
create index meals_sync on public.meals (user_id, server_updated_at);
create index meals_user_date on public.meals (user_id, local_date);
create index meal_items_sync on public.meal_items (user_id, server_updated_at);
create index meal_items_meal on public.meal_items (meal_id);

do $$
declare
  t text;
begin
  foreach t in array array['profiles', 'nutrition_goals', 'weight_entries', 'meals', 'meal_items']
  loop
    execute format(
      'create trigger touch_server_updated_at before insert or update on public.%I
         for each row execute function public.touch_server_updated_at()', t);
    execute format('alter table public.%I enable row level security', t);
  end loop;
end;
$$;

-- RLS: lê quem can_read_user permite; só o dono escreve. Não há policy de
-- delete: exclusões são lógicas (deleted_at), e a exclusão da conta apaga
-- tudo em cascata a partir de auth.users.
create policy "profiles: leitura" on public.profiles
  for select to authenticated using (public.can_read_user(id));
create policy "profiles: criação pelo dono" on public.profiles
  for insert to authenticated with check (id = (select auth.uid()));
create policy "profiles: edição pelo dono" on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

do $$
declare
  t text;
begin
  foreach t in array array['nutrition_goals', 'weight_entries', 'meals', 'meal_items']
  loop
    execute format(
      'create policy "%1$s: leitura" on public.%1$I
         for select to authenticated using (public.can_read_user(user_id))', t);
    execute format(
      'create policy "%1$s: criação pelo dono" on public.%1$I
         for insert to authenticated with check (user_id = (select auth.uid()))', t);
    execute format(
      'create policy "%1$s: edição pelo dono" on public.%1$I
         for update to authenticated
         using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()))', t);
  end loop;
end;
$$;

-- Item só pode apontar para refeição do mesmo usuário.
create function public.check_meal_item_owner()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if not exists (
    select 1 from public.meals m where m.id = new.meal_id and m.user_id = new.user_id
  ) then
    raise exception 'meal_items.meal_id must belong to the same user';
  end if;
  return new;
end;
$$;

create trigger check_meal_item_owner before insert or update on public.meal_items
  for each row execute function public.check_meal_item_owner();

-- Exclusão de conta pelo próprio app (exigência da App Store). Apaga o
-- usuário do Auth; os dados vão junto pelo "on delete cascade".
create function public.delete_account()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.users where id = (select auth.uid());
$$;

revoke execute on function public.delete_account() from public, anon;
grant execute on function public.delete_account() to authenticated;
revoke execute on function public.can_read_user(uuid) from public, anon;
grant execute on function public.can_read_user(uuid) to authenticated;
