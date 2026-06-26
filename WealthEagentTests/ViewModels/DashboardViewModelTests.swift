// DashboardViewModelTests.swift
// Layer 2 — In-memory acceptance tests for DashboardViewModel.
//
// Driving port: DashboardViewModel.load()
// Dependencies: MockContractRepository + MockCatalogProvider (in-memory doubles)
// Framework: XCTest (async @Observable ViewModel integration — per ATDD policy)
//
// @contract-shape:bounded-change — ViewModel state mutation bounded to:
//   coverageScore, monthlySpend, isLoading, error.
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.
//
// Test sequence (one enabled at a time for DELIVER):
//   1. testPortfolioMitElfVertraegenZeigtAbdeckungsgrad  ← FIRST to enable
//   2–4: XCTSkip until (1) is GREEN

import XCTest
@testable import WealthEagent

// MARK: - DashboardViewModelTests

@MainActor
final class DashboardViewModelTests: XCTestCase {

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
    // FIRST DashboardViewModel test to enable in DELIVER.

    /// Fixture portfolio (2 PHV + 1 Depot) produces a coverage score > 0.
    /// Validates that DashboardViewModel.load() calls InsightsEngine and
    /// surfaces the result in the coverageScore property.
    func testPortfolioMitElfVertraegenZeigtAbdeckungsgrad() async throws {
        // Given: fixture portfolio (HUK PHV + AXA PHV + Depot)
        let sut = DashboardViewModel(contractRepository: mockRepo, catalogProvider: mockCatalog)

        // When: Dashboard loads
        await sut.load()

        // Then: coverage score reflects that 1 of 11 level-1 categories is covered (≥1 PHV)
        XCTAssertGreaterThan(sut.coverageScore, 0,
                             "Abdeckungsgrad muss > 0 sein, wenn Verträge vorhanden sind")
        XCTAssertLessThanOrEqual(sut.coverageScore, 100,
                                 "Abdeckungsgrad darf 100 nicht überschreiten")
    }

    // MARK: ── Leeres Portfolio ───────────────────────────────────────────────

    /// Empty portfolio → coverageScore is 0 and monthlySpend is 0.0.
    func testLeemesPortfolioZeigtNullAbdeckungsgrad() async throws {
        // Given: no confirmed contracts
        let emptyRepo = MockContractRepository(contracts: [])
        let sut = DashboardViewModel(contractRepository: emptyRepo, catalogProvider: mockCatalog)

        // When: Dashboard loads
        await sut.load()

        // Then: both metrics are zero
        XCTAssertEqual(sut.coverageScore, 0,
                       "Abdeckungsgrad muss 0 sein, wenn kein Vertrag vorhanden")
        XCTAssertEqual(sut.monthlySpend, 0.0, accuracy: 0.001,
                       "Monatliche Ausgaben müssen 0,00 EUR sein bei leerem Portfolio")
    }

    // MARK: ── Monatliche Ausgaben ────────────────────────────────────────────

    /// Single annual-premium contract → monthlySpend is premium / 12.
    func testJaehrlichesPraemieWirdAufMonatAufgeteilt() async throws {
        // Given: one annual contract at 120 EUR/year
        var contract = MockContractRepository.hukPrivathaftpflicht()
        contract.premiumAmount = 120.00
        contract.premiumInterval = "jaehrlich"

        let repo = MockContractRepository(contracts: [contract])
        let sut = DashboardViewModel(contractRepository: repo, catalogProvider: mockCatalog)

        // When: Dashboard loads
        await sut.load()

        // Then: monthly spend is 10.00 EUR (120 / 12)
        XCTAssertEqual(sut.monthlySpend, 10.00, accuracy: 0.001,
                       "Jahrеsbeitrag 120 EUR muss als 10,00 EUR/Monat ausgewiesen werden")
    }

    // MARK: ── Fehlerstatus ───────────────────────────────────────────────────

    /// Repository failure → error state is surfaced, metrics remain at zero.
    func testRepositoryFehlerZeigtFehlerstatus() async throws {
        // Given: repository that always throws
        let failingRepo = MockContractRepository(contracts: [])
        failingRepo.listError = MockRepositoryError.connectionUnavailable
        let sut = DashboardViewModel(contractRepository: failingRepo, catalogProvider: mockCatalog)

        // When: Dashboard loads
        await sut.load()

        // Then: error is surfaced; metrics remain at zero (not stale data)
        XCTAssertNotNil(sut.error, "Verbindungsfehler muss im Dashboard sichtbar sein")
        XCTAssertEqual(sut.coverageScore, 0,
                       "Abdeckungsgrad muss bei Fehler 0 bleiben")
        XCTAssertEqual(sut.monthlySpend, 0.0, accuracy: 0.001,
                       "Monatliche Ausgaben müssen bei Fehler 0,00 bleiben")
    }
}
