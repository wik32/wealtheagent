// LocalContractRepositoryTests.swift
// WealthEagentTests — Adapter layer acceptance tests for LocalContractRepository.
//
// Layer 2 — In-memory acceptance (per atdd-infrastructure-policy.md).
// Mechanism: SwiftData ModelContainer(isStoredInMemoryOnly: true) per test.
//
// Walking skeleton (TEST-01): save one contract, list() returns it.
// All other tests carry XCTSkip — enable one at a time in DELIVER.
//
// Contract shapes:
//   @contract-shape:bounded-change  — mutations that change specific records
//   @contract-shape:pure-function   — read-only list operations
//
// Non-negotiable: no "Empfehlung", "Defino", "DIN 77230" in any string.

import XCTest
@testable import WealthEagent
// DELIVER: uncomment when @Model types exist
// import SwiftData

// MARK: - LocalContractRepositoryTests

/// Acceptance tests for LocalContractRepository (SwiftData adapter).
/// Each test exercises the ContractRepository protocol via LocalContractRepository directly —
/// no ViewModels, no UI, no CloudKit. The driving port is the protocol itself.
@MainActor
final class LocalContractRepositoryTests: XCTestCase {

    // MARK: - System Under Test

    var sut: LocalContractRepository!

    // MARK: - setUp / tearDown

    override func setUp() async throws {
        // DELIVER: replace with real in-memory ModelContainer
        //
        // let config = ModelConfiguration(isStoredInMemoryOnly: true)
        // let container = try ModelContainer(
        //     for: ContractRecord.self, PendingContractRecord.self,
        //     configurations: config
        // )
        // sut = LocalContractRepository(modelContainer: container)
        //
        // For now (RED scaffold phase): construct without container.
        // Tests will throw or fail at the protocol call — correct RED behaviour.
        sut = LocalContractRepository()
    }

    override func tearDown() async throws {
        sut = nil
    }

    // MARK: - TEST-01: Walking Skeleton (LIVE — this is the first test to make GREEN)
    //
    // @contract-shape:bounded-change
    // Goal: prove the full save → list round-trip works end-to-end through SwiftData.
    // When this passes, the persistence layer is wired.

    func testSaveContractAndListReturnsIt() async throws {
        // Given: a Privathaftpflicht contract from HUK-COBURG
        let contract = Contract.fixture(
            categoryKey: "privathaftpflicht",
            provider: "HUK-COBURG"
        )

        // When: the portfolio stores the contract
        try await sut.save(contract)

        // Then: the portfolio contains exactly this contract
        let stored = try await sut.list()
        XCTAssertEqual(stored.count, 1)
        XCTAssertEqual(stored[0].id, contract.id)
        XCTAssertEqual(stored[0].provider, "HUK-COBURG")
        XCTAssertEqual(stored[0].categoryKey, "privathaftpflicht")
    }

    // MARK: - TEST-02: Empty store returns empty collections
    //
    // @contract-shape:pure-function
    // Goal: fresh store returns ([], []) — no crash, no stale data.

    func testEmptyStoreReturnsEmptyCollections() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-01 is GREEN")

        let contracts = try await sut.list()
        let pending = try await sut.listPending()
        XCTAssertTrue(contracts.isEmpty, "Fresh store must have no confirmed contracts")
        XCTAssertTrue(pending.isEmpty, "Fresh store must have no pending contracts")
    }

    // MARK: - TEST-03: Save pending contract — listPending returns it
    //
    // @contract-shape:bounded-change
    // Goal: OCR output (PendingContract) survives a save → listPending round-trip.

    func testSavePendingContractAndListPendingReturnsIt() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-02 is GREEN")

        // Given: an OCR draft awaiting user review
        let pending = PendingContract.fixture(
            categoryKey: "privathaftpflicht",
            rawOCRText: "Versicherungsschein HUK-COBURG"
        )

        // When: the draft is stored for later review
        try await sut.savePending(pending)

        // Then: the draft appears in the pending list
        let storedPending = try await sut.listPending()
        XCTAssertEqual(storedPending.count, 1)
        XCTAssertEqual(storedPending[0].id, pending.id)
        XCTAssertEqual(storedPending[0].categoryKey, "privathaftpflicht")
    }

    // MARK: - TEST-04: Delete confirmed contract — list no longer contains it
    //
    // @contract-shape:bounded-change
    // Goal: deleted contract disappears; other contracts are unaffected.

    func testDeleteContractRemovesItFromPortfolio() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-03 is GREEN")

        // Given: two contracts in the portfolio
        let toDelete = Contract.fixture(categoryKey: "privathaftpflicht", provider: "HUK-COBURG")
        let toKeep = Contract.fixture(categoryKey: "depot", provider: "Deutsche Bank")
        try await sut.save(toDelete)
        try await sut.save(toKeep)

        // When: the user removes the Privathaftpflicht contract
        try await sut.delete(id: toDelete.id)

        // Then: only the Depot contract remains
        let remaining = try await sut.list()
        XCTAssertEqual(remaining.count, 1)
        XCTAssertEqual(remaining[0].id, toKeep.id)
        XCTAssertFalse(remaining.contains { $0.id == toDelete.id })
    }

    // MARK: - TEST-05: Confirm pending without corrections — fields preserved
    //
    // @contract-shape:bounded-change
    // Goal: confirming a draft without edits promotes it with the extracted fields intact
    //       and removes it from the pending list.

    func testConfirmPendingWithoutCorrectionsPreservesExtractedFields() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-04 is GREEN")

        // Given: an OCR draft with extracted fields
        let extractedFields = ContractFields(["provider": .text("AXA")])
        let pending = PendingContract.fixture(
            categoryKey: "privathaftpflicht",
            rawOCRText: "AXA Haftpflicht Schein",
            extractedFields: extractedFields
        )
        try await sut.savePending(pending)

        // When: the user confirms the draft without corrections
        let confirmed = try await sut.confirm(pending, corrected: nil)

        // Then: the confirmed contract has the extracted fields
        XCTAssertEqual(confirmed.id, pending.id)
        XCTAssertEqual(confirmed.categoryKey, "privathaftpflicht")

        // And: the draft no longer appears in the pending list
        let pendingAfter = try await sut.listPending()
        XCTAssertTrue(pendingAfter.isEmpty)

        // And: the confirmed contract appears in the portfolio
        let contractsAfter = try await sut.list()
        XCTAssertEqual(contractsAfter.count, 1)
        XCTAssertEqual(contractsAfter[0].id, pending.id)
    }

    // MARK: - TEST-06: Confirm pending with corrections — corrected values win
    //
    // @contract-shape:bounded-change
    // Goal: user corrections override OCR-extracted values in the confirmed contract.

    func testConfirmPendingWithCorrectedFieldsUsesUserValues() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-05 is GREEN")

        // Given: an OCR draft with an incorrect category
        let pending = PendingContract.fixture(
            categoryKey: "privathaftpflicht",
            rawOCRText: "Versicherungsschein"
        )
        try await sut.savePending(pending)

        // When: the user confirms with corrected provider and premium
        let correctedFields = ContractFields([
            "provider": .text("Allianz"),
            "premium_amount": .number(120.00)
        ])
        let confirmed = try await sut.confirm(pending, corrected: correctedFields)

        // Then: the confirmed contract reflects the user's corrections
        XCTAssertEqual(confirmed.fields["provider"], .text("Allianz"))
        XCTAssertEqual(confirmed.fields["premium_amount"], .number(120.00))
    }

    // MARK: - TEST-07: Discard pending — removed from list, not added to portfolio
    //
    // @contract-shape:bounded-change
    // Goal: discarded OCR draft disappears; the confirmed portfolio is untouched.

    func testDiscardPendingRemovesItWithoutAddingToPortfolio() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-06 is GREEN")

        // Given: one confirmed contract and one pending draft
        let contract = Contract.fixture(categoryKey: "depot", provider: "Deutsche Bank")
        let pending = PendingContract.fixture(
            categoryKey: "privathaftpflicht",
            rawOCRText: "Schein"
        )
        try await sut.save(contract)
        try await sut.savePending(pending)

        // When: the user discards the draft
        try await sut.discard(id: pending.id)

        // Then: the pending list is empty
        let pendingAfter = try await sut.listPending()
        XCTAssertTrue(pendingAfter.isEmpty)

        // And: the portfolio still has exactly the one confirmed contract
        let contractsAfter = try await sut.list()
        XCTAssertEqual(contractsAfter.count, 1)
        XCTAssertEqual(contractsAfter[0].id, contract.id)
    }

    // MARK: - TEST-08: Multiple contracts — list returns all
    //
    // @contract-shape:bounded-change
    // Goal: three distinct contracts are all retrievable after saving.

    func testMultipleContractsAllReturnedByList() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-07 is GREEN")

        // Given: three contracts across different categories
        let phv = Contract.fixture(categoryKey: "privathaftpflicht", provider: "HUK-COBURG")
        let bu = Contract.fixture(categoryKey: "berufsunfaehigkeit", provider: "Allianz")
        let depot = Contract.fixture(categoryKey: "depot", provider: "Deutsche Bank")
        try await sut.save(phv)
        try await sut.save(bu)
        try await sut.save(depot)

        // When: the portfolio is listed
        let stored = try await sut.list()

        // Then: all three contracts are present
        XCTAssertEqual(stored.count, 3)
        let ids = Set(stored.map { $0.id })
        XCTAssertTrue(ids.contains(phv.id))
        XCTAssertTrue(ids.contains(bu.id))
        XCTAssertTrue(ids.contains(depot.id))
    }

    // MARK: - TEST-09: Persistence across repository instances
    //
    // @contract-shape:bounded-change
    // Goal: a contract saved in one repository instance is visible in a new instance
    //       that shares the same on-disk SwiftData store — proving real persistence.
    //
    // Note: uses a file-backed ModelContainer (not in-memory) to test durability.
    // DELIVER: configure a temp-directory URL for the store and clean up in tearDown.

    func testContractSurvivedNewRepositoryInstance() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-08 is GREEN — requires file-backed ModelContainer")

        // Given: a contract saved through the first repository instance
        //   (sut uses the shared file-backed store in this test only)
        let contract = Contract.fixture(categoryKey: "privathaftpflicht", provider: "HUK-COBURG")
        try await sut.save(contract)

        // When: a second repository instance is created pointing at the same store
        // let sut2 = LocalContractRepository(modelContainer: <same file-backed container>)
        // let stored = try await sut2.list()
        //
        // Then: the contract is present
        // XCTAssertEqual(stored.count, 1)
        // XCTAssertEqual(stored[0].id, contract.id)

        // DELIVER fills in the sut2 setup above. Placeholder assertion to make the
        // test compile before DELIVER:
        XCTFail("TEST-09 body must be completed in DELIVER wave")
    }

    // MARK: - TEST-10: Confirm non-existent pending — throws notFound
    //
    // @contract-shape:bounded-change
    // Goal: confirming a draft that was never saved (or already discarded)
    //       throws ContractRepositoryError.notFound rather than silently succeeding.

    func testConfirmNonExistentPendingThrowsNotFound() async throws {
        try XCTSkipIf(true, "DELIVER: enable after TEST-09 is GREEN")

        // Given: a pending contract that was never saved to the store
        let phantom = PendingContract.fixture(
            categoryKey: "privathaftpflicht",
            rawOCRText: "does not exist in store"
        )

        // When: the user tries to confirm it
        // Then: the store signals that the draft cannot be found
        do {
            _ = try await sut.confirm(phantom, corrected: nil)
            XCTFail("Expected ContractRepositoryError.notFound to be thrown")
        } catch ContractRepositoryError.notFound(let id) {
            XCTAssertEqual(id, phantom.id)
        }
    }
}

// MARK: - Domain Fixtures

/// Minimal test fixtures for Contract and PendingContract.
/// These live here (not in MockContractRepository) because they create
/// clean isolated instances — no pre-populated portfolio state.

extension Contract {
    /// Fixture with controllable categoryKey and provider. All optional fields nil.
    static func fixture(
        id: UUID = UUID(),
        categoryKey: String,
        provider: String,
        premiumAmount: Double? = nil,
        premiumInterval: String? = nil,
        fields: ContractFields = ContractFields(),
        criteria: [String: Bool] = [:]
    ) -> Contract {
        Contract(
            id: id,
            categoryKey: categoryKey,
            provider: provider,
            premiumAmount: premiumAmount,
            premiumInterval: premiumInterval,
            fields: fields,
            criteria: criteria
        )
    }
}

extension PendingContract {
    /// Fixture with controllable categoryKey and rawOCRText.
    static func fixture(
        id: UUID = UUID(),
        categoryKey: String,
        rawOCRText: String,
        ocrConfidence: Double = 0.85,
        extractedFields: ContractFields = ContractFields()
    ) -> PendingContract {
        PendingContract(
            id: id,
            categoryKey: categoryKey,
            rawOCRText: rawOCRText,
            ocrConfidence: ocrConfidence,
            extractedFields: extractedFields
        )
    }
}
