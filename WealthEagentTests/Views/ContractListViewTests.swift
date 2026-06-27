// ContractListViewTests.swift
// Layer 2 — In-memory acceptance (structural wiring check, XCTest)
//
// @contract-shape:bounded-change
// Driving port: ContractListViewModel (initialised with MockContractRepository)
// All tests: XCTSkip (one-at-a-time strategy, ADR-025) — enable after ObservationsView is GREEN
//
// What these tests verify:
//   1. ContractListView compiles and accepts ContractListViewModel (wiring check)
//   2. Loaded portfolio shows correct contract count
//   3. Empty portfolio triggers empty state (zero contracts, no crash)
//
// Business language constraint (Pillar 1):
//   "Verträge", "Portfolio" — no "API", "database", "endpoint".

import XCTest
@testable import WealthEagent

@MainActor
final class ContractListViewTests: XCTestCase {

    // MARK: - Walking Skeleton

    /// @walking_skeleton @driving_port
    /// @contract-shape:bounded-change
    ///
    /// Verifies: ContractListView compiles and accepts ContractListViewModel without crash.
    func testContractListViewInitializesWithViewModel() throws {

        let vm = ContractListViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        )
        XCTAssertNoThrow(ContractListView(viewModel: vm, catalogProvider: MockCatalogProvider()))
    }

    // MARK: - Focused scenarios

    /// @contract-shape:bounded-change
    ///
    /// Given: portfolio with 3 confirmed contracts
    /// When: contract list is loaded
    /// Then: 3 Verträge are present in the ViewModel's observable state
    ///
    /// Business value: user sees their complete portfolio — no contracts missing from the list.
    func testDreiVertraegeWerdenNachLadenAngezeigt() async throws {

        let vm = ContractListViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        )
        await vm.load()
        XCTAssertEqual(vm.contracts.count, 3,
            "Portfolio mit 3 Verträgen sollte 3 Einträge in der Liste zeigen")
    }

    /// @contract-shape:bounded-change @error
    ///
    /// Given: no confirmed contracts in portfolio
    /// When: contract list is loaded
    /// Then: empty state — zero contracts, no pending contracts, no error
    ///
    /// Business value: new user sees honest empty state, not a broken list.
    func testLeerePortfolioZeigtLeereVertragsliste() async throws {

        let vm = ContractListViewModel(
            contractRepository: MockContractRepository(contracts: MockContractRepository.emptyPortfolio())
        )
        await vm.load()
        XCTAssertTrue(vm.contracts.isEmpty,
            "Leeres Portfolio sollte keine Verträge in der Liste zeigen")
        XCTAssertNil(vm.error,
            "Leeres Portfolio sollte keinen Fehler erzeugen")
    }
}
