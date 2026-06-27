# WealthEagent

> **Messen, nicht empfehlen.** Eine iOS-App für Deutschland, die Nutzern hilft, ihre Versicherungen und Finanzverträge zu überblicken — provisionsfrei, transparent, EU-only.

[![Tests](https://img.shields.io/badge/Tests-147%20grün-22c55e)](https://github.com/wik32/wealtheagent)
[![SwiftLint](https://img.shields.io/badge/SwiftLint-0%20Errors-22c55e)](https://github.com/realm/SwiftLint)
[![Swift](https://img.shields.io/badge/Swift-6.0-orange)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17%2B-blue)](https://developer.apple.com/ios/)
[![Stage](https://img.shields.io/badge/Stage-1%20MVP%20~90%25-f59e0b)]()

---

## Was ist WealthEagent?

WealthEagent zeigt Fakten aus den eigenen Unterlagen des Nutzers — keine Produktempfehlungen, kein Vergleichsportal, kein Affiliate-Modell.

**Stage 1 — „messen, nicht empfehlen":**
- Verträge manuell erfassen oder per OCR-Scan einlesen
- Leistungskriterien nach Stiftung Warentest / Franke & Bornberg prüfen
- Dopplungen, Lücken und Kostenkennzahlen (TER) als Beobachtungen sehen
- Portfolio-Abdeckungsgrad und monatliche Ausgaben im Blick behalten

---

## Screenshots

*— folgen nach Design-System-Sprint —*

---

## Tech Stack

| Bereich | Technologie |
|---|---|
| UI | SwiftUI, iOS 17+, iPhone + iPad |
| Sprache | Swift 6.0, Strict Concurrency |
| Persistence | SwiftData (lokal), CloudKit Private DB (Stage 2) |
| OCR | Apple Vision `VNRecognizeTextRequest` (on-device) |
| Benachrichtigungen | `UNUserNotificationCenter` (lokal, 30 Tage vor Vertragsende) |
| Tests | Swift Testing + XCTest (147 Tests, 0 Failures) |
| Build | xcodegen + Swift Package Manager |
| Linting | SwiftLint 0.64.1 mit Layer-Enforcement-Regeln |

---

## Architektur

```
Views
  └── ViewModels (@Observable, @MainActor)
        └── Ports (Swift-Protokolle)
              ├── Adapters     (SwiftData, Vision, UserNotifications, Bundle)
              ├── Services     (InsightsEngine, ContractParser, PortfolioExporter)
              └── Domain       (Contract, Catalog, FinInsights — pure value types)
```

**Layer-Regeln** sind per SwiftLint erzwungen:
- `Domain` importiert nur `Foundation`
- `Ports` importiert nur `Foundation` + Domain-Typen
- `ViewModels` importiert nur Ports + Domain + `Observation`
- `Views` importiert SwiftUI + ViewModels + Domain (kein SwiftData, kein CloudKit)

### Ports

| Protokoll | Adapter (Produktion) | Mock (Tests) |
|---|---|---|
| `ContractRepository` | `LocalContractRepository` (SwiftData) | `MockContractRepository` |
| `CatalogProvider` | `BundleCatalogProvider` (catalog.json) | `MockCatalogProvider` |
| `DocumentScanner` | `VisionDocumentScanner` | `MockDocumentScanner` |
| `NotificationPort` | `LocalNotificationAdapter` | `MockNotificationPort` |

---

## Features (Stage 1)

### Vertragsmanagement
- **Manuell erfassen** — Kategorie (22 Einträge), Anbieter, Beitrag, Zahlungsrhythmus, Laufzeit, Leistungskriterien-Checkboxen
- **OCR-Scan** — Live-Kamera oder Fotobibliothek, Mehrseitenscan, 32 Anbieter erkannt, 10 Kriterien heuristisch extrahiert
- **Entwurf prüfen** — OCR-Konfidenz anzeigen, alle Felder korrigierbar vor Bestätigung
- **Bearbeiten** — alle Felder inkl. Kriterien, Upsert (ID bleibt erhalten)
- **Löschen** — Swipe-to-Delete mit Notification-Abbestellung
- **Suche** — nach Anbieter oder Kategoriename
- **Sortierung** — Anbieter A–Z, Kategorie, Beitrag ↑↓, Vertragsende

### Analyse & Beobachtungen
- **Dashboard** — Abdeckungsgrad (0–100 %), Progress-Bar, monatliche Ausgaben, abgedeckte/fehlende Kategorien
- **Beobachtungen** — Dopplung / Lücke / Vergleich (InsightsEngine, pure functions)
- **CompareView** — Kriterienmatrix ✓/✗/– für zwei Verträge derselben Kategorie
- **Insight-Detail** — TER-Erklärung mit Benchmark (<1 % günstig, Quelle: Stiftung Warentest)

### Verknüpfungen
- Tap **Dopplung** → CompareView
- Tap **Lücke** → AddContractView (Kategorie vorausgewählt)
- Tap **Vergleich** → InsightDetailView

### Utilities
- **Laufzeiterinnerungen** — Push-Notification 30 Tage vor Vertragsende
- **Portfolio-Export** — Textexport aller Verträge mit Kriterien-Score, ShareSheet
- **iCloud-Status** — Verbindungsanzeige in Settings (Sync-Aktivierung in Stage 2)
- **First-Launch Disclaimer** — fullScreenCover, einmalig, @AppStorage

### Rechtliches
- Haftungsausschluss (WpHG/VAG, OCR-Hinweis, Datenbasis)
- Datenschutzerklärung (DSGVO, Art. 13/14, iCloud EU-Rechenzentren)
- Impressum nach § 5 TMG *(Platzhalter — vor Launch ausfüllen)*

---

## Katalog

**22 Vertragsarten** in `WealthEagent/Resources/catalog.json`, 3 Stufen:

| Stufe | Bezeichnung | Anzahl | Beispiele |
|---|---|---|---|
| 1 | Basisabsicherung | 11 | Privathaftpflicht, BU, Kranken, Kfz |
| 2 | Vermögensaufbau | 8 | Depot, Altersvorsorge, Bausparvertrag |
| 3 | Ergänzungen | 3 | Reise, Sterbegeld, Krankentagegeld |

Leistungskriterien basieren auf **Stiftung Warentest** und **Franke & Bornberg** — keine DIN 77230 / Defino-Systematik.

---

## Entwicklung

### Voraussetzungen

- Xcode 16+
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- [SwiftLint](https://github.com/realm/SwiftLint): `brew install swiftlint`

### Setup

```bash
git clone https://github.com/wik32/wealtheagent.git
cd wealtheagent
xcodegen generate
open WealthEagent.xcodeproj
```

### Tests

```bash
xcodebuild test \
  -project WealthEagent.xcodeproj \
  -scheme WealthEagent \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

### SwiftLint

```bash
swiftlint lint --config .swiftlint.yml
```

### Neues Feature

```bash
# 1. DISTILL — Acceptance Tests (RED)
# 2. DELIVER — Implementation (GREEN → COMMIT)
# Dokumentation: docs/feature/{feature-id}/
```

---

## Projektstruktur

```
WealthEagent/
├── Domain/            # Reine Value Types (Contract, Catalog, FinInsights)
├── Ports/             # Swift-Protokolle (ContractRepository, DocumentScanner, …)
├── Adapters/          # Framework-Implementierungen (SwiftData, Vision, …)
├── Services/          # Pure Functions (InsightsEngine, ContractParser, …)
├── ViewModels/        # @Observable @MainActor (Dashboard, ContractList, …)
├── Views/             # SwiftUI Screens (ContractDetailView, CompareView, …)
└── Resources/
    └── catalog.json   # 22 Vertragsarten + Leistungskriterien

WealthEagentTests/
├── Domain/            # Swift Testing — InsightsEngine, Catalog
├── Services/          # Swift Testing — ContractParser
├── Adapters/          # XCTest — LocalContractRepository, BundleCatalogProvider
├── ViewModels/        # XCTest — alle ViewModels mit Mock-Ports
├── Views/             # XCTest — strukturelle Wiring-Tests
└── Mocks/             # MockContractRepository, MockDocumentScanner, …

docs/
├── product/
│   ├── architecture/  # ADRs, brief.md, ATDD-Policy
│   └── criteria-research.md
└── feature/           # nWave-Artefakte pro Feature
```

---

## Nicht verhandelbar

| Regel | Grund |
|---|---|
| Kein „empfehlen" / „Empfehlung" | Stage-1-Prinzip: messen, nicht beraten |
| Kein „Defino" / „DIN 77230" | Lizenzrechtlich problematisch, eigene Systematik |
| EU-only Datenspeicherung | SwiftData lokal + iCloud EU-Rechenzentren |
| Keine Finanzberatung | Keine BaFin-Lizenz, nur Fakten aus Nutzer-Unterlagen |

---

## Roadmap

### Bis TestFlight
- [ ] App Icon (1024×1024 PNG)
- [ ] Impressum ausfüllen (Name, Adresse, E-Mail)
- [ ] Paid Apple Developer Account → Signing + TestFlight-Upload

### Stage 1 (verbleibend)
- [ ] Design-System (Tokens, Typografie, Farben)
- [ ] Visual Polish aller Views

### Stage 2
- [ ] CloudKit-Sync (iCloud Private Database, paid account)
- [ ] Apple Sign-In
- [ ] Wissensartikel / Lexikon (`catalog.knowledgeArticles` → UI)
- [ ] PDF-Export mit Layout
- [ ] Home-Screen Widget
- [ ] Zeitverlauf / Trend auf Dashboard
- [ ] Android (Kotlin + Firebase, separates Produkt)

---

## Lizenz

Privates Projekt. Alle Rechte vorbehalten. Kein Open-Source-Release geplant.

---

*Stand: Juni 2026 — Stage 1 MVP ~90 % fertig, 147 Tests grün*
