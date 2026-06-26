# FinanzApp MVP — Spec v0.1

## Product
Commission-independent financial transparency app (B2C, Germany). Stage 1 of a
5-stage regulatory roadmap: **measure, don't prescribe.** The user uploads
their contracts, AI consolidates them, and the app shows their complete
financial picture with neutral, factual observations.

Guiding analogy: a health check that measures but does not prescribe.

## Regulatory roadmap
1. **Stage 1 (MVP):** Pure analysis & transparency tool. No recommendations.
2. **Stage 2:** Generic financial education.
3. **Stage 3:** Lead referral to licensed brokers (legal review at boundary).
4. **Stage 4:** Liability umbrella (Haftungsdach).
5. **Stage 5:** Own BaFin license (§34d GewO).

## Core loop (MVP)
1. **Onboarding** — quick & minimal but guided: tap through ~3 screens OR a
   short voice conversation filling the same profile. Minimal data upfront.
2. **Upload** — photo, scan, or PDF; 2–20 contracts; bulk-friendly; add anytime.
3. **Extraction** — AI reads provider, type, costs, benefits/coverage, terms;
   for investments: funds, allocation. Pre-filled confirm-and-correct screen.
4. **Dashboard** — multi-level scoring: financial security, insurance
   coverage, monthly spend, estimated pension projection.
5. **Observations (Beobachtungen)** — categorized factual findings, drillable
   to contract level, including "not on file" gaps. NEVER recommendations.
6. **Knowledge Hub** — neutral educational content linked from observations.

## The regulatory copy constraint (applies to every screen)
- Findings are framed as neutral facts: "Two liability policies on file."
- Never prescriptive: no "you should", no product or provider suggestions.
- Scores are measurements with descriptive labels ("coverage gaps: 2"),
  never prescriptive ("improve this").
- Legal copy review of all user-facing text before launch.

## Data decisions
- **Hosting:** EU-only end to end. On-device processing where feasible
  (post-MVP optimization; EU-hosted LLM extraction first).
- **Extraction set (MVP):** costs + benefits per contract, payment interval,
  provider, contract type, terms/dates, contract number; investments: funds,
  portfolio, allocation. Deep tariff details: later.
- **Profile:** progressive — ask only what can't be inferred from documents.
- **Auth:** Apple/Google sign-in; banking-grade: biometric unlock, short
  sessions, screenshot protection on sensitive views, 2FA. Single-user only.

## Design decisions
- **Mobile-first** (camera is the killer input), web later.
- **German UI**, English switchable in settings.
- Voice: friendly, modern, educational tone.
- Light + dark mode, premium feel. Palette: warm cream, deep green,
  black/tan accents. Distinctive — not another blue fintech app.
- Voice as alternative interaction layer (onboarding conversation first).
- Radical simplicity in UX.

## Out of MVP scope
Product recommendations, brokerage/closure, household accounts, bank account
connections (PSD2), Stage 2+ features.

## Build order
1. Document extraction pipeline (highest technical risk)
2. Dashboard + scoring (highest user value)
3. Observations engine
4. Onboarding (incl. voice), Knowledge Hub
