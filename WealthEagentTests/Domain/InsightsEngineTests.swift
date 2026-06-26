// InsightsEngineTests.swift
// Priority 1 — InsightsEngine (pure function, highest value)
//
// Swift Testing framework (import Testing).
// @Suite grouping per feature area.
// @Test with #expect macros.
// All tests except the first are skipped (withKnownIssue) — enable one at a time in DELIVER.
//
// FIRST TEST TO ENABLE IN DELIVER: duplicatePrivathaftpflichtProducesDopplung
//
// Contract shapes:
//   @contract-shape:pure-function — InsightsEngine has no I/O, no mutation
//   All assertions: call InsightsEngine.insights(contracts:catalog:), check returned FinInsights
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import Foundation
import Testing
@testable import WealthEagent

// MARK: - Test Fixtures

private let mockCatalog = MockCatalogProvider().catalog()

// MARK: - Suite: InsightsEngine — Duplicate detection

@Suite("InsightsEngine — Dopplung (Duplicate detection)")
struct InsightsEngineDuplicateTests {

    /// FIRST TEST TO ENABLE IN DELIVER.
    /// Walking skeleton for InsightsEngine: two Privathaftpflicht contracts → 1 DopplungBeobachtung.
    /// @contract-shape:bounded-change (InsightsEngine mutates no state; the output is bounded by the two contracts)
    @Test("Zwei Privathaftpflicht-Verträge erzeugen eine Dopplung-Beobachtung")
    func duplicatePrivathaftpflichtProducesDopplung() throws {
        let contracts = [
            MockContractRepository.hukPrivathaftpflicht(),
            MockContractRepository.axaPrivathaftpflicht()
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        let duplicates = insights.duplicates
        #expect(duplicates.count == 1)
        #expect(duplicates.first?.categoryKey == "privathaftpflicht")
        #expect(duplicates.first?.kind == .duplicate)
    }

    /// One Privathaftpflicht only → no DopplungBeobachtung.
    /// @contract-shape:pure-function
    @Test("Ein einziger Privathaftpflicht-Vertrag erzeugt keine Dopplung")
    func singlePrivathaftpflichtNoDuplicate() throws {
        let contracts = [MockContractRepository.hukPrivathaftpflicht()]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        #expect(insights.duplicates.isEmpty)
    }

    /// noDuplicate categories: depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve
    /// User can legitimately have multiple depots → no DopplungBeobachtung.
    /// @contract-shape:pure-function
    @Test("Mehrere Depot-Verträge erzeugen keine Dopplung (Portfolio-Kategorie)")
    func depotAllowsMultipleContracts() throws {
        let depot1 = Contract(categoryKey: "depot", provider: "Deutsche Bank")
        let depot2 = Contract(categoryKey: "depot", provider: "Comdirect")

        let insights = InsightsEngine.insights(contracts: [depot1, depot2], catalog: mockCatalog)

        let depotDuplicates = insights.duplicates.filter { $0.categoryKey == "depot" }
        #expect(depotDuplicates.isEmpty, "Depot is a portfolio category — multiple entries are expected, not a Dopplung")
    }

    /// noDuplicate: sparplan — multiple savings plans are normal behaviour.
    /// @contract-shape:pure-function
    @Test("Mehrere Sparpläne erzeugen keine Dopplung (Portfolio-Kategorie)")
    func sparplanAllowsMultipleContracts() throws {
        let sp1 = Contract(categoryKey: "sparplan", provider: "ING")
        let sp2 = Contract(categoryKey: "sparplan", provider: "Scalable Capital")

        let insights = InsightsEngine.insights(contracts: [sp1, sp2], catalog: mockCatalog)

        let sparplanDuplicates = insights.duplicates.filter { $0.categoryKey == "sparplan" }
        #expect(sparplanDuplicates.isEmpty)
    }

    /// noDuplicate: tagesgeld_festgeld — multiple savings accounts are expected.
    /// @contract-shape:pure-function
    @Test("Mehrere Tagesgeld/Festgeld-Konten erzeugen keine Dopplung (Portfolio-Kategorie)")
    func tagesgeldAllowsMultipleContracts() throws {
        let tg1 = Contract(categoryKey: "tagesgeld_festgeld", provider: "ING")
        let tg2 = Contract(categoryKey: "tagesgeld_festgeld", provider: "DKB")

        let insights = InsightsEngine.insights(contracts: [tg1, tg2], catalog: mockCatalog)

        let tgDuplicates = insights.duplicates.filter { $0.categoryKey == "tagesgeld_festgeld" }
        #expect(tgDuplicates.isEmpty)
    }

    /// noDuplicate: liquiditaetsreserve.
    /// @contract-shape:pure-function
    @Test("Mehrere Liquiditätsreserven erzeugen keine Dopplung (Portfolio-Kategorie)")
    func liquiditaetsreserveAllowsMultipleContracts() throws {
        let lr1 = Contract(categoryKey: "liquiditaetsreserve", provider: "Sparkasse")
        let lr2 = Contract(categoryKey: "liquiditaetsreserve", provider: "Volksbank")

        let insights = InsightsEngine.insights(contracts: [lr1, lr2], catalog: mockCatalog)

        let lrDuplicates = insights.duplicates.filter { $0.categoryKey == "liquiditaetsreserve" }
        #expect(lrDuplicates.isEmpty)
    }

    /// 3 contracts of same category → exactly 1 DopplungBeobachtung (not 2).
    /// @contract-shape:pure-function
    @Test("Drei Hausrat-Verträge erzeugen genau eine Dopplung-Beobachtung (nicht zwei)")
    func threeContractsSameCategoryProducesOneDuplicate() throws {
        let hr1 = Contract(categoryKey: "hausrat", provider: "DEVK")
        let hr2 = Contract(categoryKey: "hausrat", provider: "Allianz")
        let hr3 = Contract(categoryKey: "hausrat", provider: "HUK-COBURG")

        let insights = InsightsEngine.insights(contracts: [hr1, hr2, hr3], catalog: mockCatalog)

        let hausratDuplicates = insights.duplicates.filter { $0.categoryKey == "hausrat" }
        #expect(hausratDuplicates.count == 1, "One Dopplung per category regardless of how many duplicates")
    }
}

// MARK: - Suite: InsightsEngine — Gap detection (Lücken)

@Suite("InsightsEngine — Lücke (Coverage gap detection)")
struct InsightsEngineGapTests {

    /// Standard fixture has no BU → MissingBeobachtung for berufsunfaehigkeit.
    /// @contract-shape:bounded-change
    @Test("Kein Berufsunfähigkeitsvertrag erzeugt eine Lücken-Beobachtung")
    func missingBerufsunfaehigkeitProducesLuecke() throws {
        // Standard fixture: HUK PHV + AXA PHV + Depot — no BU
        let contracts = MockContractRepository.fixtureContracts()

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        let gaps = insights.missingCategories
        let buGap = gaps.first { $0.categoryKey == "berufsunfaehigkeit" }
        #expect(buGap != nil, "BU is a level-1 category — absent from portfolio → Lücken-Beobachtung expected")
        #expect(buGap?.kind == .missing)
    }

    /// Adding a BU contract removes the BU gap observation.
    /// @contract-shape:bounded-change
    @Test("Vorhandener Berufsunfähigkeitsvertrag erzeugt keine Lücken-Beobachtung")
    func presentBerufsunfaehigkeitNoLuecke() throws {
        var contracts = MockContractRepository.fixtureContracts()
        contracts.append(Contract(categoryKey: "berufsunfaehigkeit", provider: "Allianz"))

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        let buGap = insights.missingCategories.first { $0.categoryKey == "berufsunfaehigkeit" }
        #expect(buGap == nil, "BU present in portfolio — no Lücken-Beobachtung expected")
    }

    /// Gap detection is level-1 only — missing depot (level 2) is NOT a gap observation.
    /// @contract-shape:pure-function
    @Test("Fehlendes Depot (Stufe 2) erzeugt keine Lücken-Beobachtung")
    func missingLevel2CategoryNoLuecke() throws {
        // No depot in this portfolio
        let contracts = [MockContractRepository.hukPrivathaftpflicht()]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        let depotGap = insights.missingCategories.first { $0.categoryKey == "depot" }
        #expect(depotGap == nil, "Level-2 and level-3 categories do not produce gap observations")
    }

    /// All level-1 categories present → no gap observations.
    /// @contract-shape:pure-function
    @Test("Vollständiges Stufe-1-Portfolio erzeugt keine Lücken-Beobachtungen")
    func completeLevel1PortfolioNoGaps() throws {
        let level1Contracts = mockCatalog.level1Categories.map { category in
            Contract(categoryKey: category.key, provider: "TestProvider")
        }

        let insights = InsightsEngine.insights(contracts: level1Contracts, catalog: mockCatalog)

        #expect(insights.missingCategories.isEmpty, "All level-1 categories covered — zero gap observations")
    }
}

// MARK: - Suite: InsightsEngine — Coverage score (Abdeckungsgrad)

@Suite("InsightsEngine — Abdeckungsgrad (Coverage score)")
struct InsightsEngineCoverageScoreTests {

    /// Empty portfolio → coverage score 0, no observations.
    /// @contract-shape:pure-function
    @Test("Leeres Portfolio hat Abdeckungsgrad 0 und keine Beobachtungen")
    func emptyPortfolioScoreZeroNoInsights() throws {
        let insights = InsightsEngine.insights(contracts: [], catalog: mockCatalog)

        #expect(insights.coverageScore == 0)
        #expect(insights.beobachtungen.isEmpty)
    }

    /// N covered / total level-1 → correct integer score 0–100.
    /// Standard fixture has 1 unique level-1 category covered (privathaftpflicht),
    /// 11 level-1 categories total → score = 1/11 × 100 = 9.
    /// @contract-shape:pure-function
    @Test("Abdeckungsgrad spiegelt abgedeckte Stufe-1-Kategorien korrekt wider")
    func coverageScoreReflectsLevel1Coverage() throws {
        // Fixture: PHV (counted once despite 2 contracts) + no BU, no Kranken, etc.
        let contracts = [
            MockContractRepository.hukPrivathaftpflicht(),
            MockContractRepository.axaPrivathaftpflicht(),
            MockContractRepository.depotWithHighTER()   // level-2, not counted
        ]
        let level1Total = mockCatalog.level1Categories.count   // expected: 11
        let expectedScore = Int(Double(1) / Double(level1Total) * 100.0)

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        #expect(insights.coverageScore == expectedScore,
                "1 level-1 category (privathaftpflicht) covered of \(level1Total) → score \(expectedScore)")
    }

    /// All 11 level-1 categories covered → score 100.
    /// @contract-shape:pure-function
    @Test("Vollständiges Stufe-1-Portfolio hat Abdeckungsgrad 100")
    func fullLevel1CoverageScore100() throws {
        let allLevel1 = mockCatalog.level1Categories.map { cat in
            Contract(categoryKey: cat.key, provider: "Provider")
        }

        let insights = InsightsEngine.insights(contracts: allLevel1, catalog: mockCatalog)

        #expect(insights.coverageScore == 100)
    }

    /// Coverage score is an integer in 0–100 range regardless of inputs.
    /// @contract-shape:pure-function
    @Test("Abdeckungsgrad liegt immer zwischen 0 und 100")
    func coverageScoreAlwaysInRange() throws {
        let partialPortfolio = [
            Contract(categoryKey: "privathaftpflicht", provider: "A"),
            Contract(categoryKey: "krankenversicherung", provider: "B"),
            Contract(categoryKey: "hausrat", provider: "C")
        ]

        let insights = InsightsEngine.insights(contracts: partialPortfolio, catalog: mockCatalog)

        #expect(insights.coverageScore >= 0 && insights.coverageScore <= 100,
                "Coverage score must be in range 0–100, got \(insights.coverageScore)")
    }
}

// MARK: - Suite: InsightsEngine — Cost comparison (Kennzahl)

@Suite("InsightsEngine — Kennzahl (Cost comparison observations)")
struct InsightsEngineCostComparisonTests {

    /// Depot with TER ≥ 1.0% → ComparisonBeobachtung (Kennzahl).
    /// @contract-shape:bounded-change
    @Test("Depot mit TER 1,45 % erzeugt eine Kennzahl-Beobachtung")
    func depotHighTERProducesKennzahl() throws {
        let contracts = [MockContractRepository.depotWithHighTER()]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        let comparisons = insights.comparisons
        let depotComparison = comparisons.first { $0.categoryKey == "depot" }
        #expect(depotComparison != nil, "TER 1.45% is above the 1.0% threshold → Kennzahl-Beobachtung expected")
        #expect(depotComparison?.kind == .comparison)
    }

    /// Depot with TER 0.20% → no ComparisonBeobachtung (below threshold).
    /// @contract-shape:pure-function
    @Test("Depot mit TER 0,20 % erzeugt keine Kennzahl-Beobachtung")
    func depotLowTERNoKennzahl() throws {
        var lowCostDepot = Contract(categoryKey: "depot", provider: "Comdirect")
        lowCostDepot.fields = ContractFields(["ter_percent": .number(0.20)])

        let insights = InsightsEngine.insights(contracts: [lowCostDepot], catalog: mockCatalog)

        let depotComparison = insights.comparisons.first { $0.categoryKey == "depot" }
        #expect(depotComparison == nil, "TER 0.20% is below the 1.0% threshold — no comparison observation")
    }

    /// TER exactly at 1.0% boundary triggers the observation (≥ threshold).
    /// @contract-shape:pure-function
    @Test("Depot mit TER genau 1,0 % (Grenzwert) erzeugt eine Kennzahl-Beobachtung")
    func depotTERAtBoundaryProducesKennzahl() throws {
        var boundaryDepot = Contract(categoryKey: "depot", provider: "DWS")
        boundaryDepot.fields = ContractFields(["ter_percent": .number(1.0)])

        let insights = InsightsEngine.insights(contracts: [boundaryDepot], catalog: mockCatalog)

        let comparison = insights.comparisons.first { $0.categoryKey == "depot" }
        #expect(comparison != nil, "TER 1.0% is exactly at threshold — Kennzahl-Beobachtung expected")
    }

    /// No TER field on depot → no ComparisonBeobachtung (cannot measure).
    /// @contract-shape:pure-function
    @Test("Depot ohne TER-Feld erzeugt keine Kennzahl-Beobachtung")
    func depotWithoutTERNoKennzahl() throws {
        let depotNoTER = Contract(categoryKey: "depot", provider: "Baader Bank")
        // No fields set — no TER present

        let insights = InsightsEngine.insights(contracts: [depotNoTER], catalog: mockCatalog)

        let comparison = insights.comparisons.first { $0.categoryKey == "depot" }
        #expect(comparison == nil, "No TER field — cannot compute comparison observation")
    }
}

// MARK: - Suite: InsightsEngine — Combined / walking skeleton

@Suite("InsightsEngine — Gesamtportfolio (Combined scenario tests)")
struct InsightsEngineWalkingSkeletonTests {

    /// Walking skeleton: standard fixture portfolio → exactly the expected observations.
    /// HUK + AXA PHV (Dopplung) + no BU (Lücke) + Depot TER 1.45% (Kennzahl).
    /// @contract-shape:bounded-change
    /// @walking_skeleton
    @Test("Standard-Portfolio erzeugt Dopplung, Lücke und Kennzahl-Beobachtungen")
    func standardFixtureProducesExpectedObservations() throws {
        let contracts = MockContractRepository.fixtureContracts()

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        // Dopplung: privathaftpflicht
        #expect(insights.duplicates.count == 1)
        #expect(insights.duplicates.first?.categoryKey == "privathaftpflicht")

        // Lücke: multiple level-1 categories missing (BU, Kranken, Pflege, etc.)
        #expect(!insights.missingCategories.isEmpty)
        let buGap = insights.missingCategories.first { $0.categoryKey == "berufsunfaehigkeit" }
        #expect(buGap != nil)

        // Kennzahl: depot TER
        #expect(insights.comparisons.count >= 1)

        // Coverage score: only PHV covered from level-1 → low score
        #expect(insights.coverageScore < 50)
    }

    /// Observation text never contains "Empfehlung" or "empfehlen" — domain invariant.
    /// @contract-shape:pure-function
    @Test("Beobachtungstexte enthalten kein Wort 'Empfehlung' oder 'empfehlen'")
    func observationTextsContainNoEmpfehlung() throws {
        let contracts = MockContractRepository.fixtureContracts()

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        for obs in insights.beobachtungen {
            let allText = [obs.titleDe, obs.titleEn, obs.detailDe, obs.detailEn].joined(separator: " ").lowercased()
            #expect(!allText.contains("empfehlung"), "Observation '\(obs.titleDe)' contains banned word 'Empfehlung'")
            #expect(!allText.contains("empfehlen"), "Observation '\(obs.titleDe)' contains banned verb 'empfehlen'")
        }
    }

    /// Observation text never contains "Defino" or "DIN 77230".
    /// @contract-shape:pure-function
    @Test("Beobachtungstexte enthalten keine verbotenen Fachbegriffe (Defino, DIN 77230)")
    func observationTextsContainNoBannedTerms() throws {
        let contracts = MockContractRepository.fixtureContracts()

        let insights = InsightsEngine.insights(contracts: contracts, catalog: mockCatalog)

        for obs in insights.beobachtungen {
            let allText = [obs.titleDe, obs.titleEn, obs.detailDe, obs.detailEn].joined(separator: " ").lowercased()
            #expect(!allText.contains("defino"), "Observation must not reference 'Defino'")
            #expect(!allText.contains("din 77230"), "Observation must not reference 'DIN 77230'")
        }
    }
}

// MARK: - Contract convenience init for tests

private extension Contract {
    init(categoryKey: String, provider: String) {
        self.init(
            id: UUID(),
            categoryKey: categoryKey,
            provider: provider,
            confirmedAt: Date()
        )
    }
}
