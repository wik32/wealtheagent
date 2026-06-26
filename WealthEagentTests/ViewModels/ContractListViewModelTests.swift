// ContractListViewModelTests.swift
// Layer 2 — In-memory acceptance tests for ContractListViewModel.
//
// Driving port: ContractListViewModel.load(), .add(contract:), .confirm(pending:corrected:)
// Dependencies: MockContractRepository (in-memory double)
// Framework: XCTest (async @Observable ViewModel integration — per ATDD policy)
//
// @contract-shape:bounded-change — ViewModel state mutation bounded to:
//   contracts, pendingContracts, isLoading, error.
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.
//
// Test sequence (one enabled at a time for DELIVER):
//   1. testLeemesPortfolioZeigtKeineVertraege  ← FIRST to enable
//   2–5: XCTSkip until (1) is GREEN

import XCTest
@testable import WealthEagent

// MARK: - ContractListViewModelTests

@MainActor
final class ContractListViewModelTests: XCTestCase {

    // MARK: - setUp / tearDown

    var mockRepo: MockContractRepository!

    override func setUp() async throws {
        mockRepo = MockContractRepository(contracts: [])
    }

    override func tearDown() async throws {
        mockRepo = nil
    }

    // MARK: ── Walking skeleton ──────────────────────────────────────────────
    //
    // FIRST ContractListViewModel test to enable in DELIVER.

    /// Empty repository → contracts array is empty after load().
    func testLeemesPortfolioZeigtKeineVertraege() async throws {
        // Given: no confirmed contracts in repository
        let sut = ContractListViewModel(contractRepository: mockRepo)

        // When: ViewModel loads contracts
        await sut.load()

        // Then: contracts array is empty
        XCTAssertTrue(sut.contracts.isEmpty,
                      "Leeres Portfolio darf keine Verträge anzeigen")
        XCTAssertFalse(sut.isLoading,
                       "isLoading muss nach dem Laden false sein")
    }

    // MARK: ── Vertrag hinzufügen ─────────────────────────────────────────────

    /// Adding a contract → it appears in contracts after reload.
    func testVertragHinzufuegenErscheintInListe() async throws {
        // Given: initially empty portfolio
        let sut = ContractListViewModel(contractRepository: mockRepo)
        await sut.load()
        XCTAssertTrue(sut.contracts.isEmpty, "Voraussetzung: leere Liste")

        // When: user adds a new Privathaftpflicht contract
        let newContract = MockContractRepository.hukPrivathaftpflicht()
        await sut.add(contract: newContract)

        // Then: contract appears in the list
        XCTAssertEqual(sut.contracts.count, 1,
                       "Nach Hinzufügen muss 1 Vertrag in der Liste sein")
        XCTAssertEqual(sut.contracts.first?.provider, "HUK-COBURG",
                       "Vertrag muss den eingetragenen Anbieter zeigen")
    }

    // MARK: ── Entwurf bestätigen ─────────────────────────────────────────────

    /// Confirming a pending contract promotes it to the contracts list
    /// and removes it from pendingContracts.
    func testEntwurfBestaetigungVerschiebtInVertragsListe() async throws {
        // Given: one pending contract in review queue
        let pending = PendingContract(
            id: UUID(),
            categoryKey: "privathaftpflicht",
            rawOCRText: "HUK-COBURG Privathaftpflicht 89 EUR jährlich",
            ocrConfidence: 0.87
        )
        let repoWithPending = MockContractRepository(contracts: [], pendingContracts: [pending])
        let sut = ContractListViewModel(contractRepository: repoWithPending)
        await sut.load()
        XCTAssertEqual(sut.pendingContracts.count, 1, "Voraussetzung: 1 Entwurf in Prüfwarteschlange")

        // When: user confirms the pending contract
        await sut.confirm(pending: pending)

        // Then: confirmed contract is in the portfolio, pending queue is empty
        XCTAssertEqual(sut.contracts.count, 1,
                       "Bestätigter Vertrag muss in der Vertragsliste erscheinen")
        XCTAssertTrue(sut.pendingContracts.isEmpty,
                      "Prüfwarteschlange muss nach Bestätigung leer sein")
    }

    // MARK: ── Fixture-Portfolio laden ────────────────────────────────────────

    /// Fixture repository (HUK PHV + AXA PHV + Depot) loads all 3 contracts.
    func testFixturePortfolioLaedtDreiVertraege() async throws {
        // Given: standard fixture portfolio
        let fixtureRepo = MockContractRepository(contracts: MockContractRepository.fixtureContracts())
        let sut = ContractListViewModel(contractRepository: fixtureRepo)

        // When: ViewModel loads contracts
        await sut.load()

        // Then: all 3 fixture contracts are present
        XCTAssertEqual(sut.contracts.count, 3,
                       "Fixture-Portfolio muss 3 Verträge laden")
    }

    // MARK: ── Fehlerstatus ───────────────────────────────────────────────────

    /// Repository failure → error state is surfaced, contracts remain empty.
    func testRepositoryFehlerZeigtFehlerstatus() async throws {
        // Given: repository that always throws
        mockRepo.listError = MockRepositoryError.connectionUnavailable
        let sut = ContractListViewModel(contractRepository: mockRepo)

        // When: ViewModel loads contracts
        await sut.load()

        // Then: error is surfaced; contracts list stays empty
        XCTAssertNotNil(sut.error,
                        "Verbindungsfehler muss in der Vertragsliste sichtbar sein")
        XCTAssertTrue(sut.contracts.isEmpty,
                      "Bei Fehler darf keine veraltete Liste angezeigt werden")
    }
}
