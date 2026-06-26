# ADR-001: SwiftUI Application Architecture Pattern

**Status:** Proposed — awaiting selection  
**Date:** 2026-06-26  
**Deciders:** Fabian Benusch (sole developer)  
**Context:** FinanzApp SwiftUI rewrite, Stage 1 MVP

---

## Context

FinanzApp is being rewritten in SwiftUI + CloudKit. The Flutter reference codebase uses a `ChangeNotifier`-based controller pattern (resembling MVVM without protocol-typed dependencies). Three architectural options are viable for the SwiftUI rewrite. The choice determines testability, velocity, and future team onboarding cost.

**Constraints driving this decision:**
- Solo developer for Stage 1 MVP
- Production app handling personal financial documents — testability of core logic is non-negotiable
- CloudKit, Apple Vision, and Sign In with Apple as the only external integrations (all Apple SDKs)
- iOS 17+ minimum target enables `@Observable` macro (eliminates `ObservableObject`/`@Published` boilerplate)
- Stage 3+ may introduce broker referral APIs — architecture must accommodate new I/O adapters without core refactor

**Quality attributes ranked:**
1. Testability (financial data; deterministic insight calculation must be verifiable)
2. Maintainability (solo dev, infrequent context switches — low ceremony preferred)
3. Time-to-market (Stage 1 MVP)
4. Evolvability (team may grow; Stage 3 adds external integrations)

---

## Decision

**Selected: Option B — MVVM with Protocol-Typed Ports (Ports and Adapters)**

The domain layer consists of pure Swift value types (structs, enums). Port protocols define the I/O boundary. Concrete adapters implement the ports. `@Observable` ViewModels hold presentation state and call ports. Views bind to ViewModels only.

**Dependency rule (enforced by SwiftLint):**
```
Views → ViewModels → Ports (protocols) → Domain types
                          ↑
                      Adapters (implement ports, import frameworks)
```

No layer may import from a layer to its right. `Domain/` imports only Foundation. `Ports/` imports only Domain. `Adapters/` imports Ports + Apple frameworks. `ViewModels/` imports Ports + Domain. `Views/` imports ViewModels + Domain.

`InsightsEngine` and `ContractParser` are pure functions — static methods on value types, no protocol needed, directly unit-testable.

---

## Alternatives Considered

### Option A — MV Pattern (Apple's recommended minimal approach)

**Description:** Views bind directly to `@Observable` model objects. No ViewModel layer. No port protocols. Adapters call frameworks directly from model objects.

**Strengths:**
- Least boilerplate
- Apple's own sample code pattern for SwiftUI
- Fastest to initial working state

**Weaknesses:**
- Model objects accumulate mixed concerns: state + business rules + I/O coordination
- `ContractStore.save()` imports CloudKit — makes the store untestable without a CloudKit account
- `InsightsEngine` logic embedded in model makes it harder to test in isolation
- No protocol boundary means swapping CloudKit for a future backend requires editing model objects, not just replacing an adapter

**Rejection rationale:** Testability is ranked #1. OCR parsing heuristics and insight calculation must be unit-tested without running a CloudKit container. Option A cannot provide this without adding protocols anyway — meaning Option A either becomes Option B informally, or it doesn't get tested.

### Option C — The Composable Architecture (TCA, pointfreeco/swift-composable-architecture)

**Description:** All application state in a single `Store`. Mutations only via typed `Action` enums. Side effects via `Effect` type. Unidirectional data flow enforced by the framework.

**Strengths:**
- Excellent testability — TCA's `TestStore` is thorough
- Enforces unidirectional data flow architecturally
- Strong SwiftUI community adoption

**Weaknesses:**
- Significant upfront learning investment for a solo developer
- Verbose: every user interaction requires an `Action` case, a `Reducer` clause, and often an `Effect`
- Adds a non-trivial external dependency to the core architectural layer
- TCA's benefits (state coordination across complex async flows, global state) solve problems that emerge at team size 3+, not solo
- The PointFree library version-upgrades have historically introduced breaking changes — maintenance burden for a solo app

**Rejection rationale:** Over-engineered for Stage 1 solo development. The protocol-injection pattern in Option B provides equivalent testability with no external dependency and significantly lower ceremony. If the team grows to 3+ developers with deeply nested state, TCA should be revisited.

---

## Consequences

### Positive
- `InsightsEngine.insights(contracts:catalog:)` is a pure function — fully unit-testable with zero infrastructure
- `ContractParser.parseFields(ocr:category:)` is a pure function — OCR heuristics can be tested with text fixture files
- All ViewModels accept protocol-typed dependencies — `MockContractRepository` provides instant previews and unit tests
- The `Adapters/` layer is isolated — switching from CloudKit to Firebase or a REST backend in Stage 3 touches only adapters, not ViewModels or Domain
- SwiftLint custom rules make dependency violations a build error, not a code review finding

### Negative
- ~2 days of protocol + adapter scaffolding before the first screen works end-to-end
- Two model types for contracts (`PendingContract` and `Contract`) adds a concept the Flutter codebase avoids. The trade-off: the two-type approach eliminates the `ExtractionStatus` runtime branch and makes invalid states unrepresentable.
- ViewModels are an extra file per screen — 6 ViewModels for Stage 1 screens

### Neutral
- `@Observable` macro (iOS 17+) eliminates the `@Published` boilerplate that made classic MVVM verbose in SwiftUI

---

## Enforcement

**SwiftLint custom rules** (`.swiftlint.yml` in project root):

```yaml
custom_rules:
  no_framework_in_domain:
    name: "No framework imports in Domain"
    regex: "^import (CloudKit|Vision|UIKit|AuthenticationServices)"
    included: ".*Domain/.*\\.swift"
    message: "Domain types must not import Apple frameworks. Add a Port protocol and Adapter instead."
    severity: error

  no_concrete_adapter_in_viewmodel:
    name: "ViewModels use protocol types only"
    regex: "CloudKitContractRepository|VisionDocumentScanner|BundleCatalogProvider"
    included: ".*ViewModels/.*\\.swift"
    message: "ViewModels must reference protocol types (ContractRepository, DocumentScanner, CatalogProvider), not concrete adapters."
    severity: error
```

These rules run in CI (`xcodebuild` pre-build phase) and locally via `swiftlint` in the Run Script build phase.

---

## Y-Statement Summary

In the context of a solo-developer SwiftUI MVP for a financial transparency app, facing the constraint that insight calculation and OCR parsing must be unit-testable without infrastructure, we decided for MVVM with protocol-typed ports to achieve testability and clean adapter isolation, accepting the upfront cost of 2 days of port/adapter scaffolding and a two-type contract model.
