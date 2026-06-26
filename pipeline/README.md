# FinanzApp — Document Extraction Pipeline (Sprint 1)

Reads German insurance policies, depot statements, and pension documents
(photo, scan, or PDF) into validated, structured JSON with per-field
confidence. Standalone TypeScript pipeline — no app or backend wiring yet.
See `../docs/SPEC.md` for the product context.

## Architecture

```
file (.pdf/.jpg/.png/…)
  → ingest        (PDF passthrough ≤4MB; photos: rotate/resize/normalize via sharp)
  → classify      (small model decides contract type, or rejects non-contracts)
  → extract       (large model fills the type-specific schema + per-field confidence)
  → validate      (Zod schema; invalid fields are nulled and flagged needsReview)
  → ExtractionResult { status: ok | needs_review | rejected, contract, fields }
```

- **Schemas** (`src/schemas/`) are the product contract — versioned
  (`schemaVersion`), one Zod schema per contract type, discriminated union
  `ExtractedContract`. The Flutter app and Supabase tables will derive from
  these.
- **Providers** (`src/providers/`) are pluggable behind one interface:
  - `mock` — fixture-backed, used for tests/eval without API access
  - `claude` — Claude via AWS Bedrock, **EU-regional endpoints** (data stays
    in the EU): classification on Haiku 4.5, extraction on Opus 4.6
    (`eu.anthropic.…` model IDs, region `eu-central-1`)
  - `mistral` — EU-native alternative, stub in sprint 1
- **Confidence**: fields below 0.8 confidence or failing validation are
  flagged `needsReview` — this drives the app's confirm-and-correct screen.

## Usage

```sh
npm install
npm test                 # unit tests
npm run make-samples     # generate synthetic German sample docs (PDF + photo)
npm run eval             # field-accuracy report (default: mock provider)
npm run eval -- --provider claude
npm run extract -- eval/samples/haftpflicht_huk.pdf --provider claude
```

## Prerequisites for the Claude provider

1. AWS account with Bedrock model access granted for Anthropic models in an
   EU region (console → Bedrock → Model access).
2. Copy `.env.example` to `.env` and fill in `AWS_ACCESS_KEY_ID` /
   `AWS_SECRET_ACCESS_KEY` (`.env` is git-ignored and loaded automatically).
   `~/.aws/credentials` or `AWS_BEARER_TOKEN_BEDROCK` work too.
3. Run the preflight check — it pings both EU models with a tiny request and
   prints targeted diagnostics if anything is missing:

   ```sh
   npm run check-claude
   ```

Optional overrides in `.env`: `AWS_REGION` (default `eu-central-1`),
`FINANZAPP_CLASSIFY_MODEL`, `FINANZAPP_EXTRACT_MODEL`.

EU note: the adapter pins **regional (`eu.`) cross-region inference IDs**, so
inference stays in EU regions (10% pricing premium vs. global routing —
that's the DSGVO trade we chose deliberately).

## Test data

`eval/samples/` holds synthetic documents (no personal data): six contract
types as clean PDFs and as photographed variants (skewed, compressed,
tinted), plus one non-contract letter as a negative case. Ground truth lives
in `eval/expected/`. Drop additional (anonymized!) real documents into
`eval/samples/` with a matching expected JSON and the harness picks them up.

## Results

| Provider | Date | Field accuracy | Notes |
|---|---|---|---|
| mock | 2026-06-12 | 120/120 (100%) | Harness self-test incl. negative rejection |
| claude (Bedrock EU) | — | pending | Awaiting AWS credentials |

Targets (from the sprint plan): ≥95% on clean PDFs, ≥85% on photographed
variants, 100% rejection of non-contract documents.

## Sprint 1 status

- ✅ Schemas, ingest, orchestrator, confidence, CLI, eval harness, samples
- ✅ Bedrock Claude adapter (type-checked; live run pending AWS credentials)
- ⏳ Mistral adapter is a stub (`ProviderUnavailableError`)
- Next sprints: Flutter app skeleton (5 screens) → Supabase wiring
