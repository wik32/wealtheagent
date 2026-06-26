# FinanzApp — CLAUDE.md

## Was ist das?

Provisionsfrei, transparent, EU-only. Eine B2C-App für Deutschland, die Nutzern hilft, ihre Versicherungen und Finanzverträge zu überblicken.

**Stage 1 — „messen, nicht empfehlen"**: Die App zeigt Fakten aus eigenen Unterlagen. Keine Produktempfehlungen, kein Vergleichsportal, kein Affiliate.

---

## Nicht verhandelbare Regeln (immer einhalten)

| Regel | Detail |
|---|---|
| Kein „empfehlen/Empfehlung" | In user-facing Text nie verwenden. Stattdessen: „Beobachtungen", „Fakten", „wir messen" |
| Kein „Defino" / „DIN 77230" | Nicht in UI-Text. Stattdessen: „anerkannte Bedarfssystematik" (DE) / „a recognised needs hierarchy" (EN) |
| EU-only Datenspeicherung | Hard requirement — kein US-only Hosting |
| Kein Normtext reproduzieren | DIN-77230-Beuth-Text darf nicht wörtlich übernommen werden |
| Keine Finanzberatung | Nur Fakten aus Unterlagen des Nutzers. Niemals Anlage- oder Versicherungsempfehlungen |

---

## Aktueller Stack

```
Flutter (Dart) — iOS, Material 3
├── lib/theme.dart              Editorial Design System (Serif + Sp-Grid)
├── lib/widgets/editorial.dart  Kicker, Hairline, StatRow, PullQuote
├── lib/data/catalog.dart       ContractCategory, ContractCriterion, ContractFieldSpec
├── lib/data/catalog_controller.dart   ChangeNotifier, lädt catalog.json + Supabase
├── lib/data/contracts_controller.dart ChangeNotifier, Vertragsbestand
├── assets/catalog.json         22 Kategorien (kanonische Quelle, Offline-Fallback)
└── test/widget_test.dart       7 Widget-Tests (tall viewport pattern: 1000×2200+)
```

**Backend (entschieden 2026-06-19):** Supabase + AWS Bedrock entfernt. Neuer Stack: **SwiftUI + CloudKit**. Apple Sign-In via CloudKit Container (kein eigener Auth-Server). EU-Datenspeicherung via iCloud. Flutter-Codebase bleibt als Referenz/Archiv.

**Android-Strategie:** Wenn Marktbedarf entsteht → separates Produkt in Kotlin/Jetpack Compose + Firebase. Kein Port, kein Kompromiss in der iOS-App.

---

## Architektur (festgelegt)

- **SwiftUI** — iOS (iPhone + iPad), macOS via Catalyst möglich
- **CloudKit** — Private Database für Verträge, Public Database für Katalog-Updates
- **Apple Sign-In** — Auth automatisch über CloudKit Container (iCloud Account)
- **Apple Vision** — On-device OCR für Dokumenten-Extraktion (kein Cloud-Dienst nötig)
- **catalog.json** — Katalog bleibt im App-Bundle (kein Server nötig)

---

## Katalog-Systematik (22 Kategorien)

Drei Stufen nach anerkannter Bedarfssystematik:

- **Stufe 1** — Existenzielle Grundabsicherung: Privathaftpflicht, BU, Kranken, Pflege, Risikoleben, Unfall, Hausrat, Wohngebäude, Rechtsschutz, Kfz, Tierhalterhaftpflicht
- **Stufe 2** — Vermögensaufbau & Vorsorge: Liquiditätsreserve, Altersvorsorge, Lebensversicherung, Immobilienfinanzierung, Bausparvertrag, Depot, Sparplan, Tagesgeld/Festgeld
- **Stufe 3** — Ergänzungen: Sterbegeld, Reiseversicherung, Krankentagegeld

Leistungskriterien (für inhaltlichen Vergleich) hinterlegt für: Privathaftpflicht (8), BU (5), Hausrat (5), Kfz (7), Rechtsschutz (6), Risikoleben (5), Reise (5).

---

## Design System

`theme.dart` + `widgets/editorial.dart`:

```dart
FinColors.cream / .ink / .muted / .gold (Terrakotta) / .green
Sp.xs=4 / .sm=8 / .md=12 / .lg=16 / .xl=20 / .xxl=24 / .xxxl=32
serif(size, weight, color, height, spacing)   // New York font
Kicker / Hairline / EditorialHeader / StatRow / PullQuote
```

Dark Mode via `context.isDark` — alle Farben über Context-Extensions (`context.inkColor`, `context.paperColor`, etc.).

---

## Datenschicht (aktuell Flutter)

- `AppConfig.forceMock = true` → Mock-Repository (kein Netz, für Tests)
- Mock-Bestand: 11 Verträge, davon 2× Privathaftpflicht (HUK + AXA) → triggert Dopplung-Insight + Compare
- `catalogController.load()` → lädt `assets/catalog.json` (Offline) oder Supabase (Live)
- `contractsController.insights` → `FinInsights.from()` — deterministisch, keine KI

---

## Tests

```bash
cd app && flutter test          # 7 Widget-Tests + 2 Unit-Tests
cd app && flutter analyze       # Muss sauber sein (0 Issues)
```

**Tall viewport pattern** (obligatorisch für Editorial-Layouts):
```dart
tester.view.physicalSize = const Size(1000, 2200);
tester.view.devicePixelRatio = 1.0;
addTearDown(tester.view.resetPhysicalSize);
```

`HomeShell._screens` muss ein **non-const getter** sein (kein `const` List) — sonst bricht Locale-Switching.

---

## Offene Punkte

- [ ] Backend-Entscheidung: CloudKit vs. Alternative (Firebase, eigener Server, Supabase-Rückkehr)
- [ ] Dokumenten-Extraktion: Ersatz für AWS Bedrock
- [ ] Apple/Google OAuth konfigurieren (falls Supabase zurückkommt)
- [ ] iPhone-Deployment (Simulator „server died"-Fehler noch nicht gelöst)
- [ ] Legal-Review vor Launch (Disclaimer-Texte, Bedarfssystematik-Formulierungen)
- [ ] Leistungskriterien für Unfallversicherung, Wohngebäude, Pflegeversicherung ergänzen
