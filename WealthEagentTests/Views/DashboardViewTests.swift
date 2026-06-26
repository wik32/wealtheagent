// DashboardViewTests.swift
// Layer 2 — In-memory acceptance (structural wiring check, XCTest)
//
// @contract-shape:bounded-change
// Driving port: DashboardViewModel (initialised with MockContractRepository + MockCatalogProvider)
// Walking skeleton: testDashboardViewInitializesWithViewModel — LIVE (first test, unblocked)
// All other tests: XCTSkip (one-at-a-time strategy, ADR-025)
//
// What these tests verify (value proposition for thin-View tests):
//   1. DashboardView compiles and accepts DashboardViewModel — catches wiring regressions early
//   2. ViewModel observable state (coverageScore, monthlySpend) reflects loaded portfolio
//   3. Empty-portfolio state yields coverageScore == 0 and monthlySpend == 0.0
//
// Business language constraint (Pillar 1):
//   Test names use domain terms: "Abdeckungsgrad", "Ausgaben", "Verträge".
//   No technical terms ("HTTP", "JSON", "endpoint") in test names.

import XCTest
@testable import WealthEagent

@MainActor
final class DashboardViewTests: XCTestCase {

    // MARK: - Walking Skeleton (LIVE)

    /// @walking_skeleton @driving_port
    /// @contract-shape:bounded-change
    ///
    /// Verifies: DashboardView compiles and accepts DashboardViewModel without crash.
    /// This is the wiring check — catches init-signature mismatches and missing imports.
    func testDashboardViewInitializesWithViewModel() {
        let vm = DashboardViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts()),
            catalogProvider: MockCatalogProvider()
        )
        // Walking skeleton assertion: View can be constructed with its ViewModel.
        // If DashboardView's init signature changes or the ViewModel type is mismatched,
        // this line fails to compile — caught before any UI test is needed.
        XCTAssertNoThrow(DashboardView(viewModel: vm))
    }

    // MARK: - Focused scenarios (XCTSkip — one-at-a-time)

    /// @contract-shape:bounded-change
    ///
    /// Given: portfolio with 3 confirmed contracts (2x Privathaftpflicht + 1 Depot)
    /// When: DashboardViewModel loads the portfolio
    /// Then: Abdeckungsgrad (coverageScore) is greater than 0
    ///
    /// Business value: user sees factual coverage measurement after adding contracts.
    func testAbdeckungsgradIsGreaterThanZeroAfterPortfolioLoaded() async throws {
        throw XCTSkip("Pending — enable in DELIVER after DashboardView body is implemented")

        let vm = DashboardViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts()),
            catalogProvider: MockCatalogProvider()
        )
        await vm.load()
        XCTAssertGreaterThan(vm.coverageScore, 0,
            "Abdeckungsgrad sollte > 0 sein wenn Verträge vorhanden sind")
    }

    /// @contract-shape:bounded-change @error
    ///
    /// Given: no confirmed contracts in portfolio
    /// When: DashboardViewModel loads an empty portfolio
    /// Then: Abdeckungsgrad is 0 and monatliche Ausgaben are 0.00 EUR
    ///
    /// Business value: empty state correctly shows zero coverage — not a phantom score.
    func testLeerePortfolioZeigtNullAbdeckungUndNullAusgaben() async throws {
        throw XCTSkip("Pending — enable in DELIVER after DashboardView empty state is implemented")

        let vm = DashboardViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.emptyPortfolio()),
            catalogProvider: MockCatalogProvider()
        )
        await vm.load()
        XCTAssertEqual(vm.coverageScore, 0,
            "Leeres Portfolio sollte Abdeckungsgrad 0 zeigen")
        XCTAssertEqual(vm.monthlySpend, 0.0, accuracy: 0.01,
            "Leeres Portfolio sollte monatliche Ausgaben von 0,00 EUR zeigen")
    }
}
