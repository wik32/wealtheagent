-- FinanzApp — Initialschema (Sprint 3)
-- Abgeleitet aus pipeline/src/schemas (schemaVersion 0.1.0, siehe schemas/*.schema.json).
-- Grundprinzip: Row-Level-Security auf allen Tabellen — jeder Nutzer sieht
-- ausschließlich seine eigenen Zeilen. Kein Zugriff ohne Authentifizierung.

-- =====================================================================
-- Profile (minimal — progressive Anreicherung, siehe SPEC: so wenig wie möglich abfragen)
-- =====================================================================
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  display_name text,
  birth_year integer check (birth_year between 1900 and 2030),
  family_status text check (family_status in ('single', 'paar', 'familie')),
  profession text,
  children integer check (children between 0 and 20),
  locale text not null default 'de'
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select using (auth.uid() = id);
create policy "profiles_insert_own" on public.profiles
  for insert with check (auth.uid() = id);
create policy "profiles_update_own" on public.profiles
  for update using (auth.uid() = id);
create policy "profiles_delete_own" on public.profiles
  for delete using (auth.uid() = id);

-- =====================================================================
-- Hochgeladene Dokumente (Metadaten; Datei liegt im Storage-Bucket "documents")
-- =====================================================================
create table public.documents (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  storage_path text not null,
  original_filename text,
  status text not null default 'uploaded'
    check (status in ('uploaded', 'processing', 'extracted', 'rejected', 'failed')),
  rejection_reason text
);

create index documents_user_idx on public.documents (user_id, created_at desc);

alter table public.documents enable row level security;

create policy "documents_select_own" on public.documents
  for select using (auth.uid() = user_id);
create policy "documents_insert_own" on public.documents
  for insert with check (auth.uid() = user_id);
create policy "documents_update_own" on public.documents
  for update using (auth.uid() = user_id);
create policy "documents_delete_own" on public.documents
  for delete using (auth.uid() = user_id);

-- =====================================================================
-- Extrahierte Verträge (data = ExtractionResult.contract, fields = Konfidenzen)
-- =====================================================================
create table public.contracts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  document_id uuid references public.documents (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  schema_version text not null,
  contract_type text not null check (contract_type in (
    'privathaftpflicht', 'berufsunfaehigkeit', 'krankenversicherung',
    'lebensversicherung', 'depot', 'altersvorsorge'
  )),
  status text not null default 'needs_review'
    check (status in ('ok', 'needs_review', 'confirmed')),
  data jsonb not null,
  fields jsonb not null default '{}'::jsonb,
  user_confirmed_at timestamptz
);

create index contracts_user_idx on public.contracts (user_id, created_at desc);
create index contracts_type_idx on public.contracts (user_id, contract_type);

alter table public.contracts enable row level security;

create policy "contracts_select_own" on public.contracts
  for select using (auth.uid() = user_id);
create policy "contracts_insert_own" on public.contracts
  for insert with check (auth.uid() = user_id);
create policy "contracts_update_own" on public.contracts
  for update using (auth.uid() = user_id);
create policy "contracts_delete_own" on public.contracts
  for delete using (auth.uid() = user_id);

create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create trigger contracts_touch_updated_at
  before update on public.contracts
  for each row execute function public.touch_updated_at();

-- =====================================================================
-- Storage: privater Bucket, Pfadkonvention {user_id}/{document_id}.{ext}
-- =====================================================================
insert into storage.buckets (id, name, public)
values ('documents', 'documents', false)
on conflict (id) do nothing;

create policy "storage_documents_select_own" on storage.objects
  for select using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "storage_documents_insert_own" on storage.objects
  for insert with check (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
create policy "storage_documents_delete_own" on storage.objects
  for delete using (
    bucket_id = 'documents'
    and (storage.foldername(name))[1] = auth.uid()::text
  );
