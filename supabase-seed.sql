-- KajuWEB – initial training-library placeholders
--
-- These records are unpublished on purpose. Replace their titles and
-- descriptions with the club's official curriculum before publishing.

with belt_levels(belt) as (
  values ('white'), ('yellow'), ('orange'), ('purple'),
         ('blue'), ('green'), ('brown'), ('black')
), categories(category) as (
  values ('kicks'), ('punches'), ('knife'),
         ('stick'), ('grappling'), ('combinations')
), slots(slot) as (
  values (1::smallint), (2::smallint)
)
insert into public.techniques (
  belt, category, slot, slug,
  title_es, title_en, title_ca,
  description_es, description_en, description_ca,
  published, sort_order
)
select
  belt_levels.belt,
  categories.category,
  slots.slot,
  belt_levels.belt || '-' || categories.category || '-' || slots.slot,
  'Pendiente de definir · ' || initcap(categories.category) || ' ' || slots.slot,
  'To be defined · ' || initcap(categories.category) || ' ' || slots.slot,
  'Pendent de definir · ' || initcap(categories.category) || ' ' || slots.slot,
  'Sustituir por la descripción oficial de la técnica.',
  'Replace with the official technique description.',
  'Substitueix-ho per la descripció oficial de la tècnica.',
  false,
  slots.slot
from belt_levels
cross join categories
cross join slots
on conflict (slug) do nothing;
