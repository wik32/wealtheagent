// ObservationsViewTests.swift
// Layer 2 — In-memory acceptance (structural wiring check, XCTest)
//
// @contract-shape:bounded-change
// Driving port: ObservationsViewModel (initialised with MockContractRepository + MockCatalogProvider)
// All tests: XCTSkip (one-at-a-time strategy, ADR-025) — enable after DashboardView skeleton is GREEN
//
// What these tests verify:
//   1. ObservationsView compiles and accepts ObservationsViewModel (wiring check)
//   2. Portfolio with duplicate contracts yields at least one "Dopplung" Beobachtung
//   3. Empty portfolio yields empty Beobachtungen list (no phantom observations)
//
// Business language constraint (Pillar 1):
//   "Beobachtungen", "Dopplung", "Lücke" — no "Empfehlung" anywhere.

import XCTest
@testable import WealthEagent

@MainActor
final class ObservationsViewTests: XCTestCase {

    // MARK: - Walking Skeleton

    /// @walking_skeleton @driving_port
    /// @contract-shape:bounded-change
    ///
    /// Verifies: ObservationsView compiles and accepts ObservationsViewModel without crash.
    func testObservationsViewInitializesWithViewModel() throws {

        let vm = ObservationsViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts()),
            catalogProvider: MockCatalogProvider()
        )
        XCTAssertNoThrow(ObservationsView(viewModel: vm))
    }

    // MARK: - Focused scenarios

    /// @contract-shape:bounded-change
    ///
    /// Given: portfolio with 2 Privathaftpflicht contracts (HUK + AXA)
    /// When: Beobachtungen are loaded
    /// Then: at least one Beobachtung of kind "Dopplung" is present
    ///
    /// Business value: user can see that two policies cover the same risk — factual, not advisory.
    func testDopplungBeobachtungErscheintBeiZweiGleichenVertraegen() async throws {

        let vm = ObservationsViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts()),
            catalogProvider: MockCatalogProvider()
        )
        await vm.loadInsights()
        let duplicates = vm.insights.duplicates
        XCTAssertFalse(duplicates.isEmpty,
            "Zwei Privathaftpflicht-Verträge sollten eine Dopplung-Beobachtung erzeugen")
    }

    /// @contract-shape:bounded-change @error
    ///
    /// Given: no confirmed contracts in portfolio
    /// When: Beobachtungen are loaded
    /// Then: Beobachtungen list is empty (empty-state text visible to user)
    ///
    /// Business value: empty state is honest — no phantom observations appear.
    func testLeerePortfolioZeigtKeineBeobachtungen() async throws {

        let vm = ObservationsViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.emptyPortfolio()),
            catalogProvider: MockCatalogProvider()
        )
        await vm.loadInsights()
        XCTAssertTrue(vm.insights.isEmpty,
            "Leeres Portfolio sollte keine Beobachtungen erzeugen")
    }
}
