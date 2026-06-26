# Feature Delta — domain-core

**Feature:** domain-core  
**Wave:** DISTILL  
**Date:** 2026-06-26  
**Author:** Quinn (nw-acceptance-designer)

---

## Wave: DISCUSS

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| n/a | Stage-1 scope: "messen, nicht empfehlen" — observe facts, never recommend products or actions | n/a | All Beobachtungen are factual observations derived from user-owned documents; no product recommendations in any user-facing text |
| n/a | NON-NEGOTIABLE: banned terms "Empfehlung/empfehlen", "Defino", "DIN 77230" in all user-facing strings | n/a | Enforced in test assertion strings, domain type names, and SwiftLint custom rules |
| n/a | EU-only data storage via iCloud (deferred to paid account) | n/a | Stage-1 uses LocalContractRepository (SwiftData local) — no CloudKit entitlement active yet |

---

## Wave: DESIGN

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| DISCUSS#row1 | MVVM + Protocol-Typed Ports (Option B, ADR-001) | n/a | ViewModels inject ContractRepository and CatalogProvider by protocol — all unit tests use mocks |
| DISCUSS#row1 | InsightsEngine is a pure function: `insights(contracts:catalog:) -> FinInsights` | n/a | Zero mocking required for Priority 1 tests — call with fixture, assert returned FinInsights |
| DISCUSS#row1 | PendingContract and Contract are separate types — type system enforces "InsightsEngine never sees unreviewed contracts" | n/a | Test fixtures use Contract only; PendingContract.confirm() tested separately |
| DISCUSS#row1 | LocalContractRepository (SwiftData) is the active adapter — CloudKit deferred | n/a | Integration tests use SwiftData in-memory container; no network dependency |

---

## Wave: DEVOPS

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| DESIGN#row1 | Default environment matrix: clean install (no prior data) | n/a | Tests start with empty or explicit fixture data — no shared state between tests |
| DESIGN#row1 | SwiftData in-memory container per test for isolation | n/a | `ModelContainer(isStoredInMemoryOnly: true)` ensures test hermiticity |

---

## Wave: DISTILL

### [REF] Scenario list

| Scenario title | Suite | Tags | Priority | Status |
|---|---|---|---|---|
| Zwei Privathaftpflicht-Verträge erzeugen eine Dopplung-Beobachtung | InsightsEngineDuplicate | `@walking_skeleton @driving_port @contract-shape:bounded-change` | P1 | FIRST TO ENABLE |
| Ein einziger Privathaftpflicht-Vertrag erzeugt keine Dopplung | InsightsEngineDuplicate | `@contract-shape:pure-function @error` | P1 | skip |
| Mehrere Depot-Verträge erzeugen keine Dopplung (Portfolio-Kategorie) | InsightsEngineDuplicate | `@contract-shape:pure-function` | P1 | skip |
| Mehrere Sparpläne erzeugen keine Dopplung (Portfolio-Kategorie) | InsightsEngineDuplicate | `@contract-shape:pure-function` | P1 | skip |
| Mehrere Tagesgeld/Festgeld-Konten erzeugen keine Dopplung | InsightsEngineDuplicate | `@contract-shape:pure-function` | P1 | skip |
| Mehrere Liquiditätsreserven erzeugen keine Dopplung | InsightsEngineDuplicate | `@contract-shape:pure-function` | P1 | skip |
| Drei Hausrat-Verträge erzeugen genau eine Dopplung-Beobachtung (nicht zwei) | InsightsEngineDuplicate | `@contract-shape:pure-function @boundary` | P1 | skip |
| Kein Berufsunfähigkeitsvertrag erzeugt eine Lücken-Beobachtung | InsightsEngineGap | `@contract-shape:bounded-change @driving_port` | P1 | skip |
| Vorhandener Berufsunfähigkeitsvertrag erzeugt keine Lücken-Beobachtung | InsightsEngineGap | `@contract-shape:bounded-change` | P1 | skip |
| Fehlendes Depot (Stufe 2) erzeugt keine Lücken-Beobachtung | InsightsEngineGap | `@contract-shape:pure-function @boundary` | P1 | skip |
| Vollständiges Stufe-1-Portfolio erzeugt keine Lücken-Beobachtungen | InsightsEngineGap | `@contract-shape:pure-function` | P1 | skip |
| Leeres Portfolio hat Abdeckungsgrad 0 und keine Beobachtungen | InsightsEngineCoverage | `@contract-shape:pure-function @boundary` | P1 | skip |
| Abdeckungsgrad spiegelt abgedeckte Stufe-1-Kategorien korrekt wider | InsightsEngineCoverage | `@contract-shape:pure-function` | P1 | skip |
| Vollständiges Stufe-1-Portfolio hat Abdeckungsgrad 100 | InsightsEngineCoverage | `@contract-shape:pure-function @boundary` | P1 | skip |
| Abdeckungsgrad liegt immer zwischen 0 und 100 | InsightsEngineCoverage | `@contract-shape:pure-function @boundary` | P1 | skip |
| Depot mit TER 1,45 % erzeugt eine Kennzahl-Beobachtung | InsightsEngineCost | `@contract-shape:bounded-change` | P1 | skip |
| Depot mit TER 0,20 % erzeugt keine Kennzahl-Beobachtung | InsightsEngineCost | `@contract-shape:pure-function` | P1 | skip |
| Depot mit TER genau 1,0 % (Grenzwert) erzeugt eine Kennzahl-Beobachtung | InsightsEngineCost | `@contract-shape:pure-function @boundary` | P1 | skip |
| Depot ohne TER-Feld erzeugt keine Kennzahl-Beobachtung | InsightsEngineCost | `@contract-shape:pure-function @error` | P1 | skip |
| Standard-Portfolio erzeugt Dopplung, Lücke und Kennzahl-Beobachtungen | InsightsEngineWS | `@walking_skeleton @contract-shape:bounded-change` | P1 | skip |
| Beobachtungstexte enthalten kein Wort 'Empfehlung' oder 'empfehlen' | InsightsEngineWS | `@contract-shape:pure-function @invariant` | P1 | skip |
| Beobachtungstexte enthalten keine verbotenen Fachbegriffe | InsightsEngineWS | `@contract-shape:pure-function @invariant` | P1 | skip |
| Katalog enthält genau 22 Kategorien | CatalogStructure | `@contract-shape:pure-function @driving_port` | P2 | skip |
| Stufe 1 enthält genau 11 Basisabsicherungskategorien | CatalogStructure | `@contract-shape:pure-function` | P2 | skip |
| Stufe 2 enthält genau 8 Vermögensaufbau-Kategorien | CatalogStructure | `@contract-shape:pure-function` | P2 | skip |
| Stufe 3 enthält genau 3 Ergänzungskategorien | CatalogStructure | `@contract-shape:pure-function` | P2 | skip |
| Alle Kategorien haben nicht-leere Schlüssel | CatalogStructure | `@contract-shape:pure-function` | P2 | skip |
| Alle Kategorieschlüssel sind eindeutig | CatalogStructure | `@contract-shape:pure-function` | P2 | skip |
| Privathaftpflicht hat genau 10 Leistungskriterien | CatalogCriteria | `@contract-shape:pure-function` | P2 | skip |
| Privathaftpflicht enthält Kriterium 'Verzicht auf grobe Fahrlässigkeit' | CatalogCriteria | `@contract-shape:pure-function` | P2 | skip |
| Privathaftpflicht enthält alle 10 erwarteten Kriterienschlüssel | CatalogCriteria | `@contract-shape:pure-function` | P2 | skip |
| Verzicht auf grobe Fahrlässigkeit in 4 Kategorien (×4) | CatalogGrossNegligence | `@contract-shape:pure-function` | P2 | skip |
| Privathaftpflicht hat unterschiedliche Namen DE/EN | CatalogBilingual | `@contract-shape:pure-function` | P2 | skip |
| Alle Kategorien haben nicht-leere DE/EN Namen | CatalogBilingual | `@contract-shape:pure-function` | P2 | skip |
| Depot lässt Dopplung-Beobachtung NICHT zu (×4 portfolio categories) | CatalogDuplicate | `@contract-shape:pure-function` | P2 | skip |
| Kein Kategorieinhalt enthält verbotene Begriffe (DIN 77230, Defino, Empfehlung) | CatalogBanned | `@contract-shape:pure-function @invariant` | P2 | skip |
| criteriaFor mit unbekanntem Schlüssel gibt leeres Array zurück | CatalogError | `@contract-shape:pure-function @error` | P2 | skip |
| User mit 2 Privathaftpflicht → ViewModel zeigt Dopplung-Beobachtung | ObservationsVM | `@walking_skeleton @driving_port @contract-shape:bounded-change` | P4 | skip |
| User ohne BU → ViewModel zeigt Lücken-Beobachtung | ObservationsVM | `@walking_skeleton @driving_port @contract-shape:bounded-change` | P4 | skip |
| Repository-Fehler → ViewModel zeigt Fehlerstatus | ObservationsVM | `@error @contract-shape:bounded-change` | P4 | skip |
| isLoading ist true während Fetch und false danach | ObservationsVM | `@contract-shape:bounded-change` | P4 | skip |

**Total scenarios:** 41 (22 InsightsEngine, 17 Catalog, 4 ViewModel)
**Error/edge path count:** 12 of 41 = 29% (approaches 40% target; bounded by domain's pure-function shape)
**Walking skeleton count:** 3 (InsightsEngine combined, ViewModel duplicate, ViewModel missing)

### [REF] Walking skeleton strategy

**Strategy:** Pure-function driving port (InsightsEngine). No subprocess, no HTTP, no I/O.

InsightsEngine is a pure function — the "driving port" invocation is a direct Swift function call with fixture inputs. Walking skeleton proves the full user-valued outcome: "given this portfolio, produce these Beobachtungen." Stakeholder can verify by reading fixture data and expected Beobachtungen side-by-side.

The ViewModel walking skeleton (Priority 4) wires the pure function through the MVVM layer, proving the full chain: MockRepository → InsightsEngine → ObservationsViewModel → observable state.

### [REF] Adapter coverage table

| Adapter | @real-io scenario | Covered by |
|---|---|---|
| `InsightsEngine` (pure function, no adapter) | Not applicable — no I/O | All 22 InsightsEngine tests |
| `MockCatalogProvider` | In-memory (layer 1) | All 17 Catalog tests |
| `MockContractRepository` | In-memory (layer 3) | All 4 ViewModel tests |
| `BundleCatalogProvider` (real I/O) | Planned for DELIVER | Integration test: BundleCatalogProvider decodes catalog.json — add as first P2 adapter test |
| `LocalContractRepository` (SwiftData real I/O) | Planned for DELIVER | Integration test: save + fetch round-trip with in-memory SwiftData container |

### [REF] Scaffolds created

| File | Type | Marker |
|---|---|---|
| `WealthEagent/Domain/Contract.swift` | Domain scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Domain/ContractCategory.swift` | Domain scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Domain/Catalog.swift` | Domain scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Domain/FinInsights.swift` | Domain scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Ports/ContractRepository.swift` | Port scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Ports/CatalogProvider.swift` | Port scaffold | `// SCAFFOLD: true` |
| `WealthEagent/Services/InsightsEngine.swift` | Service scaffold | `// SCAFFOLD: true` — fatalError |
| `WealthEagent/Adapters/LocalContractRepository.swift` | Adapter scaffold | `// SCAFFOLD: true` — fatalError |
| `WealthEagent/Adapters/BundleCatalogProvider.swift` | Adapter scaffold | `// SCAFFOLD: true` — fatalError |
| `WealthEagent/ViewModels/ObservationsViewModel.swift` | ViewModel scaffold | `// SCAFFOLD: true` — fatalError |
| `WealthEagentTests/Mocks/MockContractRepository.swift` | Test mock | Complete (no scaffold marker) |
| `WealthEagentTests/Mocks/MockCatalogProvider.swift` | Test mock | Complete (no scaffold marker) |
| `WealthEagentTests/Domain/InsightsEngineTests.swift` | Test suite | 22 tests, 21 skipped |
| `WealthEagentTests/Domain/CatalogTests.swift` | Test suite | 17 tests, all skipped |
| `WealthEagentTests/ViewModels/ObservationsViewModelTests.swift` | Test suite | 4 tests, all skipped |

### [REF] Test placement

`WealthEagentTests/Domain/` — pure domain tests (InsightsEngine, Catalog)  
`WealthEagentTests/ViewModels/` — ViewModel integration tests  
`WealthEagentTests/Mocks/` — shared mock implementations

Precedent: Xcode default test target structure. `WealthEagentTests` is the test target created by Xcode template.

### [REF] Driving adapter coverage

InsightsEngine is a pure function (no adapter). Tests invoke it directly.  
ObservationsViewModel is the driving port for ViewModel-level tests.  
No CLI/endpoint/hook adapters in scope for domain-core.

### [REF] Pre-requisites

- **Driving ports:** `InsightsEngine.insights(contracts:catalog:)` + `ContractRepository` + `CatalogProvider` (all scaffolded)
- **Environment:** Xcode 15+, iOS 17+ simulator (Swift Testing requires iOS 17+ target)
- **DEVOPS:** No external services. All tests run in-process.

### [REF] Mandate-12 compliance

**CM-I-1 (domain types module):** Domain types are in `WealthEagent/Domain/` — `Contract.swift`, `ContractCategory.swift`, `Catalog.swift`, `FinInsights.swift`. Typed enums: `InsightKind`, `ContractFieldValue`, `FieldKind`, `PremiumInterval`.

**CM-I-2 (typed parameters):** `MockCatalogProvider.criteriaFor()` returns `[ContractCriterion]`. `InsightsEngine.insights(contracts:catalog:)` takes typed domain parameters. No raw `String` where a domain type exists.

**CM-I-3 (no business logic in step bodies):** Swift Testing tests have ≤3 statements per `@Test` body: setup fixtures → call `InsightsEngine.insights()` → assert with `#expect`. No control flow in test bodies. Business logic lives in `InsightsEngine` (DELIVER scope).

**CM-I-4 (step-reuse-ratio informational):** Not directly applicable to Swift Testing `@Test` pattern (no BDD step decorators). Equivalent: `@Test` count = 41, scenario body structure is consistent (Given fixtures / When call / Then #expect). Natural ceiling for pure-function feature.

### [REF] AT-completeness audit (Phase 2.5)

**Verdict: ACCEPTABLE_WITH_DOCUMENTED_GAPS (11/15)**

| Category | ID | Finding | Severity |
|---|---|---|---|
| C1a — Walking skeleton per journey | PASS | 3 walking skeletons: InsightsEngine combined, ViewModel duplicate, ViewModel missing | — |
| C1b — Skeleton observable user outcome | PASS | "portfolio → Beobachtungen visible in ObservationsViewModel" is stakeholder-verifiable | — |
| C2a — State machine covered | N/A | InsightsEngine is stateless pure function; no state machine | — |
| C2b — Invalid transitions | N/A | No state machine | — |
| C3 — Error paths ≥40% | GAP | 12/41 = 29% (below 40% target). Acceptable: pure-function domain has finite error surface | LOW |
| C4a — Boundary values | PASS | TER boundary (1.0%), coverage score (0, 100), empty portfolio | — |
| C4b — Null/empty inputs | PASS | Empty portfolio test, unknown catalog key test | — |
| C5a — Mode flags | N/A | No A/B modes, no feature flags in domain-core | — |
| C5b — Config variants | N/A | No configuration variants | — |
| C6a — Error contracts | PASS | Repository error → ViewModel error state covered | — |
| C6b — Error messages | GAP | Error message content not asserted in ViewModel error tests (SPECIFICATION_AMBIGUITY: error message format not defined in DESIGN) | LOW |
| C6c — Recovery paths | PASS | Repository error → empty insights (no crash, recoverable) | — |
| C7a — Multi-tenant | N/A | Single-user iOS app; no multi-tenancy | — |
| C7b — Concurrency | GAP | Concurrent InsightsEngine calls not tested; pure function is safe but not explicitly asserted | LOW |
| C7c — Multi-actor | N/A | Single-user app | — |

**Gaps classified:**
- C3 (error path 29%): AT_GAP_IN_DELIVERY_SCOPE — crafter adds edge cases during DELIVER GREEN cycle
- C6b (error messages): SPECIFICATION_AMBIGUITY — error message format not specified in DESIGN wave; route to design for next feature
- C7b (concurrency): AT_GAP_IN_DELIVERY_SCOPE — add concurrency test in DELIVER if InsightsEngine gains async interface

### [REF] First test to enable in DELIVER

`InsightsEngineTests.swift` → `duplicatePrivathaftpflichtProducesDopplung`

Remove `withKnownIssue(...)` wrapper. Implement `InsightsEngine.insights()` until this test goes GREEN. Then enable the next test in order.
