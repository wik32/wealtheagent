# ADR-004: Bounded Context Design — FinanzApp Stage 1

**Status:** Accepted
**Date:** 2026-06-26
**Author:** Hera (nw-ddd-architect)
**Scope:** Domain model — bounded contexts, aggregate design, context mapping

---

## Context

FinanzApp is a single-developer iOS app in Stage 1 ("messen, nicht empfehlen"). The domain is narrow but precise: ingest user-owned financial documents, extract contract data, detect duplicates and coverage gaps against a 22-category catalog, and present factual observations. No recommendations, no advice, no third-party data.

The application architecture (MVVM + Protocol-Typed Ports, CloudKit) is settled in ADR-001 through ADR-003. This ADR defines the domain model layer that those architecture decisions serve.

The key domain design questions are:
1. Where are the bounded context boundaries?
2. What are the aggregate roots and their invariants?
3. How do the contexts integrate?
4. Does Event Sourcing or CQRS add value here?

---

## Decision

### Four Bounded Contexts

#### 1. Catalog Context (Supporting subdomain)

The 22-category catalog is a read-only knowledge base. It defines what financial contracts exist in Germany, what fields each category captures, and what evaluation criteria apply. It is authored by FinanzApp, not by users.

**Boundary justification:** The catalog never changes based on user actions. It has no user-specific state. It is independently versioned (schemaVersion field in catalog.json). It is logically upstream of all other contexts.

**Implementation shape:** `BundleCatalogProvider` (implements `CatalogProvider` protocol). Synchronous read from app bundle. No persistence needed.

#### 2. Contract Context (Core subdomain)

The user's financial contract portfolio. Two aggregates:
- `PendingContract` — OCR output, mutable, awaiting user review
- `Contract` — user-confirmed, stable, persisted to CloudKit

**Boundary justification:** User data has a fundamentally different lifecycle and security model from catalog data. Mixing them would couple schema evolution to catalog evolution. The "confirmed vs pending" state machine is a contract lifecycle concern, not a catalog concern.

**Implementation shape:** `ContractRepository` protocol, implemented by `CloudKitContractRepository`. Domain types in `Domain/` with zero framework imports.

#### 3. Insights Context (Core subdomain)

Derives factual observations from `[Contract] + Catalog`. Pure function. No storage. No mutation.

**Boundary justification:** Observations are computed, not stored. They have no independent lifecycle. They cannot modify contracts or the catalog. Separating this context prevents coupling the observation logic to storage concerns, and makes it fully unit-testable as a pure function.

**Implementation shape:** `InsightsEngine` — `static func insights(contracts: [Contract], catalog: Catalog) -> FinInsights`. No protocol needed (pure function, no I/O to mock).

**Language constraint (domain invariant):** The word "Empfehlung" (recommendation) is banned from this context's ubiquitous language. All outputs are `Beobachtung` (observation) or `Messung` (measurement). This is enforced in code naming and in SwiftLint custom rules on string literals in the `Insights/` module.

#### 4. Identity Context (Generic subdomain)

User profile: onboarding state, household configuration (size, partner, children), language preference. Auth is delegated to Apple Sign-In via iCloud — no auth logic lives here.

**Boundary justification:** Identity data contextualizes insights (household size affects which gap observations are surfaced) but has no business logic of its own. It is configuration, not behaviour. Keeping it separate prevents polluting the Contract or Insights context with user preference concerns.

**Implementation shape:** `UserProfile` struct, persisted as a singleton `UserProfile` CKRecord in the same CloudKit zone as contracts (see ADR-002).

---

### Context Map

```
Catalog (upstream, OHS)
    ├──→ Contract (conformist — categoryKey is Catalog's key)
    └──→ Insights (conformist — level-1 category list drives gap detection)

Contract (upstream, Customer-Supplier)
    └──→ Insights (downstream — InsightsEngine consumes [Contract] snapshot)

Identity (upstream, Customer-Supplier)
    └──→ Insights (downstream — HouseholdProfile contextualises gap rules)

Apple Sign-In (external)
    └──→ Identity (conformist — iCloud account = user identity, no translation)
```

No Anti-Corruption Layer is needed between any internal contexts. The Contract Context adopts Catalog's category key schema directly (the keys like `"privathaftpflicht"` become `Contract.categoryKey`). The Insights Context adopts Contract's type directly. All three contexts are owned by the same solo developer, so model negotiation is zero-cost.

An ACL would be needed if:
- A third-party insurance comparison API were integrated (Stage 3 candidate). Its model of "product" and "coverage" would need translation into FinanzApp's `ContractCategory` and `Criterion` model.
- A financial broker API were integrated. Its concept of "contract" (as a product recommendation) is categorically different from FinanzApp's concept of "contract" (as a document the user already has).

---

### Aggregate Design Rationale

**Why PendingContract and Contract are separate aggregates, not one aggregate with a status flag:**

The Flutter reference implementation uses a single `ExtractionResult` with `ExtractionStatus.needsReview | ok | rejected`. This creates a runtime branch: code that works with confirmed contracts must guard against accidentally receiving an unreviewed one.

In Swift, two types encode this structurally:
- `PendingContract` — carries `rawOCRText`, `fieldConfidences`, mutable fields. Can be edited. Cannot be read by InsightsEngine.
- `Contract` — has no OCR evidence fields. Cannot be "un-confirmed." Is the only type InsightsEngine accepts.

The invariant "InsightsEngine never sees an unreviewed contract" is enforced by the type system, not by a runtime guard. This eliminates a class of bugs at design time.

**Why ContractFields is a value object, not a child entity:**

Fields on a contract (provider name, premium amount, coverage sum) do not have independent identity. A coverage sum of €5,000,000 on one contract and €5,000,000 on another are the same value — they are not "the same field." Fields exist only in the context of their contract and change atomically with it. Value object is correct.

**Why criteria are not a child entity on Contract:**

`[String: Bool]` — criterion key to met/not-met — is a simple map. No invariant requires transactional consistency within the criteria collection itself. A map of value-typed booleans satisfies Vernon's Rule 2 (small aggregates) and Rule 1 (only true invariants inside the boundary).

---

### ES/CQRS Decision

**Event Sourcing: Rejected for Stage 1.**

The domain does not warrant ES:
- No audit trail requirement from legal review (Stage 1). The GDPR right-to-erasure is simpler to implement with record deletion than with event log tombstoning.
- No temporal queries ("what was the premium on date X?"). Users track current contracts.
- No concurrency conflicts. One iCloud account, one active device at a time in typical use.
- CloudKit's `modificationDate` satisfies the lightweight "when was this changed?" need.

Trade-off acknowledged: if a future legal audit requirement mandates a full history of contract changes per user, ES would simplify that implementation. The `ContractEdited` domain event (in-process) provides an anchor for adding an event store in a future stage without redesigning the aggregate.

**CQRS: Present in lightweight form, no additional infrastructure needed.**

The read-side projection (`InsightsEngine`) is already a pure function separate from the write-side (`ContractRepository`). This is the essential CQRS separation without the operational overhead of separate read/write databases. No explicit CQRS infrastructure (command bus, event bus, separate read store) is introduced.

---

## Consequences

**Positive:**
- Domain types in `Domain/` are pure Swift structs with zero framework imports. Fully testable with no mocking.
- Type-safe boundary between PendingContract and Contract eliminates the `needsReview` runtime branch.
- InsightsEngine is a pure function: fastest possible unit test, no flakiness, no async complexity.
- Context boundaries are clear enough that a second developer can be handed any single context with a one-page brief.

**Negative / trade-offs:**
- Two aggregate types (PendingContract + Contract) require two CloudKit record types and an atomic transition operation. This adds ~30 lines of CloudKit code compared to a single type with a status field. This cost is paid once and does not compound.
- The Insights Context computes observations on every call — no caching in Stage 1. For 10–30 contracts this is sub-millisecond; no optimisation needed.

**Constraints this decision places on implementers (software-crafter):**
- `InsightsEngine` must accept `[Contract]` only — never `[PendingContract]`. The type signature enforces this.
- `ContractRepository.confirm(_:corrected:)` must be a single atomic CloudKit operation (delete PendingContract + save Contract in one `CKModifyRecordsOperation`). See ADR-002.
- Domain types must not import CloudKit, Vision, SwiftUI, or Foundation beyond `Date`, `UUID`, `Decimal`. SwiftLint rules enforce this.
- The string "Empfehlung" must not appear in any `Insights/` module file as a user-visible string. SwiftLint custom rule to be added.

---

## Alternatives Considered

**Single "FinancialRecord" context for everything:** Rejected. Mixing catalog knowledge (read-only, FinanzApp-authored) with user contract data (mutable, user-owned) in one context would couple catalog schema evolution to user data migration. A catalog update would force a user data migration — unacceptable.

**Three contexts (merge Identity into Contract):** The `UserProfile` data could live on `ContractRepository` as a profile-specific record. This works technically (it's in the same CloudKit zone). Rejected because the onboarding flow, language preference, and household data have a fundamentally different read/write pattern from contracts. Household size is read once per Insights computation; contracts are read on every view load. Keeping them conceptually separate simplifies future changes to either.

**Event Sourcing for Contract Context:** Evaluated. The append-only nature of CloudKit records (via modificationDate) provides weak audit semantics. Full ES would require a separate event log record type, projection rebuilds, and event versioning — costs that don't pay off until Stage 3 at earliest.
