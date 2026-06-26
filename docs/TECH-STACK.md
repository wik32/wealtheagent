# FinanzApp — Tech Stack Proposal v0.1 (for sign-off)

Optimized for: solo/small team speed, EU data residency, premium custom UI,
mobile-first with a web path, and a document-extraction pipeline as the core
technical asset.

## Recommendation at a glance

| Layer | Pick | Why |
|---|---|---|
| Mobile app | **Expo (React Native) + TypeScript** | One codebase for iOS+Android, fast iteration, first-class camera/document libs, later web via React Native Web or shared logic with Next.js |
| Backend & DB | **Supabase, EU region (Frankfurt)** | Postgres + Auth (Apple/Google) + file storage + row-level security out of the box; EU data residency; replaceable later |
| Doc extraction | **Claude via AWS Bedrock eu-central-1** (alt: Mistral, Paris) | Best-in-class document understanding with structured JSON output; Bedrock keeps all data in Frankfurt; Mistral OCR as EU-native fallback/second opinion |
| Voice | On-device STT (iOS Speech / Android SpeechRecognizer) + EU-hosted LLM for the conversation | Audio never leaves the device as audio; only text goes to the EU endpoint |
| Web (later) | Next.js sharing the TS domain layer | Same types, same API |

## Mobile framework: Expo vs. Flutter
- **Expo/React Native (recommended):** TypeScript end to end (shared types
  with backend and extraction schemas), huge ecosystem, `expo-camera` +
  document-scanner modules, `expo-local-authentication` for biometrics, OTA
  updates for fast MVP iteration. Web story via RN Web is adequate for later.
- **Flutter (alternative):** better raw rendering control for fully custom
  premium UI, single binary feel. Costs us Dart (no type sharing with
  backend) and a slightly slower hiring pool in DE web talent.
- Decision driver: type sharing across app/backend/extraction schemas is
  worth more to us than Flutter's rendering edge.

## Backend: Supabase (EU) vs. custom (NestJS on Hetzner/AWS)
- **Supabase EU (recommended for MVP):** auth with Apple/Google built in,
  Postgres with row-level security (every user sees only their rows —
  important for a finance app), encrypted file storage for documents,
  edge functions for the extraction pipeline. Fastest path; it is plain
  Postgres underneath, so no hard lock-in.
- **Custom NestJS (later option):** migrate when we need complex pipeline
  orchestration or BaFin-stage audit requirements.

## Document extraction pipeline (the core asset)
1. Capture: camera with edge detection / PDF import; multi-page support.
2. Preprocess: deskew, compress; store original encrypted in EU bucket.
3. Extract: vision-capable LLM with a strict JSON schema per contract type
   (provider, type, premium + interval, coverage, dates, contract no.;
   investments: funds, allocation). Schema versioned in repo.
4. Confidence: per-field confidence; low-confidence fields highlighted in
   the confirm-and-correct screen.
5. Feedback: user corrections stored → ground-truth dataset (our moat).

## EU/DSGVO posture
- All storage and inference in EU regions (Frankfurt/Paris). DPAs with all
  processors. No US-region calls.
- Documents encrypted at rest; deletion = real deletion (DSGVO Art. 17).
- On-device processing explored post-MVP (e.g. on-device OCR pre-pass so
  only text, not images, leaves the phone).

## Security (banking-grade)
- Sign in with Apple / Google + optional TOTP 2FA.
- Biometric app lock, short session timeout, screenshot blocking on
  sensitive screens, certificate pinning, no sensitive data in app switcher.

## Open items for sign-off
1. Expo vs. Flutter — final call.
2. Bedrock/Claude vs. Mistral as primary extraction model (can A/B both
   behind one interface; recommended).
3. Supabase EU acceptable for MVP? (Yes from my side.)
