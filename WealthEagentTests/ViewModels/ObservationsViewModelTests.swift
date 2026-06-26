// ObservationsViewModelTests.swift
// Layer 2 — In-memory acceptance tests for ObservationsViewModel.
//
// Driving port: ObservationsViewModel.loadInsights()
// Dependencies: MockContractRepository + MockCatalogProvider (in-memory doubles)
// Framework: XCTest (async @Observable ViewModel integration — per ATDD policy)
//
// @contract-shape:bounded-change — ViewModel state mutation bounded to:
//   insights, isLoading, error.
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.
// All observations are Beobachtungen — factual, never advisory.
//
// Test sequence (one enabled at a time for DELIVER):
//   1. testUserWithTwoPrivathaftpflichtSeesDopplungBeobachtung  ← WALKING SKELETON (live RED)
//   2–6: all other tests XCTSkip until skeleton is GREEN.

import XCTest
@testable import WealthEagent

// MARK: - ObservationsViewModelTests

@MainActor
final class ObservationsViewModelTests: XCTestCase {

    // MARK: - setUp / tearDown

    var mockRepo: MockContractRepository!
    var mockCatalog: MockCatalogProvider!

    override func setUp() async throws {
        mockRepo = MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        mockCatalog = MockCatalogProvider()
    }

    override func tearDown() async throws {
        mockRepo = nil
        mockCatalog = nil
    }

    // MARK: ── Walking skeleton ──────────────────────────────────────────────
    //
    // FIRST test to enable in DELIVER.
    // Remove the XCTSkip line when InsightsEngine.insights() is implemented.

    /// Walking skeleton: user with two Privathaftpflicht contracts
    /// sees exactly one Dopplung-Beobachtung in the Observations tab.
    ///
    /// Covers the end-to-end path:
    ///   MockContractRepository → ObservationsViewModel.loadInsights()
    ///   → InsightsEngine.insights(contracts:catalog:) → FinInsights.duplicates
    func testUserWithTwoPrivathaftpflichtSeesDopplungBeobachtung() async throws {
        // Given: user has two Privathaftpflicht contracts
        let repo = MockContractRepository(contracts: [
            MockContractRepository.hukPrivathaftpflicht(),
            MockContractRepository.axaPrivathaftpflicht()
        ])
        let sut = ObservationsViewModel(contractRepository: repo, catalogProvider: mockCatalog)

        // When: ViewModel loads Beobachtungen
        await sut.loadInsights()

        // Then: exactly 1 Dopplung-Beobachtung for Privathaftpflicht is visible
        let dopplungen = sut.insights.duplicates
        XCTAssertEqual(dopplungen.count, 1,
                       "Erwartet 1 Dopplung-Beobachtung, erhalten \(dopplungen.count)")
        XCTAssertEqual(dopplungen.first?.categoryKey, "privathaftpflicht",
                       "Dopplung-Beobachtung muss für privathaftpflicht sein")
        XCTAssertEqual(dopplungen.first?.kind, .duplicate)
    }

    // MARK: ── Happy-path Beobachtungen ──────────────────────────────────────

    /// User with no Berufsunfähigkeit contract sees a Lücken-Beobachtung for BU.
    func testUserWithNoBerufsunfaehigkeitSeesLueckeBeobachtung() async throws {
        throw XCTSkip("Lücken-Beobachtung — enable after walking skeleton is GREEN")

        // Given: fixture portfolio (HUK PHV + AXA PHV + Depot — no BU)
        let sut = ObservationsViewModel(contractRepository: mockRepo, catalogProvider: mockCatalog)

        // When: ViewModel loads Beobachtungen
        await sut.loadInsights()

        // Then: Lücken-Beobachtung for berufsunfaehigkeit is present
        let buLuecke = sut.insights.missingCategories.first {
            $0.categoryKey == "berufsunfaehigkeit"
        }
        XCTAssertNotNil(buLuecke,
                        "Erwartet Lücken-Beobachtung für berufsunfaehigkeit — keine gefunden")
        XCTAssertEqual(buLuecke?.kind, .missing)
    }

    /// User with an empty portfolio sees no Beobachtungen.
    func testEmptyPortfolioProducesNoBeobachtungen() async throws {
        throw XCTSkip("Leeres Portfolio — enable after walking skeleton is GREEN")

        // Given: user has no confirmed contracts
        let emptyRepo = MockContractRepository(contracts: [])
        let sut = ObservationsViewModel(contractRepository: emptyRepo, catalogProvider: mockCatalog)

        // When: ViewModel loads Beobachtungen
        await sut.loadInsights()

        // Then: no Beobachtungen visible (not even gap observations — nothing to measure)
        XCTAssertTrue(sut.insights.isEmpty,
                      "Leeres Portfolio darf keine Beobachtungen produzieren")
    }

    // MARK: ── Error paths ────────────────────────────────────────────────────

    /// When repository is unavailable, ViewModel surfaces the error and keeps insights empty.
    func testRepositoryUnavailableShowsFehlerstatus() async throws {
        throw XCTSkip("Fehlerstatus — enable after walking skeleton is GREEN")

        // Given: repository that always throws
        let failingRepo = MockContractRepository(contracts: [])
        failingRepo.listError = MockRepositoryError.connectionUnavailable
        let sut = ObservationsViewModel(contractRepository: failingRepo, catalogProvider: mockCatalog)

        // When: ViewModel loads Beobachtungen
        await sut.loadInsights()

        // Then: error is surfaced, Beobachtungen remain empty
        XCTAssertNotNil(sut.error, "Verbindungsfehler muss im Fehlerstatus sichtbar sein")
        XCTAssertTrue(sut.insights.isEmpty,
                      "Bei Fehler dürfen keine Beobachtungen angezeigt werden")
    }

    // MARK: ── Loading state ──────────────────────────────────────────────────

    /// isLoading is false before and after loadInsights() completes.
    func testLadeindikatorIsFalseBeforeAndAfterLoad() async throws {
        throw XCTSkip("Ladeindikator — enable after walking skeleton is GREEN")

        // Given: standard repository
        let sut = ObservationsViewModel(contractRepository: mockRepo, catalogProvider: mockCatalog)

        // Before: not loading
        XCTAssertFalse(sut.isLoading, "isLoading muss vor dem Laden false sein")

        // When: ViewModel loads Beobachtungen
        await sut.loadInsights()

        // After: loading finished
        XCTAssertFalse(sut.isLoading, "isLoading muss nach dem Laden false sein")
    }

    // MARK: ── Sign-out ───────────────────────────────────────────────────────

    /// After sign-out, all Beobachtungen are cleared from the ViewModel.
    func testAbmeldenBereingtAlleBeobachtungen() async throws {
        throw XCTSkip("Abmelden — enable after walking skeleton is GREEN")

        // Given: ViewModel with loaded Beobachtungen
        let sut = ObservationsViewModel(contractRepository: mockRepo, catalogProvider: mockCatalog)
        await sut.loadInsights()
        XCTAssertFalse(sut.insights.isEmpty, "Voraussetzung: Beobachtungen vorhanden")

        // When: user signs out
        sut.signOut()

        // Then: Beobachtungen are cleared
        XCTAssertTrue(sut.insights.isEmpty,
                      "Nach Abmelden dürfen keine Beobachtungen angezeigt werden")
        XCTAssertNil(sut.error, "Nach Abmelden muss der Fehlerstatus gelöscht sein")
    }
}

// MARK: - Mock error

enum MockRepositoryError: Error {
    case connectionUnavailable
}
