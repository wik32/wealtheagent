# FinanzApp — Supabase Backend

Projekt: `https://ncldijjkxoshshunkkmu.supabase.co` (Region eu-west-1, Irland — EU).

## Struktur

- `migrations/0001_init.sql` — Tabellen `profiles`, `documents`, `contracts`
  (JSONB nach `../schemas/`), Row-Level-Security auf allem, privater
  Storage-Bucket `documents`. **Bereits eingespielt (2026-06-12).**
- `functions/extract-document/` — Edge Function: lädt ein hochgeladenes
  Dokument (mit Nutzer-JWT, RLS aktiv), extrahiert via Claude auf AWS
  Bedrock (EU-regionale Modelle) und schreibt das Ergebnis in `contracts`.

## Einmalige Einrichtung im Dashboard

1. **Authentication → Sign In / Up → „Allow anonymous sign-ins" aktivieren**
   (die App meldet Nutzer beim ersten Start anonym an; Apple/Google folgt
   als Konto-Upgrade).

## Edge Function deployen

Voraussetzungen: [Supabase CLI](https://supabase.com/docs/guides/cli) und
ein Access Token (Dashboard → Account → Access Tokens).

```sh
brew install supabase/tap/supabase
supabase login                       # öffnet Browser
cd <repo-root>
supabase link --project-ref ncldijjkxoshshunkkmu

# AWS-Zugangsdaten als Function-Secrets (gleiche wie pipeline/.env):
supabase secrets set AWS_ACCESS_KEY_ID=… AWS_SECRET_ACCESS_KEY=… AWS_REGION=eu-central-1

supabase functions deploy extract-document
```

Test (mit angemeldetem Nutzer-JWT):

```sh
curl -X POST "https://ncldijjkxoshshunkkmu.supabase.co/functions/v1/extract-document" \
  -H "Authorization: Bearer <user-jwt>" -H "Content-Type: application/json" \
  -d '{"document_id": "<uuid aus documents>"}'
```

## Sicherheitsmodell

- Kein Service-Role-Key im Client oder in der Function — alles läuft mit dem
  JWT des Nutzers, RLS erzwingt Datentrennung auf Zeilen- und Storage-Ebene.
- AWS-Schlüssel existieren nur als Function-Secrets (serverseitig) und in
  `pipeline/.env` (lokal, git-ignoriert).
- Dokumente liegen im privaten Bucket unter `{user_id}/…`; Zugriff nur auf
  den eigenen Ordner.
