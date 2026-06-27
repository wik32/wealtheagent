// PendingContractReviewViewModelTests.swift
// Layer 2 — In-memory acceptance (XCTest @MainActor)
//
// Driving port: PendingContractReviewViewModel.confirm() / .discard()
// Dependencies: MockContractRepository, MockCatalogProvider
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

@MainActor
final class PendingContractReviewViewModelTests: XCTestCase {

    // MARK: - setUp / tearDown

    private var repo: MockContractRepository!
    private var catalog: Catalog!

    override func setUp() async throws {
        repo = MockContractRepository(contracts: [])
        catalog = MockCatalogProvider().catalog()
    }

    override func tearDown() async throws {
        repo = nil
        catalog = nil
    }

    // MARK: - Helpers

    private func makePending(
        categoryKey: String = "privathaftpflicht",
        provider: String = "HUK-COBURG",
        ocrConfidence: Double = 0.92
    ) async throws -> PendingContract {
        var fields = ContractFields()
        fields["provider"] = .text(provider)
        let pending = PendingContract(
            categoryKey: categoryKey,
            rawOCRText: "HUK-COBURG Privathaftpflicht 89 EUR jährlich",
            ocrConfidence: ocrConfidence,
            extractedFields: fields
        )
        try await repo.savePending(pending)
        return pending
    }

    // MARK: — Walking skeleton

    /// PendingContractReviewViewModel initializes with pre-filled fields from OCR.
    func testViewModelInitialisiertMitOCRDaten() async throws {
        let pending = try await makePending()
        let sut = PendingContractReviewViewModel(
            pending: pending,
            contractRepository: repo,
            catalog: catalog
        )
        XCTAssertEqual(sut.provider, "HUK-COBURG",
                       "Anbieter muss aus OCR-Daten vorausgefüllt sein")
        XCTAssertEqual(sut.selectedCategoryKey, "privathaftpflicht",
                       "Kategorie muss aus OCR-Daten vorausgefüllt sein")
    }

    // MARK: — Bestätigen

    /// confirm() creates a confirmed Contract and removes the PendingContract.
    func testBestaetigungErstelltVertragUndEntferntEntwurf() async throws {
        let pending = try await makePending()
        let sut = PendingContractReviewViewModel(
            pending: pending,
            contractRepository: repo,
            catalog: catalog
        )

        try await sut.confirm()

        let contracts = try await repo.list()
        let remaining = try await repo.listPending()
        XCTAssertEqual(contracts.count, 1, "Bestätigung muss einen Vertrag anlegen")
        XCTAssertTrue(remaining.isEmpty, "Bestätigung muss den Entwurf entfernen")
    }

    /// Confirmed contract has the provider from the review form.
    func testBestaetigterVertragHatKorrektenAnbieter() async throws {
        let pending = try await makePending()
        let sut = PendingContractReviewViewModel(
            pending: pending,
            contractRepository: repo,
            catalog: catalog
        )
        sut.provider = "Allianz"

        try await sut.confirm()

        let contracts = try await repo.list()
        XCTAssertEqual(contracts.first?.provider, "Allianz",
                       "Korrigierter Anbieter muss im bestätigten Vertrag erscheinen")
    }

    /// canConfirm is false when provider is empty.
    func testBestaetigungNichtMoeglichOhneAnbieter() async throws {
        let pending = try await makePending()
        let sut = PendingContractReviewViewModel(
            pending: pending,
            contractRepository: repo,
            catalog: catalog
        )
        sut.provider = ""
        XCTAssertFalse(sut.canConfirm, "Bestätigung ohne Anbieter darf nicht möglich sein")
    }

    // MARK: — Verwerfen

    /// discard() removes the PendingContract without creating a Contract.
    func testVerwerfenEntferntEntwurfOhneVertrag() async throws {
        let pending = try await makePending()
        let sut = PendingContractReviewViewModel(
            pending: pending,
            contractRepository: repo,
            catalog: catalog
        )

        try await sut.discard()

        let remaining = try await repo.listPending()
        let contracts = try await repo.list()
        XCTAssertTrue(remaining.isEmpty, "Verwerfen muss den Entwurf entfernen")
        XCTAssertTrue(contracts.isEmpty, "Verwerfen darf keinen Vertrag anlegen")
    }
}
