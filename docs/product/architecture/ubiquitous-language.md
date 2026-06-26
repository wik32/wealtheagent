# Ubiquitous Language — FinanzApp

**Scope:** Stage 1 domain model
**Date:** 2026-06-26
**Author:** Hera (nw-ddd-architect)

This glossary defines the terms used consistently across domain model, code (Swift identifiers), and user-facing strings (via `Localizable.xcstrings`). Terms are scoped per bounded context where they differ. The language is bilingual: Swift identifiers use EN, user-facing strings use DE (with EN translations).

**Constraint:** The word "Empfehlung" (recommendation) and the verb "empfehlen" are banned from all user-facing strings in Stage 1. Any observation about the user's portfolio is a factual `Beobachtung`, not advice. This is a legal and product constraint, not a style preference.

---

## Cross-Context Terms

Terms used consistently across all four bounded contexts.

| EN (code identifier) | DE (user-facing) | Definition | Notes |
|---|---|---|---|
| `CategoryKey` | — | String identifier for a contract category in the catalog (e.g. `"privathaftpflicht"`). Used as a foreign key from Contract to Catalog. | Strong typedef over `String`. Never a raw string in domain logic. |
| `NeedsLevel` | Stufe (1 / 2 / 3) | The tier in the recognised needs hierarchy: 1 = existential protection, 2 = living standard and provision, 3 = wealth building. | In code: `ContractCategory.needsLevel: Int`. In UI: "Stufe 1", "Stufe 2", "Stufe 3". Never "Defino-Stufe". |
| `Provider` | Anbieter | The company or institution that issued a contract (insurer, bank, fund provider). | Domain type: `String`. May be a value object in a later stage. |
| `schemaVersion` | — | Version string on all persisted records. Enables `ContractMigrator` on schema change. | Always `"1.0"` in Stage 1. Not user-facing. |

---

## Catalog Context

| EN (code identifier) | DE (user-facing) | Definition |
|---|---|---|
| `Catalog` | Katalog | The complete collection of contract categories, field specifications, and knowledge articles. Loaded from `catalog.json` at startup. |
| `ContractCategory` | Vertragsart | One of the 22 types of insurance or financial products tracked by FinanzApp. Identified by `CategoryKey`. |
| `ContractFieldSpec` | Feld | A typed, labelled field definition within a category (e.g. "Deckungssumme / Coverage amount" on Privathaftpflicht). |
| `FieldKind` | — | The data type of a field: `.text`, `.date`, `.money`, `.premium`, `.intNum`, `.boolean`, `.choice`. Not user-facing. |
| `ContractFieldChoice` | Auswahl | One option in a choice field (e.g. "Single / Einzelperson" for `insuredPersons`). |
| `ContractCriterion` | Leistungskriterium | A named quality criterion for comparing contracts of the same category (e.g. "Forderungsausfalldeckung"). |
| `KnowledgeArticle` | Wissensartikel | Educational content about a contract category or topic. Linked from observations. |
| `needsLevel` | Stufe | The tier (1, 2, or 3) of a category in the recognised needs hierarchy. |
| `purpose` | Wozu dient dieser Vertrag? | Short explanation of what a category covers. |
| `relevance` | Warum ist das relevant? | Why this category matters in the context of a recognised needs hierarchy. Never mentions DIN 77230 or Defino by name. |
| `watch` | Worauf achten? | What the user should look for when reviewing contracts of this type. |

**Language constraints for Catalog Context:**
- Never write "DIN 77230" or "Defino" in any `KnowledgeArticle.body` or `ContractCategory.relevance` field.
- Use "anerkannte Bedarfssystematik" (DE) / "recognised needs hierarchy" (EN) as the approved reference to the underlying methodology.

---

## Contract Context

| EN (code identifier) | DE (user-facing) | Definition |
|---|---|---|
| `PendingContract` | Entwurf | An OCR-extracted contract record awaiting user review. Not yet confirmed. Not visible to InsightsEngine. |
| `Contract` | Vertrag | A user-confirmed financial contract record. Stored in CloudKit. The canonical user portfolio unit. |
| `ContractFields` | Vertragsdaten | The typed field values for a specific contract (e.g. `coverageSum: Money`, `insuredPersons: "familie"`). A value object. |
| `FieldConfidence` | Erkennungssicherheit | Per-field confidence score from OCR extraction. Present on `PendingContract`, discarded after `ContractConfirmed`. |
| `OCRResult` | — | The raw output of Apple Vision: text blocks with confidence scores. Input to `ContractParser`. Never persisted directly. |
| `TextBlock` | — | One recognised text span from OCR: text string + confidence + optional bounding box. |
| `Premium` | Beitrag | The periodic payment for an insurance or savings contract: an amount (Money) and an interval (PremiumInterval). |
| `PremiumInterval` | Zahlungsweise | How often the premium is paid: `.monthly` (monatlich), `.quarterly` (vierteljaehrlich), `.semiannual` (halbjaehrlich), `.annual` (jaehrlich), `.oneOff` (einmalig). |
| `Money` | Betrag | A monetary value: `amount: Decimal` (EUR only in Stage 1) + `currency: Currency`. |
| `confirmedAt` | Erfasst am | The timestamp when the user confirmed a PendingContract into a Contract. |
| `extractedAt` | Erkannt am | The timestamp of OCR completion for a PendingContract. |
| `ocrConfidence` | Gesamtsicherheit | Mean confidence of all OCR text blocks for a PendingContract. 0.0–1.0. |
| `ConfirmPendingContract` | Vertrag bestätigen | The user command that transitions a PendingContract to a Contract. Atomic CloudKit operation. |
| `EditContract` | Vertrag bearbeiten | The user command to correct fields on a confirmed Contract. |
| `DeleteContract` | Vertrag löschen | The user command to permanently remove a Contract from the portfolio. |

**What "Vertrag" means in this context vs. German law:**
In FinanzApp, "Vertrag" refers to a record the user has photographed and entered into the app — it represents evidence of a real-world contract. It is not a legally binding object in the app. This distinction matters for disclaimers.

**The pending/confirmed boundary:**
- A `PendingContract` is ephemeral: it exists only until the user confirms or discards it.
- A `Contract` is permanent (until the user deletes it): it represents a fact the user has asserted about their portfolio.
- This distinction must be preserved in UI copy: pending contracts are "Entwürfe" (drafts), confirmed contracts are "Verträge" (contracts).

---

## Insights Context

| EN (code identifier) | DE (user-facing) | Definition |
|---|---|---|
| `FinInsights` | Auswertung | The complete set of computed observations and measurements for a user's portfolio. Produced by `InsightsEngine`. |
| `Insight` | Beobachtung | A single factual observation derived from the contract portfolio. One of: duplicate, coverage gap, or comparison. |
| `InsightKind` | Art der Beobachtung | The category of an observation: `.duplicate` (Dopplung), `.coverageGap` (Lücke), `.comparison` (Kennzahl). |
| `DuplicateObservation` | Dopplung | An observation that the user has more than one confirmed contract of the same category. Factual — not a recommendation to cancel. |
| `CoverageGapObservation` | Lücke | An observation that the user has no confirmed contract in a level-1 category. Factual — not a recommendation to buy. |
| `ComparisonObservation` | Kennzahl | An observation about a measurable value in the portfolio (e.g. fund cost TER, coverage amount). |
| `InsightsEngine` | — | The pure function `insights(contracts: [Contract], catalog: Catalog) -> FinInsights`. No I/O. No mutation. Not user-facing. |
| `CoverageScore` | Abdeckungsgrad | The percentage of level-1 catalog categories for which the user has at least one confirmed contract. A measurement, not a score in the sense of a credit rating. |
| `monthlySpend` | Monatliche Gesamtbeiträge | The sum of all monthly premium equivalents across all confirmed insurance contracts. A measurement. |
| `estimatedMonthlyPension` | Prognostizierte Monatsrente | The sum of `expectedMonthlyPension` fields across all `altersvorsorge` contracts. A measurement from user-provided data — not a projection by FinanzApp. |

**Banned terms in this context:**

| Banned (DE) | Banned (EN) | Use instead (DE) | Use instead (EN) |
|---|---|---|---|
| Empfehlung | Recommendation | Beobachtung | Observation |
| empfehlen | recommend | messen, feststellen | measure, observe |
| sollte | should | — | — |
| raten | advise | — | — |
| besser | better (comparatively) | im Vergleich: | measured against: |

**Observation framing rules (enforced in UI copy review):**
- Coverage gaps use the frame: "In deinen Unterlagen ist keine [Vertragsart] vorhanden." Not: "Du solltest eine [Vertragsart] abschließen."
- Duplicates use the frame: "Du hast [N] [Vertragsart]-Policen erfasst." Not: "Eine davon ist überflüssig."
- Comparisons use the frame: "Laufende Kosten [X] % p.a. — breite Index-ETFs liegen im Schnitt bei etwa 0,2 % p.a." Not: "Das ist zu teuer."

---

## Identity Context

| EN (code identifier) | DE (user-facing) | Definition |
|---|---|---|
| `UserProfile` | Profil | The singleton record representing the app user's preferences and household configuration. Not a financial profile. |
| `OnboardingState` | — | Whether the user has completed onboarding. `Bool`. |
| `LanguagePreference` | Sprache | `.system` (Systemsprache), `.de` (Deutsch), `.en` (English). Controls all localised strings via `Locale`. |
| `householdSize` | Haushaltsgröße | Number of people in the household. Used to contextualise which level-1 categories are relevant (e.g. `risikolebensversicherung` for households with dependants). |
| `hasPartner` | Mit Partner | Whether the household includes a partner. |
| `hasChildren` | Mit Kindern | Whether the household includes children. |
| `CompleteOnboarding` | Einrichtung abschließen | The command that marks onboarding as complete and saves the household profile. |

---

## Domain Events (Cross-Context Reference)

| Event (EN) | Raised in | German description |
|---|---|---|
| `PendingContractCreated` | Contract Context | OCR-Erkennung abgeschlossen, Entwurf gespeichert |
| `PendingContractFieldsCorrected` | Contract Context | Nutzer hat Felder im Entwurf korrigiert |
| `ContractConfirmed` | Contract Context | Nutzer hat Entwurf als Vertrag bestätigt |
| `ContractEdited` | Contract Context | Nutzer hat bestätigten Vertrag bearbeitet |
| `ContractDeleted` | Contract Context | Nutzer hat Vertrag gelöscht |
| `OnboardingCompleted` | Identity Context | Nutzer hat Einrichtung abgeschlossen |

---

## Terms Intentionally Excluded

The following terms are in common use in the German insurance industry but are deliberately **not** part of FinanzApp's ubiquitous language because they carry implicit recommendation framing or reference proprietary methodologies.

| Excluded term | Why excluded | Approved substitute |
|---|---|---|
| Defino | Proprietary brand name for the needs hierarchy methodology | "anerkannte Bedarfssystematik" |
| DIN 77230 | Standards body norm — cannot reproduce normtext; brand association | "anerkannte Bedarfssystematik" |
| Empfehlung / empfehlen | Implies advice / regulated financial recommendation | Beobachtung, Messung, feststellen |
| Vergleich (as noun for comparison product) | Implies product comparison / broker activity | Kennzahl, Gegenüberstellung (measured values only) |
| Abschluss (als Handlungsaufforderung) | Implies soliciting insurance purchase | Not used in any context |
| Lücke (als Handlungsaufforderung) | "Lücke" as a fact is fine; "Lücke schließen" implies action | "Lücke" as observation only; never "schließ die Lücke" |
