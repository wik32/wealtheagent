// InsightsEngineTests.swift
// FinanzAppTests — Domain Tests (Priority 1)
//
// Tests for InsightsEngine.insights(contracts:catalog:) — pure function.
// Uses Swift Testing framework (import Testing) for pure unit tests.
//
// Contract shape: pure-function (no I/O, no mutation)
// All tests are RED against the scaffold. Enable one at a time in DELIVER.
//
// Domain invariant enforced here:
//   - Output never contains "Empfehlung" or "empfehlen" in title/detail strings.
//   - Observations are factual Beobachtungen, not advice.
//
// Walking skeleton first, then happy-path, then error/edge (≥40%).

import Testing
@testable import FinanzApp

// MARK: - Walking Skeleton

/// Walking skeleton: user with 2 Privathaftpflicht contracts sees a duplicate observation,
/// and a user with no Berufsunfähigkeit sees a gap observation.
/// This is the end-to-end proof that InsightsEngine delivers observable user value.
@Suite("InsightsEngine — Walking Skeleton")
struct InsightsEngineWalkingSkeletonTests {

    let catalog = MockCatalogFixtures.standard

    @Test("User with 2 Privathaftpflicht contracts sees 1 duplicate observation")
    func userWithTwoPrivathaftpflichtContractsSeesDuplicateObservation() {
        // Given: 2 confirmed Privathaftpflicht contracts in the portfolio
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.axaPrivathaftpflicht
        ]

        // When: insights are computed
        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        // Then: exactly 1 duplicate observation for privathaftpflicht
        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.count == 1)
        #expect(duplicates.first?.categoryKey == "privathaftpflicht")
    }

    @Test("User with no Berufsunfähigkeit contract sees 1 gap observation")
    func userWithNoBerufsunfaehigkeitSeesGapObservation() {
        // Given: portfolio without any Berufsunfähigkeit contract
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.krankenversicherung
        ]

        // When: insights are computed
        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        // Then: at least 1 missing observation for berufsunfaehigkeit
        let gapForBU = insights.observations.filter {
            $0.kind == .missing && $0.categoryKey == "berufsunfaehigkeit"
        }
        #expect(gapForBU.count == 1)
    }
}

// MARK: - Priority 1a: Duplicate Detection

@Suite("InsightsEngine — Duplicate Detection")
struct InsightsEngineDuplicateTests {

    let catalog = MockCatalogFixtures.standard

    @Test("Two contracts of same category produce 1 duplicate observation")
    func twoContractsSameCategoryProduceDuplicateObservation() {
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.axaPrivathaftpflicht
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.count == 1)
        #expect(duplicates[0].categoryKey == "privathaftpflicht")
        #expect(duplicates[0].kind == .duplicate)
    }

    @Test("Single contract of any category produces no duplicate observation")
    func singleContractProducesNoDuplicateObservation() {
        let contracts = [MockContractFixtures.hukPrivathaftpflicht]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty)
    }

    @Test("Empty portfolio produces no duplicate observations")
    func emptyPortfolioProducesNoDuplicateObservations() {
        let insights = InsightsEngine.insights(contracts: [], catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty)
    }

    // MARK: noDuplicate types — depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve

    @Test("Two depot contracts do not produce a duplicate observation")
    func twoDepotContractsDoNotProduceDuplicateObservation() {
        let depot1 = Contract(
            id: UUID(),
            categoryKey: "depot",
            provider: "Comdirect",
            fieldsJSON: "{}"
        )
        let depot2 = Contract(
            id: UUID(),
            categoryKey: "depot",
            provider: "ING",
            fieldsJSON: "{}"
        )

        let insights = InsightsEngine.insights(contracts: [depot1, depot2], catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty, "depot is a noDuplicate type — two depots are valid")
    }

    @Test("Two sparplan contracts do not produce a duplicate observation")
    func twoSparplanContractsDoNotProduceDuplicateObservation() {
        let sparplan1 = Contract(id: UUID(), categoryKey: "sparplan", provider: "ING", fieldsJSON: "{}")
        let sparplan2 = Contract(id: UUID(), categoryKey: "sparplan", provider: "DKB", fieldsJSON: "{}")

        let insights = InsightsEngine.insights(contracts: [sparplan1, sparplan2], catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty, "sparplan is a noDuplicate type")
    }

    @Test("Two tagesgeld_festgeld contracts do not produce a duplicate observation")
    func twoTagesgeldContractsDoNotProduceDuplicateObservation() {
        let tg1 = Contract(id: UUID(), categoryKey: "tagesgeld_festgeld", provider: "DKB", fieldsJSON: "{}")
        let tg2 = Contract(id: UUID(), categoryKey: "tagesgeld_festgeld", provider: "Consorsbank", fieldsJSON: "{}")

        let insights = InsightsEngine.insights(contracts: [tg1, tg2], catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty, "tagesgeld_festgeld is a noDuplicate type")
    }

    @Test("Two liquiditaetsreserve contracts do not produce a duplicate observation")
    func twoLiquiditaetsreserveContractsDoNotProduceDuplicateObservation() {
        let lr1 = Contract(id: UUID(), categoryKey: "liquiditaetsreserve", provider: "Sparkasse", fieldsJSON: "{}")
        let lr2 = Contract(id: UUID(), categoryKey: "liquiditaetsreserve", provider: "DKB", fieldsJSON: "{}")

        let insights = InsightsEngine.insights(contracts: [lr1, lr2], catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        #expect(duplicates.isEmpty, "liquiditaetsreserve is a noDuplicate type")
    }

    @Test("Three contracts of same category produce exactly 1 duplicate observation")
    func threeContractsSameCategoryProduceOneDuplicateObservation() {
        let contract3 = Contract(id: UUID(), categoryKey: "privathaftpflicht", provider: "Signal Iduna", fieldsJSON: "{}")
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.axaPrivathaftpflicht,
            contract3
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let duplicates = insights.observations.filter { $0.kind == .duplicate && $0.categoryKey == "privathaftpflicht" }
        #expect(duplicates.count == 1, "One duplicate observation regardless of how many duplicates exist")
    }

    // MARK: Domain invariant: no "Empfehlung" in output

    @Test("Duplicate observation title contains no banned term 'Empfehlung'")
    func duplicateObservationTitleContainsNoBannedTerms() {
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.axaPrivathaftpflicht
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        for observation in insights.observations {
            #expect(!observation.title.contains("Empfehlung"), "Title must not contain 'Empfehlung'")
            #expect(!observation.title.contains("empfehlen"), "Title must not contain 'empfehlen'")
            #expect(!observation.detail.contains("Empfehlung"), "Detail must not contain 'Empfehlung'")
            #expect(!observation.detail.contains("empfehlen"), "Detail must not contain 'empfehlen'")
        }
    }
}

// MARK: - Priority 1b: Gap Detection (Missing Level-1 Categories)

@Suite("InsightsEngine — Gap Detection")
struct InsightsEngineGapTests {

    let catalog = MockCatalogFixtures.standard

    @Test("Portfolio missing Berufsunfähigkeit produces 1 gap observation for that category")
    func portfolioMissingBUProducesGapObservation() {
        // Given: portfolio without Berufsunfähigkeit
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.krankenversicherung,
            MockContractFixtures.hausrat
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let buGap = insights.observations.filter { $0.kind == .missing && $0.categoryKey == "berufsunfaehigkeit" }
        #expect(buGap.count == 1)
    }

    @Test("Portfolio with a contract for every level-1 category produces no gap observations")
    func fullLevel1CoverageProducesNoGapObservations() {
        // Given: one contract for each of the 11 level-1 categories
        let level1Keys = MockCatalogFixtures.allCategories
            .filter { $0.needsLevel == 1 }
            .map { $0.key }

        let contracts = level1Keys.map { key in
            Contract(id: UUID(), categoryKey: key, provider: "Test Provider", fieldsJSON: "{}")
        }

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let gaps = insights.observations.filter { $0.kind == .missing }
        #expect(gaps.isEmpty, "No gaps when all level-1 categories are covered")
    }

    @Test("Empty portfolio produces gap observations for all 11 level-1 categories")
    func emptyPortfolioProducesGapsForAllLevel1Categories() {
        let insights = InsightsEngine.insights(contracts: [], catalog: catalog)

        let gaps = insights.observations.filter { $0.kind == .missing }
        #expect(gaps.count == 11, "All 11 level-1 categories should show as gaps")
    }

    @Test("Gap observation for level-1 category is absent when category is present in portfolio")
    func gapObservationAbsentWhenCategoryPresent() {
        let contracts = [MockContractFixtures.hukPrivathaftpflicht]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let phvGap = insights.observations.filter { $0.kind == .missing && $0.categoryKey == "privathaftpflicht" }
        #expect(phvGap.isEmpty, "privathaftpflicht is present — no gap should be produced")
    }

    @Test("Level-2 and level-3 categories do not produce gap observations")
    func level2And3CategoriesDoNotProduceGapObservations() {
        // Given: portfolio with only level-2/3 contracts and no level-1
        let contracts = [
            MockContractFixtures.depot,
            MockContractFixtures.sparplan,
            MockContractFixtures.tagesgeld
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        // Then: gaps exist for level-1 but NOT for depot/sparplan/tagesgeld themselves
        let depotGap = insights.observations.filter { $0.kind == .missing && $0.categoryKey == "depot" }
        #expect(depotGap.isEmpty, "depot is level-2 — should not produce a gap observation")
    }

    @Test("Gap observation detail does not use frame 'solltest du' (advice framing)")
    func gapObservationDetailDoesNotUseAdviceFraming() {
        let insights = InsightsEngine.insights(contracts: [], catalog: catalog)

        for observation in insights.observations.filter({ $0.kind == .missing }) {
            #expect(!observation.detail.contains("solltest"), "Detail must not use advice framing 'solltest'")
            #expect(!observation.detail.contains("Empfehlung"), "Detail must not use 'Empfehlung'")
        }
    }
}

// MARK: - Priority 1c: Coverage Score

@Suite("InsightsEngine — Coverage Score")
struct InsightsEngineCoverageScoreTests {

    let catalog = MockCatalogFixtures.standard

    @Test("Empty portfolio has coverage score of 0.0")
    func emptyPortfolioHasCoverageScoreZero() {
        let insights = InsightsEngine.insights(contracts: [], catalog: catalog)
        #expect(insights.coverageScore == 0.0)
    }

    @Test("Portfolio covering all 11 level-1 categories has coverage score of 1.0")
    func fullLevel1CoverageHasCoverageScore1() {
        let level1Keys = MockCatalogFixtures.allCategories
            .filter { $0.needsLevel == 1 }
            .map { $0.key }

        let contracts = level1Keys.map { key in
            Contract(id: UUID(), categoryKey: key, provider: "Provider", fieldsJSON: "{}")
        }

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
        #expect(insights.coverageScore == 1.0)
    }

    @Test("Portfolio covering 5 of 11 level-1 categories has coverage score of approximately 5/11")
    func portfolioCovering5of11HasCorrectCoverageScore() {
        // Given: exactly 5 distinct level-1 categories covered
        let level1Keys = MockCatalogFixtures.allCategories
            .filter { $0.needsLevel == 1 }
            .prefix(5)
            .map { $0.key }

        let contracts = level1Keys.map { key in
            Contract(id: UUID(), categoryKey: key, provider: "Provider", fieldsJSON: "{}")
        }

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
        let expected = 5.0 / 11.0
        #expect(abs(insights.coverageScore - expected) < 0.001)
    }

    @Test("Level-2 and level-3 contracts do not contribute to coverage score")
    func level2And3ContractsDoNotContributeToCoverageScore() {
        // Given: only level-2 contracts, no level-1
        let contracts = [
            MockContractFixtures.depot,
            MockContractFixtures.sparplan,
            MockContractFixtures.altersvorsorge
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
        #expect(insights.coverageScore == 0.0, "Only level-1 categories count toward coverage score")
    }

    @Test("Two contracts with same level-1 category key count as 1 covered category")
    func twoContractsSameCategoryCountAsOneCovered() {
        // Given: 2 Privathaftpflicht = still only 1 out of 11 covered
        let contracts = [
            MockContractFixtures.hukPrivathaftpflicht,
            MockContractFixtures.axaPrivathaftpflicht
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
        let expected = 1.0 / 11.0
        #expect(abs(insights.coverageScore - expected) < 0.001)
    }

    @Test("Coverage score is between 0.0 and 1.0 for any portfolio")
    func coverageScoreIsAlwaysBetweenZeroAndOne() {
        for contracts in [
            [],
            [MockContractFixtures.hukPrivathaftpflicht],
            MockContractFixtures.all
        ] {
            let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
            #expect(insights.coverageScore >= 0.0)
            #expect(insights.coverageScore <= 1.0)
        }
    }
}

// MARK: - Priority 1d: Cost Comparison (TER)

@Suite("InsightsEngine — Cost Comparison")
struct InsightsEngineCostComparisonTests {

    let catalog = MockCatalogFixtures.standard

    @Test("Depot contract with TER 1.45% produces 1 comparison observation")
    func depotWithHighTERProducesComparisonObservation() {
        let contracts = [MockContractFixtures.depot]  // TER 1.45% in fixture

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let comparisons = insights.observations.filter { $0.kind == .comparison }
        #expect(comparisons.count == 1)
        #expect(comparisons[0].categoryKey == "depot")
    }

    @Test("Depot contract with TER 0.20% does not produce a comparison observation")
    func depotWithLowTERProducesNoComparisonObservation() {
        let cheapDepot = Contract(
            id: UUID(),
            categoryKey: "depot",
            provider: "ING",
            fieldsJSON: """
            {"positions": [{"isin": "IE00B4L5Y983", "ter": 0.20, "name": "iShares MSCI World"}]}
            """
        )

        let insights = InsightsEngine.insights(contracts: [cheapDepot], catalog: catalog)

        let comparisons = insights.observations.filter { $0.kind == .comparison }
        #expect(comparisons.isEmpty, "TER 0.20% is below the 1.0% threshold — no comparison needed")
    }

    @Test("Depot contract with TER exactly 1.0% produces a comparison observation")
    func depotWithTERExactlyAtThresholdProducesComparisonObservation() {
        let borderlineDepot = Contract(
            id: UUID(),
            categoryKey: "depot",
            provider: "Some Bank",
            fieldsJSON: """
            {"positions": [{"isin": "DE0000000001", "ter": 1.0, "name": "Test Fund"}]}
            """
        )

        let insights = InsightsEngine.insights(contracts: [borderlineDepot], catalog: catalog)

        let comparisons = insights.observations.filter { $0.kind == .comparison }
        #expect(comparisons.count == 1, "TER exactly 1.0% should trigger the observation")
    }

    @Test("Depot with no positions field produces no comparison observation")
    func depotWithNoPositionsProducesNoComparisonObservation() {
        let depotNoPositions = Contract(
            id: UUID(),
            categoryKey: "depot",
            provider: "Empty Depot Bank",
            fieldsJSON: "{}"
        )

        let insights = InsightsEngine.insights(contracts: [depotNoPositions], catalog: catalog)

        let comparisons = insights.observations.filter { $0.kind == .comparison }
        #expect(comparisons.isEmpty, "Depot with no positions data cannot have a TER observation")
    }

    @Test("Non-depot contracts do not produce TER comparison observations")
    func nonDepotContractsDoNotProduceTERObservations() {
        let contracts = [
            MockContractFixtures.krankenversicherung,
            MockContractFixtures.hausrat,
            MockContractFixtures.rechtsschutz
        ]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        let comparisons = insights.observations.filter { $0.kind == .comparison }
        #expect(comparisons.isEmpty)
    }

    @Test("Comparison observation detail uses measurement framing, not advice framing")
    func comparisonObservationUsesMeasurementFraming() {
        let contracts = [MockContractFixtures.depot]

        let insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)

        for comparison in insights.observations.filter({ $0.kind == .comparison }) {
            #expect(!comparison.detail.contains("zu teuer"), "Must not frame as 'zu teuer' — use measurement framing")
            #expect(!comparison.detail.contains("solltest"), "Must not use advice framing")
            #expect(!comparison.detail.contains("Empfehlung"), "Must not use 'Empfehlung'")
        }
    }
}

// MARK: - Priority 1e: Full Portfolio Integration

@Suite("InsightsEngine — Full Portfolio (11 Contracts)")
struct InsightsEngineFullPortfolioTests {

    let catalog = MockCatalogFixtures.standard

    @Test("Standard 11-contract fixture produces expected observation types")
    func standardFixtureProducesExpectedObservations() {
        let insights = InsightsEngine.insights(
            contracts: MockContractFixtures.all,
            catalog: catalog
        )

        // Should have: 1 duplicate (privathaftpflicht), 1 comparison (depot TER), N missing gaps
        let duplicates = insights.observations.filter { $0.kind == .duplicate }
        let comparisons = insights.observations.filter { $0.kind == .comparison }
        let missing = insights.observations.filter { $0.kind == .missing }

        #expect(duplicates.count == 1, "Exactly 1 duplicate (2x privathaftpflicht)")
        #expect(comparisons.count == 1, "Exactly 1 comparison (depot TER 1.45%)")
        #expect(missing.count >= 1, "At least berufsunfaehigkeit is missing")
    }

    @Test("Standard fixture has berufsunfaehigkeit in gap observations")
    func standardFixtureHasBUInGaps() {
        let insights = InsightsEngine.insights(
            contracts: MockContractFixtures.all,
            catalog: catalog
        )

        let buGap = insights.observations.filter { $0.kind == .missing && $0.categoryKey == "berufsunfaehigkeit" }
        #expect(buGap.count == 1)
    }

    @Test("Coverage score for standard fixture accounts for covered level-1 categories")
    func standardFixtureCoverageScore() {
        let insights = InsightsEngine.insights(
            contracts: MockContractFixtures.all,
            catalog: catalog
        )

        // Level-1 categories covered: privathaftpflicht, krankenversicherung, hausrat,
        //   rechtsschutz, kfz, risikoleben = 6 out of 11
        // NOT covered: berufsunfaehigkeit, pflegeversicherung, unfallversicherung,
        //   wohngebaeude, tierhalterhaftpflicht = 5 missing
        let expectedScore = 6.0 / 11.0
        #expect(abs(insights.coverageScore - expectedScore) < 0.001)
    }
}
