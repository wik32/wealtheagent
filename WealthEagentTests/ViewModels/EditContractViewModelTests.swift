// EditContractViewModelTests.swift
// Layer 2 — In-memory acceptance (XCTest @MainActor)
//
// Driving port: EditContractViewModel.save()
// Dependencies: MockContractRepository, MockCatalogProvider
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

@MainActor
final class EditContractViewModelTests: XCTestCase {

    private var repo: MockContractRepository!
    private var catalog: Catalog!

    override func setUp() async throws {
        repo = MockContractRepository(contracts: [MockContractRepository.hukPrivathaftpflicht()])
        catalog = MockCatalogProvider().catalog()
    }

    override func tearDown() async throws {
        repo = nil
        catalog = nil
    }

    // MARK: — Walking skeleton

    /// EditContractViewModel initializes with pre-filled fields from existing contract.
    func testEditViewModelInitialisertMitVorhandenenDaten() {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        XCTAssertEqual(sut.provider, "HUK-COBURG",
                       "Anbieter muss aus dem bestehenden Vertrag vorausgefüllt sein")
        XCTAssertEqual(sut.selectedCategoryKey, "privathaftpflicht",
                       "Kategorie muss aus dem bestehenden Vertrag vorausgefüllt sein")
        XCTAssertEqual(sut.existingId, contract.id,
                       "Ursprüngliche Vertrags-ID muss beibehalten werden")
    }

    /// Pre-fills premium amount in German comma notation.
    func testBeitragWirdMitKommaVorausgefuellt() {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        XCTAssertEqual(sut.premiumAmountText, "89,00",
                       "Beitrag muss im deutschen Kommaformat vorausgefüllt sein")
    }

    /// Pre-fills existing criteria.
    func testKriterienWerdenVorausgefuellt() {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        XCTAssertEqual(sut.criteriaChecked["gross_negligence_waiver"], true,
                       "Erfüllte Kriterien müssen vorausgefüllt sein")
        XCTAssertEqual(sut.criteriaChecked["volunteer_work"], false,
                       "Nicht-erfüllte Kriterien müssen als false vorausgefüllt sein")
    }

    // MARK: — Speichern (Upsert)

    /// save() upserts the contract — repository still has exactly 1 contract.
    func testSpeichernUpsertBehaeltEineEintrag() async throws {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        sut.provider = "HUK-COBURG (aktualisiert)"

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.count, 1,
                       "Upsert darf keinen doppelten Vertrag anlegen")
        XCTAssertEqual(saved.first?.provider, "HUK-COBURG (aktualisiert)",
                       "Aktualisierter Anbieter muss im Repository erscheinen")
    }

    /// save() preserves the original contract ID.
    func testSpeichernBehaeltUrsprungsID() async throws {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        sut.provider = "Neuer Anbieter"

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.first?.id, contract.id,
                       "Die ursprüngliche Vertrags-ID muss nach dem Bearbeiten erhalten bleiben")
    }

    /// save() updates criteria.
    func testSpeichernAktualisiertKriterien() async throws {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let sut = EditContractViewModel(
            contract: contract,
            contractRepository: repo,
            catalog: catalog
        )
        sut.criteriaChecked["volunteer_work"] = true

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.first?.criteria["volunteer_work"], true,
                       "Aktualisierte Kriterien müssen gespeichert werden")
    }

    // MARK: — Löschen via ContractListViewModel

    /// ContractListViewModel.delete() removes the contract.
    func testLoeschenEntferntVertragAusPortfolio() async throws {
        let contract = MockContractRepository.hukPrivathaftpflicht()
        let listVM = ContractListViewModel(contractRepository: repo)
        await listVM.load()
        XCTAssertEqual(listVM.contracts.count, 1, "Voraussetzung: 1 Vertrag vorhanden")

        await listVM.delete(contract: contract)

        XCTAssertTrue(listVM.contracts.isEmpty,
                      "Gelöschter Vertrag darf nicht mehr in der Liste erscheinen")
    }
}
