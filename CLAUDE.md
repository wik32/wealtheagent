# WealthEagent — CLAUDE.md

## Was ist das?

Provisionsfrei, transparent, EU-only. Eine B2C-App für Deutschland, die Nutzern hilft,
ihre Versicherungen und Finanzverträge zu überblicken.

**Stage 1 — „messen, nicht empfehlen"**: Die App zeigt Fakten aus eigenen Unterlagen.
Keine Produktempfehlungen, kein Vergleichsportal, kein Affiliate.

---

## Nicht verhandelbare Regeln (immer einhalten)

| Regel | Detail |
|---|---|
| Kein „empfehlen/Empfehlung" | In user-facing Text nie verwenden. Stattdessen: „Beobachtungen", „Fakten", „wir messen" |
| Kein „Defino" / „DIN 77230" | Nirgends verwenden — weder UI noch Code-Kommentare noch Docs |
| EU-only Datenspeicherung | Hard requirement — SwiftData lokal + iCloud für EU-Nutzer |
| Keine Finanzberatung | Nur Fakten aus Unterlagen des Nutzers. Niemals Anlage- oder Versicherungsempfehlungen |

---

## Stack (aktiv)

| Layer | Technologie | Status |
|---|---|---|
| UI | SwiftUI, iOS 17+, iPhone + iPad | ✅ aktiv |
| Persistence | SwiftData (lokal), `@Model ContractRecord` | ✅ aktiv |
| Sync | CloudKit Private Database | ⏳ benötigt paid Apple Dev Account |
| Auth | Apple Sign-In via iCloud | ⏳ benötigt paid Apple Dev Account |
| OCR | Apple Vision `VNRecognizeTextRequest`, on-device | ✅ aktiv |
| Testing | Swift Testing (`@Test`, `#expect`) + XCTest | ✅ aktiv |
| Build | xcodegen (project.yml) | ✅ aktiv |
| Linting | SwiftLint 0.64.1, custom layer-enforcement rules | ✅ aktiv |
| Language | Swift 6.0, `SWIFT_STRICT_CONCURRENCY: complete` | ✅ aktiv |

**Bundle-ID:** `de.wealtheagent.app`
**Team-ID:** `S329UBTY8T` (f.benusch@icloud.com, persönliches free account)
**GitHub:** `github.com/wik32/wealtheagent`
**Android:** Separates Produkt (Kotlin + Firebase) wenn Marktbedarf entsteht.

---

## Architektur (MVVM + Protocol-Typed Ports)

```
Views → ViewModels (@Observable) → Ports (Protokolle) → Domain
                                        ↑
                               Adapters (SwiftData, Vision, Bundle, UserNotifications)
                                        ↑
                               Services (InsightsEngine, ContractParser, PortfolioExporter)
```

### Layer-Regeln (SwiftLint enforced — `.swiftlint.yml`)

| Layer | Erlaubte Imports | Verboten |
|---|---|---|
| `Domain/` | Foundation | CloudKit, Vision, UIKit, SwiftUI, SwiftData |
| `Ports/` | Foundation + Domain | CloudKit, Vision, UIKit, SwiftUI, SwiftData |
| `ViewModels/` | Foundation, Observation, Ports, Domain | CloudKit, Vision, UIKit, SwiftUI, SwiftData |
| `Adapters/` | Ports + alle Apple Frameworks | — |
| `Views/` | SwiftUI, PhotosUI, UIKit, Ports, Domain | CloudKit, SwiftData, Vision |

### Aktive Ports

| Protokoll | Production Adapter | Test Mock |
|---|---|---|
| `ContractRepository` | `LocalContractRepository` (SwiftData) | `MockContractRepository` |
| `CatalogProvider` | `BundleCatalogProvider` (catalog.json) | `MockCatalogProvider` |
| `DocumentScanner` | `VisionDocumentScanner` (Apple Vision) | `MockDocumentScanner` |
| `NotificationPort` | `LocalNotificationAdapter` (UNUserNotificationCenter) | `MockNotificationPort` |

---

## Katalog (catalog.json)

22 Vertragsarten in 3 Stufen — `WealthEagent/Resources/catalog.json`.
Leistungskriterien basieren auf **Stiftung Warentest** + **Franke & Bornberg** (nicht DIN 77230).

- **Stufe 1 (11)** — Basisabsicherung: Privathaftpflicht, BU, Kranken, Pflege, Risikoleben, Unfall, Hausrat, Wohngebäude, Rechtsschutz, Kfz, Tierhalterhaftpflicht
- **Stufe 2 (8)** — Vermögensaufbau: Liquiditätsreserve, Altersvorsorge, Lebensversicherung, Immobilienfinanzierung, Bausparvertrag, Depot, Sparplan, Tagesgeld/Festgeld
- **Stufe 3 (3)** — Ergänzungen: Sterbegeld, Reiseversicherung, Krankentagegeld

`BundleCatalogProvider` liest `catalog.json` einmalig und cached. Änderungen am
Katalog nur in `catalog.json` — nie wieder hard-coded in Swift.

---

## Persistenz (SwiftData)

```swift
// @Model-Typen in LocalContractRepository.swift
ContractRecord   // bestätigte Verträge  → Contract (Domain)
PendingContractRecord  // OCR-Entwürfe → PendingContract (Domain)
```

- Zone: `ModelContainer(for: ContractRecord.self, PendingContractRecord.self)`
- Tests: `ModelConfiguration(isStoredInMemoryOnly: true)` für Isolation

---

## Tests

```
147 Tests, 0 Failures, 0 SwiftLint Errors (Stand: 2026-06-27)

63 Swift Testing (@Test, #expect)        — Layer 1 Unit (pure functions)
84 XCTest (@MainActor)                   — Layer 2 In-memory Acceptance
```

| Suite | Framework | Was wird getestet |
|---|---|---|
| `InsightsEngineTests` | Swift Testing | Dopplung, Lücke, TER, Coverage-Score |
| `CatalogTests` | Swift Testing | 22 Kategorien, Kriterien, Lookups |
| `ContractParserTests` | Swift Testing | OCR-Extraktion, Anbieter, Kriterien |
| `BundleCatalogProviderTests` | XCTest | Echte catalog.json Bundle-Dekodierung |
| `LocalContractRepositoryTests` | XCTest | SwiftData CRUD, in-memory |
| `*ViewModelTests` | XCTest | Alle ViewModels mit Mock-Ports |
| `*ViewTests` | XCTest | Strukturelle Wiring-Checks |

---

## Implementierte Features (Stand: 2026-06-27)

### Vertragsmanagement
- Manuelles Erfassen (Kategorie, Anbieter, Beitrag, Zahlungsrhythmus, Laufzeit, Leistungskriterien)
- OCR-Scan (Apple Vision, on-device, de-DE, Kamera + Bibliothek, Mehrseitenscan)
- Entwurf-Prüf-Screen nach Scan (korrigierbar, Kriterien aus OCR befüllt)
- Vertragsliste mit Suche + Sortierung (5 Optionen)
- Vertragsdetail (read-only, alle Felder, Kriterien ✓/✗/–)
- Bearbeiten (pre-filled, Upsert by ID)
- Löschen (Swipe-to-Delete)

### Analyse
- Dashboard: Abdeckungsgrad (%), Monatliche Ausgaben, abgedeckte/fehlende Kategorien
- Beobachtungen: Dopplung / Lücke / Vergleich (InsightsEngine)
- CompareView: Kriterienmatrix ✓/✗/– für Dopplung-Verträge
- InsightDetailView: TER-Erklärung mit Benchmark

### Verknüpfungen
- Tap Dopplung → CompareView
- Tap Lücke → AddContractView (Kategorie vorausgewählt)
- Tap Vergleich/TER → InsightDetailView

### Utilities
- Laufzeiterinnerungen (Push-Notification 30 Tage vor Vertragsende)
- Portfolio-Export (Text-Zusammenfassung, ShareSheet)
- iCloud-Verbindungsstatus in Settings

### Rechtliches
- First-Launch Pflichthinweis (fullScreenCover, @AppStorage)
- Haftungsausschluss, Datenschutz (DSGVO), Impressum [Platzhalter]

---

## Offene Punkte

### TestFlight-Blocker
- [ ] App Icon (1024×1024 PNG ohne Alpha)
- [ ] Impressum ausfüllen (Name, Adresse, E-Mail in `ImpressumView.swift`)
- [ ] Paid Apple Developer Account ($99/Jahr) → Signing + CloudKit

### Stage 1 — Design
- [ ] Design-System (Tokens, Typografie, Farben) — SwiftUI noch ungestylt
- [ ] Visual Polish aller Views

### Stage 2 — Geplant
- [ ] CloudKit-Sync (paid account nötig)
- [ ] Apple Sign-In
- [ ] Wissensartikel / Lexikon (catalog hat `knowledgeArticles`, keine UI)
- [ ] PDF-Export mit Layout
- [ ] Home-Screen Widget
- [ ] Zeitverlauf / Trend auf Dashboard

---

## Entwicklungsworkflow

```bash
# Projekt neu generieren (nach project.yml-Änderungen)
xcodegen generate

# Tests lokal
xcodebuild test -project WealthEagent.xcodeproj \
  -scheme WealthEagent \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# SwiftLint
swiftlint lint --config .swiftlint.yml

# Auf Gerät bauen (iPhone verbunden, Team-ID gesetzt)
xcodebuild -project WealthEagent.xcodeproj -scheme WealthEagent \
  -destination 'platform=iOS,id=DEVICE_UDID' \
  -allowProvisioningUpdates DEVELOPMENT_TEAM=S329UBTY8T
```

**Neue Dateien** immer in `project.yml` prüfen — xcodegen nimmt alle `.swift`-Dateien
aus `WealthEagent/` automatisch auf, aber `Resources/` muss explizit gelistet sein.

---

## Methodologie

Entwicklung nach **nWave** (DISTILL → DELIVER pro Feature).
- DISTILL: Acceptance-Tests zuerst (RED), dann DELIVER: Implementation (GREEN → COMMIT)
- Crafter: `@nw-software-crafter` (OOP, Swift)
- DES-Tracking in `docs/feature/{feature-id}/deliver/`
