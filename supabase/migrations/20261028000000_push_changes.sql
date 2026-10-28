-- Envio da sincronização (ver docs/arquitetura.md, seção 5).
--
-- O app manda, numa chamada só, as linhas alteradas de cada tabela:
--   {"profiles": [...], "nutrition_goals": [...], "weight_entries": [...],
--    "meals": [...], "meal_items": [...]}
-- Tudo é gravado numa transação: uma refeição nunca chega sem os itens.
--
-- - Idempotente: reenviar o mesmo pacote cai nas mesmas linhas (upsert no id).
-- - Última edição vence: a linha só é atualizada se o updated_at recebido for
--   maior que o salvo, então um reenvio atrasado não desfaz uma edição nova.
-- - O dono vem sempre da sessão (auth.uid()), nunca do pacote; como a função
--   roda com as permissões de quem chama, a RLS continua valendo.
create function public.push_changes(changes jsonb)
returns void
language plpgsql
set search_path = ''
as $$
begin
  insert into public.profiles as t (
    id, name, goal, gender, birth_date, activity_level, height_cm,
    created_at, updated_at, deleted_at
  )
  select
    r.id, r.name, r.goal, r.gender, r.birth_date, r.activity_level, r.height_cm,
    r.created_at, r.updated_at, r.deleted_at
  from jsonb_populate_recordset(null::public.profiles,
         coalesce(changes -> 'profiles', '[]')) r
  on conflict (id) do update set
    name = excluded.name,
    goal = excluded.goal,
    gender = excluded.gender,
    birth_date = excluded.birth_date,
    activity_level = excluded.activity_level,
    height_cm = excluded.height_cm,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at
  where t.updated_at < excluded.updated_at;

  insert into public.nutrition_goals as t (
    id, user_id, calories, carbs_g, protein_g, fat_g, effective_from,
    created_at, updated_at, deleted_at
  )
  select
    r.id, (select auth.uid()), r.calories, r.carbs_g, r.protein_g, r.fat_g,
    r.effective_from, r.created_at, r.updated_at, r.deleted_at
  from jsonb_populate_recordset(null::public.nutrition_goals,
         coalesce(changes -> 'nutrition_goals', '[]')) r
  on conflict (id) do update set
    calories = excluded.calories,
    carbs_g = excluded.carbs_g,
    protein_g = excluded.protein_g,
    fat_g = excluded.fat_g,
    effective_from = excluded.effective_from,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at
  where t.updated_at < excluded.updated_at;

  insert into public.weight_entries as t (
    id, user_id, measured_on, weight_kg, created_at, updated_at, deleted_at
  )
  select
    r.id, (select auth.uid()), r.measured_on, r.weight_kg,
    r.created_at, r.updated_at, r.deleted_at
  from jsonb_populate_recordset(null::public.weight_entries,
         coalesce(changes -> 'weight_entries', '[]')) r
  on conflict (id) do update set
    measured_on = excluded.measured_on,
    weight_kg = excluded.weight_kg,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at
  where t.updated_at < excluded.updated_at;

  -- Refeições antes dos itens: o item precisa da refeição já gravada.
  insert into public.meals as t (
    id, user_id, type, eaten_at, local_date, created_at, updated_at, deleted_at
  )
  select
    r.id, (select auth.uid()), r.type, r.eaten_at, r.local_date,
    r.created_at, r.updated_at, r.deleted_at
  from jsonb_populate_recordset(null::public.meals,
         coalesce(changes -> 'meals', '[]')) r
  on conflict (id) do update set
    type = excluded.type,
    eaten_at = excluded.eaten_at,
    local_date = excluded.local_date,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at
  where t.updated_at < excluded.updated_at;

  insert into public.meal_items as t (
    id, user_id, meal_id, food_id, position, food_name, food_emoji,
    kcal_100g, carbs_100g, protein_100g, fat_100g,
    portion_unit, portion_grams, quantity, created_at, updated_at, deleted_at
  )
  select
    r.id, (select auth.uid()), r.meal_id, r.food_id, r.position, r.food_name,
    r.food_emoji, r.kcal_100g, r.carbs_100g, r.protein_100g, r.fat_100g,
    r.portion_unit, r.portion_grams, r.quantity,
    r.created_at, r.updated_at, r.deleted_at
  from jsonb_populate_recordset(null::public.meal_items,
         coalesce(changes -> 'meal_items', '[]')) r
  on conflict (id) do update set
    meal_id = excluded.meal_id,
    food_id = excluded.food_id,
    position = excluded.position,
    food_name = excluded.food_name,
    food_emoji = excluded.food_emoji,
    kcal_100g = excluded.kcal_100g,
    carbs_100g = excluded.carbs_100g,
    protein_100g = excluded.protein_100g,
    fat_100g = excluded.fat_100g,
    portion_unit = excluded.portion_unit,
    portion_grams = excluded.portion_grams,
    quantity = excluded.quantity,
    updated_at = excluded.updated_at,
    deleted_at = excluded.deleted_at
  where t.updated_at < excluded.updated_at;
end;
$$;

revoke execute on function public.push_changes(jsonb) from public, anon;
grant execute on function public.push_changes(jsonb) to authenticated;
