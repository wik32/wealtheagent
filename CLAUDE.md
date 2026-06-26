# WealthEagent — CLAUDE.md

## Was ist das?

Provisionsfrei, transparent, EU-only. Eine B2C-App für Deutschland, die Nutzern hilft, ihre Versicherungen und Finanzverträge zu überblicken.

**Stage 1 — „messen, nicht empfehlen"**: Die App zeigt Fakten aus eigenen Unterlagen. Keine Produktempfehlungen, kein Vergleichsportal, kein Affiliate.

---

## Nicht verhandelbare Regeln (immer einhalten)

| Regel | Detail |
|---|---|
| Kein „empfehlen/Empfehlung" | In user-facing Text nie verwenden. Stattdessen: „Beobachtungen", „Fakten", „wir messen" |
| Kein „Defino" / „DIN 77230" | Nirgends verwenden — weder UI noch Code-Kommentare noch Docs |
| EU-only Datenspeicherung | Hard requirement — iCloud erfüllt das für EU-Nutzer |
| Keine Finanzberatung | Nur Fakten aus Unterlagen des Nutzers. Niemals Anlage- oder Versicherungsempfehlungen |

---

## Stack (festgelegt)

- **SwiftUI** — iOS 17+, iPhone + iPad
- **CloudKit** — Private Database für Verträge, Apple Sign-In via iCloud Account
- **Apple Vision** — On-device OCR, kein Cloud-Dienst
- **Swift Package Manager** — keine 3rd-party Architektur-Frameworks
- **Swift Testing + XCTest** — Testframework

**Android:** Separates Produkt (Kotlin + Firebase) wenn Marktbedarf entsteht. Kein Port.

---

## Architektur (festgelegt, siehe docs/product/architecture/)

**MVVM + Protocol-Typed Ports (Option B)**

```
Views → ViewModels (@Observable) → Ports (Protokolle) → Domain
                                          ↑
                                     Adapters (CloudKit, Vision, Bundle)
```

- `Domain/` — pure Swift value types, null framework imports
- `Ports/` — Swift protocols (`ContractRepository`, `CatalogProvider`, `DocumentScanner`)
- `Adapters/` — CloudKit, Vision, Bundle-JSON Implementierungen
- `Services/` — pure functions (`InsightsEngine`, `ContractParser`)
- `ViewModels/` — `@Observable` classes, rufen Ports auf
- `Views/` — SwiftUI, nur ViewModels + Domain sehen

**Dependency rule (SwiftLint enforced):**
`Domain` importiert nur Foundation. `Ports` importiert nur Domain. `Adapters` importiert Ports + Apple frameworks. `ViewModels` importiert Ports + Domain. `Views` importiert ViewModels + Domain.

---

## Kategoriensystematik (22 Vertragsarten)

Drei Stufen — Bezeichnung neutral, ohne externe Systematik-Referenz:

- **Stufe 1** — Basisabsicherung: Privathaftpflicht, BU, Kranken, Pflege, Risikoleben, Unfall, Hausrat, Wohngebäude, Rechtsschutz, Kfz, Tierhalterhaftpflicht
- **Stufe 2** — Vermögensaufbau: Liquiditätsreserve, Altersvorsorge, Lebensversicherung, Immobilienfinanzierung, Bausparvertrag, Depot, Sparplan, Tagesgeld/Festgeld
- **Stufe 3** — Ergänzungen: Sterbegeld, Reiseversicherung, Krankentagegeld

Leistungskriterien werden neu aufgesetzt auf Basis von Stiftung Warentest / Morgen & Morgen — nicht aus DIN 77230.

---

## CloudKit Schema

- Zone: `FinanzAppZone` (Custom Zone, Private Database)
- Record-Typen: `CDContract`, `CDPendingContract`, `CDUserProfile`
- `fieldsJSON` als String (~1 KB pro Vertrag)
- Canary-Probe beim App-Start prüft tatsächliche Write-Permission

---

## Tests

- Pure functions (`InsightsEngine`, `ContractParser`) → Swift Testing (`#expect`)
- ViewModels mit Mock-Ports → XCTest
- Scaffold-Marker: `// SCAFFOLD: true` + `fatalError("Not yet implemented")`

---

## Offene Punkte

- [ ] Xcode-Projekt anlegen (Bundle-ID: `de.wealtheagent.app`, CloudKit-Container: `iCloud.de.wealtheagent.app`)
- [ ] Leistungskriterien neu recherchieren (Stiftung Warentest, Morgen & Morgen)
- [ ] Legal-Review vor Launch (Disclaimer-Texte)
- [ ] SwiftLint-Regeln für Layer-Enforcement einrichten
