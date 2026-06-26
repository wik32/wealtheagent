// ContractListViewModelTests.swift
// FinanzAppTests — ViewModel Tests (Priority 4, placeholder)
//
// These tests verify observable ViewModel behavior via MockContractRepository.
// Uses XCTest (not Swift Testing) as required for ViewModel + async integration tests.
//
// SCAFFOLD: true — all tests disabled with XCTSkip pending DELIVER wave.
// Enable one at a time. Each enable = one TDD cycle.

import XCTest
@testable import FinanzApp

// MARK: - ContractListViewModel (Priority 3: Contract Persistence via mock)

/// Placeholder class — ContractListViewModel is not yet scaffolded.
/// This file documents the planned test surface for DELIVER.
final class ContractListViewModelTests: XCTestCase {

    var repository: MockContractRepository!

    override func setUp() {
        super.setUp()
        repository = MockContractRepository()
        repository.reset()
    }

    // MARK: - Contract Persistence (Priority 3)

    func test_saveContract_canBeRetrievedById() async throws {
        throw XCTSkip("Pending DELIVER — RED scaffold. Enable when ContractListViewModel is implemented.")

        // Given: a new confirmed contract
        let contract = MockContractFixtures.hukPrivathaftpflicht

        // When: saved via repository
        try await repository.save(contract)

        // Then: can be retrieved by its ID
        let contracts = try await repository.listContracts()
        let found = contracts.first(where: { $0.id == contract.id })
        XCTAssertNotNil(found, "Saved contract should be retrievable by ID")
        XCTAssertEqual(found?.provider, "HUK-COBURG")
        XCTAssertEqual(found?.categoryKey, "privathaftpflicht")
    }

    func test_confirmPendingContract_becomesContractAndRawOCRRemovedFromPending() async throws {
        throw XCTSkip("Pending DELIVER — RED scaffold.")

        // Given: a PendingContract saved to repository
        let pending = PendingContract(
            id: UUID(),
            categoryKey: "privathaftpflicht",
            provider: "HUK-COBURG",
            rawOCRText: "Privathaftpflicht HUK-COBURG Beitrag 7,50€",
            ocrConfidence: 0.95,
            extractedAt: Date()
        )
        try await repository.savePending(pending)

        // When: user confirms the PendingContract
        try await repository.confirm(pending, corrected: nil)

        // Then: PendingContract is gone from pending list
        let pendingList = try await repository.listPendingContracts()
        XCTAssertFalse(pendingList.contains(where: { $0.id == pending.id }),
                       "Confirmed PendingContract must be removed from pending list")

        // And: Contract appears in confirmed list
        let contracts = try await repository.listContracts()
        let confirmed = contracts.first(where: { $0.id == pending.id })
        XCTAssertNotNil(confirmed, "Confirmed contract should appear in contract list")

        // And: rawOCRText is NOT in the returned Contract (it is PendingContract-only data)
        // Contract struct has no rawOCRText field — this is structurally enforced by types
    }

    func test_deleteContract_contractNoLongerInList() async throws {
        throw XCTSkip("Pending DELIVER — RED scaffold.")

        // Given: a contract in the repository
        let contract = MockContractFixtures.hausrat
        try await repository.save(contract)

        // When: the contract is deleted
        try await repository.delete(id: contract.id)

        // Then: the contract is no longer in the list
        let contracts = try await repository.listContracts()
        XCTAssertFalse(contracts.contains(where: { $0.id == contract.id }),
                       "Deleted contract must not appear in list")
    }

    func test_saveMultipleContracts_allRetrievable() async throws {
        throw XCTSkip("Pending DELIVER — RED scaffold.")

        // Given: all 11 fixture contracts
        for contract in MockContractFixtures.all {
            try await repository.save(contract)
        }

        // When: list is fetched
        let contracts = try await repository.listContracts()

        // Then: all 11 are present
        XCTAssertEqual(contracts.count, 11)
    }

    // MARK: - ViewModel Load Behavior (Priority 4, ViewModel not yet implemented)

    func test_onLoad_callsListContracts() async throws {
        throw XCTSkip("Pending DELIVER — ContractListViewModel not yet scaffolded.")
        // When ContractListViewModel is scaffolded:
        // let vm = ContractListViewModel(repository: repository)
        // await vm.load()
        // XCTAssertTrue(repository.listContractsCalled)
    }

    func test_afterConfirm_insightsAreRecalculated() async throws {
        throw XCTSkip("Pending DELIVER — ContractListViewModel + ObservationsViewModel not yet scaffolded.")
        // When ContractListViewModel triggers confirm:
        // await vm.confirm(pending: somePending)
        // XCTAssertNotNil(observationsVM.insights)
    }

    func test_signOut_contractsListCleared() async throws {
        throw XCTSkip("Pending DELIVER — ContractListViewModel not yet scaffolded.")
        // When sign-out is called:
        // await vm.signOut()
        // XCTAssertTrue(vm.contracts.isEmpty)
    }
}
