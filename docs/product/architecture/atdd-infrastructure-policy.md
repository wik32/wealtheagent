# ATDD Infrastructure Policy — FinanzApp

**Project:** FinanzApp (SwiftUI + CloudKit, iOS 17+)
**Date:** 2026-06-26
**Author:** Quinn (nw-acceptance-designer)

Per `nw-distill` Project Infrastructure Policy. One file per project. Apply-if-exists; write-if-absent; rewrite with `--policy=fresh`. Git history is the audit trail.

---

## Driving

| Port | Mechanism | Note |
|---|---|---|
| `InsightsEngine.insights(contracts:catalog:)` | Direct call in Swift Testing `@Test` body | Pure function — no DI, no mock, zero infrastructure. Call with fixture inputs, assert output. |
| `CatalogProvider` protocol | `MockCatalogProvider` in-memory implementation | Synchronous. Mirrors `BundleCatalogProvider` interface. |
| `ContractRepository` protocol | `MockContractRepository` in-memory implementation | Async. Mirrors `CloudKitContractRepository` interface. No CloudKit dependency. |
| `DocumentScanner` protocol | `MockDocumentScanner` in-memory implementation | Returns configurable `OCRResult` fixtures. No Apple Vision dependency. |

---

## Driven internal (real)

| Port | Mechanism | Note |
|---|---|---|
| `CloudKitContractRepository` | Requires real iCloud account + CloudKit container | Not included in unit test suite. Covered by `probe()` contract + manual integration test on device. Add Xcode UI test target when CI includes a real device. |
| `BundleCatalogProvider` | Real bundle read from `catalog.json` | DELIVER: add one integration test in `FinanzAppTests` that instantiates `BundleCatalogProvider` and calls `.catalog()`. Verifies JSON decodes to 22 categories. |

---

## Driven external / non-deterministic (fake)

| Port | Fake | Note |
|---|---|---|
| `VisionDocumentScanner` (Apple Vision) | `MockDocumentScanner` | Returns fixture `OCRResult`. No camera, no Vision framework, no device required. |
| `CloudKit` (iCloud Private Database) | `MockContractRepository` | In-memory contract store. Not a CloudKit fake — it is a complete in-process replacement. The `ContractRepository` protocol is the boundary. |
| Apple Sign-In / iCloud account | Not mocked in unit tests | Authentication is handled by the OS. Unit tests do not test auth flow. ViewModel sign-out is tested by calling `repository.reset()` in `MockContractRepository`. |
| System clock (`Date()`) | Fixture-provided `Date` values | Test fixtures use hardcoded dates where date equality is tested. No fake clock needed at Stage 1. |

---

## Layer Assignment (per nw-test-design-mandates Layered Test Discipline)

| Test Suite | Layer | Mechanism |
|---|---|---|
| `InsightsEngineTests.swift` (Swift Testing) | Layer 1 — Unit | Pure function, zero infrastructure, Swift Testing `@Test` |
| `CatalogTests.swift` (Swift Testing) | Layer 1 — Unit | In-memory `MockCatalogProvider`, zero infrastructure |
| `ContractListViewModelTests.swift` (XCTest) | Layer 2 — In-memory acceptance | `MockContractRepository`, async/await, XCTest |
| BundleCatalogProvider integration test (planned) | Layer 3 — Adapter integration | Real `catalog.json` bundle read, XCTest |
| CloudKit integration tests (future) | Layer 4 — Integration | Requires real CloudKit container, device-only |

---

## Banned Infrastructure in Unit Tests

The following must NOT appear in `InsightsEngineTests.swift` or `CatalogTests.swift`:
- `import CloudKit`
- `import Vision`
- `import UIKit`
- Any `async` / `await` (InsightsEngine is synchronous)
- Any `XCTestExpectation` (use Swift Testing `#expect`)

These constraints are enforced by SwiftLint rules in `.swiftlint.yml` (see ADR-001).

---

## State-Delta Port (Mandate 8)

Swift pilot of the universe-bound assertion contract. The Python canonical is at `nwave_ai/state_delta/`. For Swift, the equivalent is:

```swift
// tests/common/StateDelta.swift (to be bootstrapped in DELIVER)
// Captures observable state before and after a mutation and asserts
// only the declared universe entries changed as expected.

struct StateDelta<Universe: Equatable> {
    let before: Universe
    let after: Universe

    func assert(
        universe: [KeyPath<Universe, some Equatable>],
        expected: [KeyPath<Universe, some Equatable>: some Equatable],
        file: StaticString = #file, line: UInt = #line
    ) {
        // assert only declared keys changed; all others must be equal
    }
}
```

At Stage 1, the pure-function tests use direct `#expect()` assertions (equivalent to layers 4+ traditional assertions per Mandate 8). The `StateDelta` Swift port is planned for DELIVER when ViewModel state mutation tests are implemented (Layer 2).
