-- FinanzApp — Leistungskriterien je Vertragsart (Bedingungs-/Leistungsanalyse).
-- Getrennt von den Erfassungsfeldern: beschreibt, WELCHE inhaltlichen Merkmale
-- ein Vertrag dieser Art haben kann (z. B. Forderungsausfalldeckung). Ob ein
-- konkreter Vertrag sie enthält, steht je Vertrag in contracts.data['criteria'].
-- Öffentlich lesbar (App-Content), Schreibrecht nur Service-Role.

create table public.contract_criteria (
  id uuid primary key default gen_random_uuid(),
  category_key text not null
    references public.contract_categories (key) on update cascade on delete cascade,
  criterion_key text not null,
  label_de text not null,
  label_en text not null,
  sort_order integer not null default 0,
  active boolean not null default true,
  unique (category_key, criterion_key)
);

create index contract_criteria_category_idx
  on public.contract_criteria (category_key, sort_order);

alter table public.contract_criteria enable row level security;

create policy "criteria_public_read" on public.contract_criteria
  for select using (true);
