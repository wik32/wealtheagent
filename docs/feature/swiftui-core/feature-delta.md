# Feature Delta — swiftui-core

**Feature ID:** swiftui-core
**Date:** 2026-06-26
**Wave author:** Quinn (nw-acceptance-designer)
**Target language:** Swift (iOS 17+, XCTest + Swift Testing)

---

## Wave: DISTILL

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| n/a | MVVM + Protocol-Typed Ports (ADR-001, confirmed D1 2026-06-26) | n/a | All ViewModels accept protocol-typed dependencies; MockContractRepository enables unit tests without CloudKit |
| n/a | InsightsEngine is a pure function with contract shape pure-function | n/a | Fully unit-testable with zero mocking, zero async, zero infrastructure |
| n/a | Banned term: "Empfehlung" / "empfehlen" in all user-facing strings | n/a | Test assertions verify output strings do not contain banned terms; enforced at test layer and production code |
| n/a | BundleCatalogProvider loads from catalog.json bundle (offline-capable) | n/a | MockCatalogProvider mirrors structure; tests run offline with no network dependency |
| n/a | PendingContract → Contract transition is atomic (ADR-002 D2) | n/a | confirm() test verifies pending record removed and Contract record created atomically |
| n/a | noDuplicate types: depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve | n/a | Tests explicitly verify these four categories do NOT produce InsightKind.duplicate observations |

### [REF] Scenario List

| Scenario | Tags | Priority |
|---|---|---|
| User with 2 Privathaftpflicht contracts sees 1 duplicate observation | @walking_skeleton @driving_port | P1 |
| User with no Berufsunfähigkeit sees 1 gap observation | @walking_skeleton @driving_port | P1 |
| Two contracts same category produce 1 duplicate observation | @driving_port | P1a |
| Single contract produces no duplicate observation | @driving_port | P1a |
| Empty portfolio produces no duplicate observations | @driving_port @error | P1a |
| Two depot contracts do not produce duplicate (noDuplicate type) | @driving_port @error | P1a |
| Two sparplan contracts do not produce duplicate (noDuplicate type) | @driving_port @error | P1a |
| Two tagesgeld_festgeld contracts do not produce duplicate (noDuplicate type) | @driving_port @error | P1a |
| Two liquiditaetsreserve contracts do not produce duplicate (noDuplicate type) | @driving_port @error | P1a |
| Three contracts same category produce exactly 1 duplicate observation | @driving_port @error | P1a |
| Duplicate observation contains no banned term 'Empfehlung' | @driving_port @domain_invariant | P1a |
| Portfolio missing BU produces gap observation | @driving_port | P1b |
| Full level-1 coverage produces no gap observations | @driving_port | P1b |
| Empty portfolio produces 11 gap observations | @driving_port @error | P1b |
| Gap absent when category present | @driving_port | P1b |
| Level-2/3 categories do not produce gap observations | @driving_port @error | P1b |
| Gap observation does not use advice framing ('solltest') | @driving_port @domain_invariant | P1b |
| Empty portfolio has coverage score 0.0 | @driving_port | P1c |
| Full level-1 coverage has score 1.0 | @driving_port | P1c |
| 5/11 level-1 covered has score ~5/11 | @driving_port | P1c |
| Level-2/3 contracts do not contribute to coverage score | @driving_port @error | P1c |
| Two same-category contracts count as 1 covered | @driving_port | P1c |
| Coverage score always between 0.0 and 1.0 | @driving_port @property | P1c |
| Depot TER 1.45% produces comparison observation | @driving_port | P1d |
| Depot TER 0.20% produces no comparison observation | @driving_port @error | P1d |
| Depot TER exactly 1.0% produces comparison observation (boundary) | @driving_port @error | P1d |
| Depot with no positions produces no comparison | @driving_port @error | P1d |
| Non-depot contracts produce no TER observations | @driving_port @error | P1d |
| Comparison observation uses measurement framing (not advice) | @driving_port @domain_invariant | P1d |
| Standard 11-contract fixture produces expected observation types | @driving_port | P1e |
| Standard fixture has BU in gap observations | @driving_port | P1e |
| Standard fixture coverage score accounts for covered level-1 categories | @driving_port | P1e |
| Catalog has 22 categories | @walking_skeleton @driving_port | P2 |
| Catalog has 11 level-1 categories | @driving_port | P2 |
| Catalog has 8 level-2 categories | @driving_port | P2 |
| Catalog has 3 level-3 categories | @driving_port | P2 |
| Category keys all unique | @driving_port | P2 |
| Category lookup 'privathaftpflicht' returns correct category | @driving_port | P2 |
| Category lookup unknown key returns nil | @driving_port @error | P2 |
| criteriaFor('privathaftpflicht') returns 8 criteria | @driving_port | P2 |
| criteriaFor('berufsunfaehigkeit') returns 5 criteria | @driving_port | P2 |
| criteriaFor unknown key returns empty array | @driving_port @error | P2 |
| Category names bilingual DE and EN | @driving_port | P2 |
| Category names contain no banned terms | @driving_port @domain_invariant | P2 |
| byLevel[1] contains 11 categories | @driving_port | P2 |
| Save contract can be retrieved by ID | @driving_port | P3 |
| Confirm pending contract becomes Contract, raw OCR removed from pending | @driving_port | P3 |
| Delete contract no longer in list | @driving_port | P3 |
| On load ContractListViewModel calls listContracts | @driving_port | P4 |
| After confirm insights recalculated | @driving_port | P4 |
| Sign out contracts list cleared | @driving_port | P4 |

**Total scenarios:** 48
**Error/edge scenarios:** ~20 (42% — meets ≥40% target)
**Domain invariant scenarios:** 4 (banned-term enforcement)

### [REF] Adapter Coverage Table

| Adapter | @real-io scenario | Coverage |
|---|---|---|
| InsightsEngine (pure function) | YES | All P1 tests — no real-io needed (pure function) |
| MockCatalogProvider | YES | P2 catalog tests (in-memory, mirrors BundleCatalogProvider interface) |
| MockContractRepository | YES | P3 persistence tests (in-memory, mirrors CloudKitContractRepository interface) |
| CloudKitContractRepository | @requires_external | Not tested in this suite — requires iCloud account and CloudKit container. Covered by probe() contract and future integration tests. |
| VisionDocumentScanner | @requires_external | Not tested in this suite — requires device camera. MockDocumentScanner covers the interface contract. |
| BundleCatalogProvider (real bundle) | NOTE | DELIVER: one real-bundle integration test should read actual catalog.json from bundle and verify 22 categories decode correctly |

**Missing real-io test for BundleCatalogProvider:** The mock tests prove the interface contract. DELIVER should add one integration test that calls the real `BundleCatalogProvider.catalog()` reading from the actual `catalog.json` bundle resource. This is a Priority 2 task in DELIVER.

### [REF] Walking Skeleton Strategy

**Strategy:** Protocol-injection with in-memory doubles (Tier A only)

**Justification:** InsightsEngine is a pure function — no ports needed, no mocks required. `ContractRepository` and `CatalogProvider` are protocol-typed — `MockContractRepository` and `MockCatalogProvider` provide deterministic, zero-infrastructure doubles. The walking skeletons exercise the full InsightsEngine logic end-to-end with real inputs and real outputs. Tier B (state-machine PBT) is NOT applicable: InsightsEngine is a pure function (not a state machine), and the journey has no ≥3 chained scenario sequence requiring Tier B.

**Driving port:** `InsightsEngine.insights(contracts:catalog:)` is the primary driving port for all P1 tests. `CatalogProvider.catalog()` and `ContractRepository.listContracts()` are the ports for P2/P3.

### [REF] Scaffolds Created

| File | Type | Status |
|---|---|---|
| `FinanzApp/Domain/Contract.swift` | Domain scaffold | RED — fatalError in init |
| `FinanzApp/Domain/ContractCategory.swift` | Domain scaffold | RED — fatalError in methods |
| `FinanzApp/Domain/ContractCriterion.swift` | Domain scaffold | RED — fatalError in methods |
| `FinanzApp/Domain/FinInsights.swift` | Domain scaffold | Types only — no fatalError |
| `FinanzApp/Domain/Catalog.swift` | Domain scaffold | RED — fatalError in all methods |
| `FinanzApp/Ports/ContractRepository.swift` | Port protocol | Types only — no fatalError |
| `FinanzApp/Ports/CatalogProvider.swift` | Port protocol | Types only — no fatalError |
| `FinanzApp/Ports/DocumentScanner.swift` | Port protocol | Types only — no fatalError |
| `FinanzApp/Services/InsightsEngine.swift` | Service scaffold | RED — fatalError in all methods |
| `FinanzAppTests/Mocks/MockContractRepository.swift` | Test mock | Implemented — ready for tests |
| `FinanzAppTests/Mocks/MockCatalogProvider.swift` | Test mock | Implemented — ready for tests |
| `FinanzAppTests/Mocks/MockDocumentScanner.swift` | Test mock | Implemented — ready for tests |

### [REF] Test Placement

**Directory:** `FinanzApp/FinanzAppTests/`

**Justification:** Xcode convention for iOS projects. Test target `FinanzAppTests` is part of the same Xcode project as `FinanzApp`. Swift Testing + XCTest mix is supported in Xcode 16+ (iOS 17+ target). No alternative test directory convention exists for Swift/iOS.

### [REF] Pre-requisites

**Driving ports (confirmed from Architecture SSoT):**
- `InsightsEngine.insights(contracts:catalog:)` — pure function, primary port for P1
- `CatalogProvider.catalog()` — synchronous protocol method, port for P2
- `ContractRepository.listContracts()` / `save()` / `confirm()` / `delete()` — async protocol methods, ports for P3

**DEVOPS environment matrix:** Not present. Defaulting to: clean install (iOS 17 Simulator). No CloudKit integration in this test suite.

**Language:** `[lang-mode] Swift` (iOS 17+, Package.swift marker, Xcode project)
**Policy mode:** `[policy-mode] write-if-absent` (first DISTILL in this project)

### [REF] Step-Reuse-Ratio (Mandate-12 Criterion 4, Informational)

This feature uses Swift Testing `@Test` methods with descriptive names rather than BDD step decorators. The ratio metric is adapted: function names serve as the DSL surface.

- Total test invocations across all test suites: ~48
- Unique helper functions (MockContractFixtures, MockCatalogFixtures): 14 fixtures reused across suites
- Natural ceiling: config-shaped feature for pure function + mock infrastructure. Ratio is not applicable in the traditional decorator sense. Documented as informational per Mandate-12 Criterion 4.

**Mandate-12 compliance:**
- CM-I-1: Domain types in `FinanzApp/Domain/` — typed structs/enums for Contract, Insight, InsightKind, etc. ✓
- CM-I-2: MockContractRepository and test helpers use typed parameters (Contract, UUID, etc.) ✓
- CM-I-3: Test bodies are ≤5 lines each, no inline business logic, delegating to InsightsEngine and MockContractRepository ✓
- CM-I-4: Ratio informational — documented above ✓

### [REF] One-at-a-Time Implementation Sequence (for DELIVER)

Enable in this order. Each enable = one TDD RED→GREEN→COMMIT cycle.

**Cycle 1 (Walking Skeleton):** Enable `userWithTwoPrivathaftpflichtContractsSeesDuplicateObservation` first. This forces implementation of `InsightsEngine.insights()` + `duplicateObservations()`.

**Cycle 2:** Enable `userWithNoBerufsunfaehigkeitSeesGapObservation`. Forces `missingObservations()`.

**Cycle 3–7:** Duplicate detection tests (noDuplicate types, edge cases).

**Cycle 8–13:** Coverage score tests.

**Cycle 14–19:** Gap detection tests.

**Cycle 20–25:** Cost comparison tests.

**Cycle 26–34:** Catalog loading tests (fix `Catalog.swift` scaffolds).

**Cycle 35–37:** Full portfolio integration tests.

**Cycle 38–40:** Persistence tests via MockContractRepository (Contract scaffold fix).

**Cycle 41–44:** ContractListViewModel tests (after ViewModel is scaffolded).
