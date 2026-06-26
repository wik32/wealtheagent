-- FinanzApp — Katalog (DIN 77230 / Defino)
-- App-Content (kein Nutzerdatum): Vertragsarten, Formularfelder und
-- Wissensartikel. Diese Tabellen sind ÖFFENTLICH LESBAR (RLS: select using true),
-- aber nur die Service-Role darf schreiben (keine insert/update/delete-Policy).
-- Damit lassen sich Kategorien, Felder und Texte ohne App-Update pflegen.

-- =====================================================================
-- Vertragsarten / Bedarfsfelder (nach den 3 Defino-Stufen)
-- =====================================================================
create table public.contract_categories (
  key text primary key,
  defino_level smallint not null check (defino_level between 1 and 3),
  defino_field text,
  name_de text not null,
  name_en text not null,
  icon text not null default 'shield',
  sort_order integer not null default 0,
  purpose_de text,
  purpose_en text,
  relevance_de text,
  relevance_en text,
  watch_de text,
  watch_en text,
  active boolean not null default true
);

alter table public.contract_categories enable row level security;

create policy "categories_public_read" on public.contract_categories
  for select using (true);

-- =====================================================================
-- Formularfelder je Vertragsart (treibt den generischen Erfassungs-Dialog)
-- =====================================================================
create table public.contract_fields (
  id uuid primary key default gen_random_uuid(),
  category_key text not null
    references public.contract_categories (key) on update cascade on delete cascade,
  field_key text not null,
  kind text not null
    check (kind in ('text', 'date', 'money', 'premium', 'int', 'bool', 'choice')),
  label_de text not null,
  label_en text not null,
  sort_order integer not null default 0,
  required boolean not null default false,
  -- für kind='choice': [{"value": "...", "label_de": "...", "label_en": "..."}]
  choices jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  unique (category_key, field_key)
);

create index contract_fields_category_idx
  on public.contract_fields (category_key, sort_order);

alter table public.contract_fields enable row level security;

create policy "fields_public_read" on public.contract_fields
  for select using (true);

-- =====================================================================
-- Wissens-Hub (neutrale Erklärungen, keine Empfehlungen — Stage-1-Leitplanke)
-- =====================================================================
create table public.knowledge_articles (
  slug text primary key,
  category_de text not null,
  category_en text not null,
  title_de text not null,
  title_en text not null,
  -- Absätze als JSON-Array von Strings
  body_de jsonb not null default '[]'::jsonb,
  body_en jsonb not null default '[]'::jsonb,
  contract_key text
    references public.contract_categories (key) on update cascade on delete set null,
  sort_order integer not null default 0,
  active boolean not null default true
);

alter table public.knowledge_articles enable row level security;

create policy "articles_public_read" on public.knowledge_articles
  for select using (true);

-- =====================================================================
-- contracts.contract_type: starre CHECK-Liste lösen. Der Fremdschlüssel auf
-- contract_categories wird am ENDE von 0003 gesetzt — erst dann existieren die
-- Kategorien, auf die bestehende contracts-Zeilen verweisen.
-- =====================================================================
alter table public.contracts
  drop constraint if exists contracts_contract_type_check;
