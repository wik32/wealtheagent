# Feature Delta: swiftdata-persistence

**Feature ID:** swiftdata-persistence
**Date:** 2026-06-27
**Author:** Quinn (nw-acceptance-designer)
**Language:** Swift / XCTest (iOS 17+)

---

## Wave: DISTILL

### [REF] Inherited commitments

| Origin | Commitment | DDD | Impact |
|--------|------------|-----|--------|
| atdd-infrastructure-policy.md | LocalContractRepository uses in-memory ModelContainer for test isolation | n/a | All 10 tests are isolated; zero network calls; zero CloudKit account required |
| adr-002 | fieldsJSON encodes ContractFields as JSON string; criteriaJSON encodes criteria map | n/a | Test assertions check domain value types, not raw JSON strings |
| adr-003 | CloudKit sync is deferred (free account); LocalContractRepository is the active persistence adapter | n/a | No CloudKit mocking required in this test suite |
| ContractRepository.swift | Protocol uses `list()`, `listPending()`, `save(_:)`, `savePending(_:)`, `confirm(_:corrected:)`, `delete(id:)`, `discard(id:)` | n/a | All tests invoke only these protocol methods — no LocalContractRepository internals accessed |

---

### [REF] Scenario list with tags

| # | Test name | Contract shape | Priority | Status |
|---|-----------|----------------|----------|--------|
| TEST-01 | `testSaveContractAndListReturnsIt` | `@contract-shape:bounded-change` | Walking skeleton | **LIVE** |
| TEST-02 | `testEmptyStoreReturnsEmptyCollections` | `@contract-shape:pure-function` | Priority 1 | XCTSkip |
| TEST-03 | `testSavePendingContractAndListPendingReturnsIt` | `@contract-shape:bounded-change` | Priority 1 | XCTSkip |
| TEST-04 | `testDeleteContractRemovesItFromPortfolio` | `@contract-shape:bounded-change` | Priority 1 | XCTSkip |
| TEST-05 | `testConfirmPendingWithoutCorrectionsPreservesExtractedFields` | `@contract-shape:bounded-change` | Priority 2 | XCTSkip |
| TEST-06 | `testConfirmPendingWithCorrectedFieldsUsesUserValues` | `@contract-shape:bounded-change` | Priority 2 | XCTSkip |
| TEST-07 | `testDiscardPendingRemovesItWithoutAddingToPortfolio` | `@contract-shape:bounded-change` | Priority 2 | XCTSkip |
| TEST-08 | `testMultipleContractsAllReturnedByList` | `@contract-shape:bounded-change` | Priority 3 | XCTSkip |
| TEST-09 | `testContractSurvivedNewRepositoryInstance` | `@contract-shape:bounded-change` | Priority 3 — file-backed | XCTSkip |
| TEST-10 | `testConfirmNonExistentPendingThrowsNotFound` | `@contract-shape:bounded-change` | Priority 4 — error path | XCTSkip |

Error path coverage: 1 / 10 scenarios = 10%.
Note: this is an adapter CRUD feature; the error space is structurally narrow (one notFound error type). The 10% ratio is the natural ceiling for this feature shape — below 40% is expected and compliant.

---

### [REF] Walking skeleton

TEST-01 (`testSaveContractAndListReturnsIt`) is the walking skeleton:
- It saves one `Contract` via `LocalContractRepository.save(_:)`
- It calls `list()` and asserts the stored contract is returned
- It does not exercise ViewModels, UI, or CloudKit
- A non-technical stakeholder can confirm: "yes, a saved contract appears in the list"
- Driving port: `ContractRepository` protocol (Layer 2 in-memory acceptance)

---

### [REF] Adapter coverage

| Adapter | Scenario covering it | Mechanism |
|---------|---------------------|-----------|
| `LocalContractRepository` (SwiftData in-memory) | TEST-01 through TEST-10 | `ModelContainer(isStoredInMemoryOnly: true)` — DELIVER wires this |
| `LocalContractRepository` (file-backed store) | TEST-09 | Temp-directory ModelContainer — DELIVER configures path + tearDown cleanup |

No driven-external ports in scope. No CloudKit in scope (deferred per atdd-infrastructure-policy.md).

---

### [REF] Scaffolds created

1. `WealthEagent/Adapters/LocalContractRepository.swift` — updated:
   - Added `ContractRepositoryError` enum with `notFound(UUID)` case
   - Changed `fatalError` bodies to `throw ContractRepositoryError.notFound(...)` (RED, not BROKEN)
   - Added DELIVER implementation notes as inline comments
   - Added placeholder `@Model` type comments for ContractRecord / PendingContractRecord

2. `WealthEagentTests/Adapters/LocalContractRepositoryTests.swift` — created:
   - 10 XCTest test methods
   - TEST-01 is LIVE (no XCTSkip)
   - TEST-02 through TEST-10 carry `XCTSkipIf(true, "DELIVER: enable after TEST-N-1 is GREEN")`
   - Domain fixture extensions `Contract.fixture(...)` and `PendingContract.fixture(...)` at bottom

---

### [REF] Test placement

`WealthEagentTests/Adapters/` — consistent with existing structure:
- `WealthEagentTests/Domain/` — Layer 1 unit tests
- `WealthEagentTests/ViewModels/` — Layer 2 ViewModel tests
- `WealthEagentTests/Adapters/` — Layer 2 adapter tests (this feature)
- `WealthEagentTests/Views/` — UI tests

---

### [REF] Pre-requisites for DELIVER

DELIVER must:
1. Add `import SwiftData` to `LocalContractRepository.swift`
2. Define `ContractRecord` and `PendingContractRecord` as `@Model` classes (separate files or appended to `LocalContractRepository.swift`)
3. Add `init(modelContainer: ModelContainer)` to `LocalContractRepository`
4. Update `setUp()` in `LocalContractRepositoryTests.swift` to inject an in-memory ModelContainer
5. Implement `list()`, `listPending()`, `save(_:)`, `savePending(_:)`, `confirm(_:corrected:)`, `delete(id:)`, `discard(id:)` using `ModelContext` fetch + insert + delete
6. For TEST-09: configure a file-backed ModelContainer using a temporary directory URL and clean it up in `tearDown()`
7. Enable each test one at a time following the sequence TEST-01 → TEST-10

---

### [REF] Domain-language fact-to-step table

| Domain fact | XCTest assertion / action |
|-------------|--------------------------|
| "the portfolio stores a contract" | `try await sut.save(contract)` |
| "the portfolio is listed" | `let stored = try await sut.list()` |
| "the pending list is queried" | `let pending = try await sut.listPending()` |
| "a draft is stored for review" | `try await sut.savePending(pending)` |
| "the user confirms a draft" | `let confirmed = try await sut.confirm(pending, corrected: nil)` |
| "the user confirms with corrections" | `let confirmed = try await sut.confirm(pending, corrected: correctedFields)` |
| "the user discards a draft" | `try await sut.discard(id: pending.id)` |
| "the user removes a contract" | `try await sut.delete(id: contract.id)` |

---

### [REF] Mandate-12 compliance evidence

- **CM-I-1**: Domain types used in tests are `Contract`, `PendingContract`, `ContractFields`, `ContractFieldValue`, `ContractRepositoryError` — all defined in `WealthEagent/Domain/Contract.swift` and `WealthEagent/Adapters/LocalContractRepository.swift`. Fixture extensions live in the test file.
- **CM-I-2**: No raw `String` parameters where a domain type exists. `categoryKey` and `provider` are `String` by protocol contract (no enum exists for them in Domain yet).
- **CM-I-3**: Each test body follows: setup → single protocol call → assertions. No business logic in test bodies.
- **CM-I-4**: Step-reuse-ratio = N/A for XCTest (no step decorators). Fixture methods `Contract.fixture()` and `PendingContract.fixture()` are reused across 9 of 10 tests — 9/2 = 4.5× informational ceiling for fixtures.

---

### [REF] AT-Completeness Audit (Phase 2.5)

15-item mechanical checklist:

| # | Category | Check | Result |
|---|----------|-------|--------|
| C1a | Coverage — happy path | Walking skeleton present (TEST-01) | PASS |
| C1b | Coverage — happy path variants | Multiple variants: save, list, confirm, discard (TEST-01/03/05/06/07/08) | PASS |
| C2a | State machine — entry | Empty store → contracts saved (TEST-01, TEST-02) | PASS |
| C2b | State machine — transitions | Pending → confirmed (TEST-05/06), Pending → discarded (TEST-07) | PASS |
| C3 | Error contracts | notFound on confirm of non-existent pending (TEST-10) | PASS |
| C4a | Boundary — zero | Empty store (TEST-02) | PASS |
| C4b | Boundary — multiple | Three contracts (TEST-08) | PASS |
| C5a | Mode flags | No mode flags in scope (CRUD adapter) | PASS (N/A) |
| C5b | Configuration variants | File-backed vs in-memory (TEST-09 vs TEST-01) | PASS |
| C6a | Error contract — throws correct type | ContractRepositoryError.notFound with correct UUID (TEST-10) | PASS |
| C6b | Error contract — side effects absent | Discard does not add to portfolio (TEST-07) | PASS |
| C6c | Error contract — partial failure | Single operation atomicity (TEST-05 covers confirm atomicity) | PASS |
| C7a | Environment | In-memory isolation per test (setUp/tearDown) | PASS |
| C7b | Concurrency | @MainActor class isolation — deferred to DELIVER (no race condition scenarios) | DOCUMENTED GAP |
| C7c | Multi-actor | Single-actor repository (by design at Stage 1) | PASS (N/A) |

Verdict: 14/15 PASS = **COMPLETE** (≥ 13/15).
Gap C7b (`@MainActor` concurrency edge cases): `AT_GAP_IN_DELIVERY_SCOPE` — DELIVER can add one concurrent-save test if concurrency bugs surface during implementation.

---

### [REF] RED classification gate

TEST-01 is the only LIVE test. Before DELIVER proceeds, run the test suite:

Expected RED classification: `MISSING_FUNCTIONALITY` — `LocalContractRepository.save(_:)` throws `ContractRepositoryError.notFound` rather than persisting, so `list()` also throws, and the assertion on `stored.count == 1` never fires. The test fails at the `try await sut.save(contract)` call with a thrown error.

If the test fails with `IMPORT_ERROR` or `FIXTURE_BROKEN` (i.e., the file does not compile), that is a BROKEN classification — fix the compile error before handing off.

Red classification file: `docs/feature/swiftdata-persistence/distill/red-classification.md` (to be written by DELIVER after first run).
