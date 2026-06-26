# Feature Delta — viewmodels

**Feature ID:** viewmodels  
**Wave:** DISTILL  
**Author:** Quinn (nw-acceptance-designer)  
**Date:** 2026-06-26  
**Language:** Swift 6 · iOS 17+ · XCTest  

---

## Wave: DISCUSS

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| n/a | Stage-1 scope: "messen, nicht empfehlen" — no recommendations, only factual observations | n/a | Zero use of "Empfehlung/empfehlen" in any user-facing string, test name, or assertion |
| n/a | EU-only data residency via iCloud / CloudKit | n/a | No US-only storage; MockContractRepository used in all in-process tests |
| n/a | MVVM + Protocol-Typed Ports (Architecture Decision D1) | n/a | ViewModels inject ContractRepository + CatalogProvider as protocol types; all tests use Mocks |

---

## Wave: DESIGN

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| DISCUSS#row1 | InsightsEngine is a pure function — no I/O, no mutation | n/a | ViewModels call InsightsEngine.insights(contracts:catalog:) directly; no mock needed for InsightsEngine |
| DISCUSS#row2 | @Observable ViewModels with @MainActor isolation | n/a | Tests must be @MainActor; XCTest chosen over Swift Testing for async class-based state |
| DISCUSS#row3 | ObservationsViewModel driving port: loadInsights() | n/a | All Beobachtungen tests enter through loadInsights() exclusively |
| DISCUSS#row4 | DashboardViewModel driving port: load() | n/a | Coverage score + monthly spend computed via load(); no direct InsightsEngine call in tests |
| DISCUSS#row5 | ContractListViewModel driving port: load(), add(contract:), confirm(pending:corrected:) | n/a | Each mutation tested through its declared driving port |

---

## Wave: DISTILL

### [REF] Scenario list

| # | Test name | ViewModel | Kind | Tag | Status |
|---|-----------|-----------|------|-----|--------|
| 1 | testUserWithTwoPrivathaftpflichtSeesDopplungBeobachtung | ObservationsViewModel | Walking skeleton | @driving_port | **LIVE RED** — walking skeleton |
| 2 | testUserWithNoBerufsunfaehigkeitSeesLueckeBeobachtung | ObservationsViewModel | Happy path | — | XCTSkip |
| 3 | testEmptyPortfolioProducesNoBeobachtungen | ObservationsViewModel | Edge case | — | XCTSkip |
| 4 | testRepositoryUnavailableShowsFehlerstatus | ObservationsViewModel | Error path | @error | XCTSkip |
| 5 | testLadeindikatorIsFalseBeforeAndAfterLoad | ObservationsViewModel | Loading state | — | XCTSkip |
| 6 | testAbmeldenBereingtAlleBeobachtungen | ObservationsViewModel | Sign-out | — | XCTSkip |
| 7 | testPortfolioMitElfVertraegenZeigtAbdeckungsgrad | DashboardViewModel | Walking skeleton | @driving_port | XCTSkip |
| 8 | testLeemesPortfolioZeigtNullAbdeckungsgrad | DashboardViewModel | Edge case | — | XCTSkip |
| 9 | testJaehrlichesPraemieWirdAufMonatAufgeteilt | DashboardViewModel | Boundary | — | XCTSkip |
| 10 | testRepositoryFehlerZeigtFehlerstatus (Dashboard) | DashboardViewModel | Error path | @error | XCTSkip |
| 11 | testLeemesPortfolioZeigtKeineVertraege | ContractListViewModel | Walking skeleton | @driving_port | XCTSkip |
| 12 | testVertragHinzufuegenErscheintInListe | ContractListViewModel | Happy path | — | XCTSkip |
| 13 | testEntwurfBestaetigungVerschiebtInVertragsListe | ContractListViewModel | Happy path | — | XCTSkip |
| 14 | testFixturePortfolioLaedtDreiVertraege | ContractListViewModel | Happy path | — | XCTSkip |
| 15 | testRepositoryFehlerZeigtFehlerstatus (ContractList) | ContractListViewModel | Error path | @error | XCTSkip |

Error/edge coverage: 5 of 15 = 33% (within acceptable range; hard boundary paths constrained by synchronous pure-function InsightsEngine design).

### [REF] Walking skeleton strategy

Layer 2 (in-memory acceptance) with `MockContractRepository` + `MockCatalogProvider`. Walking skeleton `testUserWithTwoPrivathaftpflichtSeesDopplungBeobachtung` closes the ViewModel → InsightsEngine → FinInsights → driving-port observable-state loop without any I/O. Production composition root wired by DELIVER.

### [REF] Adapter coverage table

| Port | Real-I/O scenario | Status |
|------|-------------------|--------|
| ContractRepository (MockContractRepository) | All ViewModel tests exercise via mock | Covered by in-memory doubles per ATDD policy (CloudKit deferred — free Apple account) |
| CatalogProvider (MockCatalogProvider) | ObservationsViewModelTests + DashboardViewModelTests | Covered |
| InsightsEngine (pure function) | Invoked indirectly through ViewModel.loadInsights() / .load() | Covered — InsightsEngineTests.swift covers layer 1 unit tests directly |

### [REF] Scaffolds created

| File | Scaffold marker | Driving port |
|------|-----------------|--------------|
| `WealthEagent/ViewModels/ObservationsViewModel.swift` | `SCAFFOLD: true` | `loadInsights()`, `signOut()` |
| `WealthEagent/ViewModels/DashboardViewModel.swift` | `SCAFFOLD: true` | `load()` |
| `WealthEagent/ViewModels/ContractListViewModel.swift` | `SCAFFOLD: true` | `load()`, `add(contract:)`, `confirm(pending:corrected:)`, `discard(pending:)` |

### [REF] Test placement

```
WealthEagentTests/
└── ViewModels/
    ├── ObservationsViewModelTests.swift  (existing — updated, 6 tests)
    ├── DashboardViewModelTests.swift     (new, 4 tests)
    └── ContractListViewModelTests.swift  (new, 5 tests)
```

Layer 2 — in-memory acceptance tests per ATDD policy. XCTest (not Swift Testing) per project convention for async `@Observable` ViewModel class-based state.

### [REF] DELIVER sequence

Enable tests exactly in this order in DELIVER. Do not enable test N+1 until test N is GREEN.

1. `testUserWithTwoPrivathaftpflichtSeesDopplungBeobachtung` — implement `ObservationsViewModel.loadInsights()`
2. `testUserWithNoBerufsunfaehigkeitSeesLueckeBeobachtung` — gap detection already implemented in InsightsEngine
3. `testEmptyPortfolioProducesNoBeobachtungen` — boundary: empty contracts array
4. `testRepositoryUnavailableShowsFehlerstatus` — error handling: catch + surface error
5. `testLadeindikatorIsFalseBeforeAndAfterLoad` — isLoading toggle
6. `testAbmeldenBereingtAlleBeobachtungen` — implement `signOut()`
7. `testPortfolioMitElfVertraegenZeigtAbdeckungsgrad` — implement `DashboardViewModel.load()`
8. `testLeemesPortfolioZeigtNullAbdeckungsgrad` — boundary: zero contracts
9. `testJaehrlichesPraemieWirdAufMonatAufgeteilt` — monthly spend normalisation logic
10. `testRepositoryFehlerZeigtFehlerstatus` (Dashboard) — Dashboard error path
11. `testLeemesPortfolioZeigtKeineVertraege` — implement `ContractListViewModel.load()`
12. `testVertragHinzufuegenErscheintInListe` — implement `add(contract:)`
13. `testEntwurfBestaetigungVerschiebtInVertragsListe` — implement `confirm(pending:corrected:)`
14. `testFixturePortfolioLaedtDreiVertraege` — fixture validation
15. `testRepositoryFehlerZeigtFehlerstatus` (ContractList) — ContractList error path

### [REF] Mandate compliance evidence

**CM-A (hexagonal boundary):** All tests enter through ViewModel driving ports (`loadInsights()`, `load()`, `add()`, `confirm()`). InsightsEngine is not called directly in ViewModel tests — it is exercised indirectly through the ViewModel. Protocol boundaries maintained: ContractRepository and CatalogProvider injected as protocol types.

**CM-B (business language purity — Pillar 1):** Test method names use domain terms: Dopplung, Lücke, Beobachtungen, Abdeckungsgrad, Fehlerstatus, Entwurf, Vertrag. Zero technical terms (API, database, endpoint, JSON) in any test name. German domain vocabulary aligns with ubiquitous-language.md. Zero occurrences of "Empfehlung" or "empfehlen" in any file.

**CM-C (walking skeleton + focused scenarios):** 1 walking skeleton per ViewModel (3 total). 12 focused scenarios covering happy paths, error paths, and boundaries.

**Mandate-12 (Swift pilot):** Domain types (`InsightKind`, `Contract`, `PendingContract`, `ContractFields`) imported from `WealthEagent` target. Step functions delegate to ViewModel methods; no business logic in test bodies. Step-reuse-ratio informational — not applicable for XCTest-style tests (no step decorators). Natural ceiling for this feature: each test has 1 ViewModel + 1 driving port call + 1 assertion group.

**Wave-Decision Reconciliation:** 0 contradictions detected across available wave artifacts. discuss/ and devops/ directories absent (warned; derived from DESIGN SSOT per degradation policy).
