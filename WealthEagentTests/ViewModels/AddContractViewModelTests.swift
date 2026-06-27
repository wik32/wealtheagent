// AddContractViewModelTests.swift
// Layer 2 — In-memory acceptance (XCTest @MainActor)
//
// Driving port: AddContractViewModel
// Dependencies: MockContractRepository, MockCatalogProvider
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

@MainActor
final class AddContractViewModelTests: XCTestCase {

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

    // MARK: — Walking skeleton

    /// AddContractViewModel initializes with canSave = false (no category, no provider).
    func testAddContractViewModelInitialisiert() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        XCTAssertFalse(sut.canSave, "Speichern nicht möglich ohne Kategorie und Anbieter")
        XCTAssertTrue(sut.selectedCategoryKey.isEmpty)
        XCTAssertTrue(sut.provider.isEmpty)
        XCTAssertEqual(sut.premiumInterval, "monatlich", "Standard-Zahlungsrhythmus ist monatlich")
    }

    // MARK: — Validierung: canSave

    /// canSave is false when provider is empty but category is set.
    func testSpeichernNichtMoeglichOhneAnbieter() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.provider = ""
        XCTAssertFalse(sut.canSave, "Speichern darf nicht möglich sein ohne Anbieter")
    }

    /// canSave is false when category is empty but provider is set.
    func testSpeichernNichtMoeglichOhneKategorie() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = ""
        sut.provider = "HUK-COBURG"
        XCTAssertFalse(sut.canSave, "Speichern darf nicht möglich sein ohne Kategorie")
    }

    /// canSave is true when both category and provider are set.
    func testSpeichernMoeglichMitKategorieUndAnbieter() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.provider = "HUK-COBURG"
        XCTAssertTrue(sut.canSave, "Speichern muss möglich sein mit Kategorie und Anbieter")
    }

    /// Whitespace-only provider does not satisfy canSave.
    func testAnbieterNurLeerzeichenIstUngueltig() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.provider = "   "
        XCTAssertFalse(sut.canSave, "Anbieter mit nur Leerzeichen ist ungültig")
    }

    // MARK: — Speichern: Persistenz

    /// save() with valid data persists a Contract to the repository.
    func testSpeichernPersitiertVertragImRepository() async throws {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.provider = "HUK-COBURG"
        sut.premiumAmountText = "89,00"
        sut.premiumInterval = "jaehrlich"

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.count, 1, "Gespeicherter Vertrag muss im Repository erscheinen")
        XCTAssertEqual(saved.first?.provider, "HUK-COBURG")
        XCTAssertEqual(saved.first?.categoryKey, "privathaftpflicht")
        XCTAssertEqual(saved.first?.premiumInterval, "jaehrlich")
    }

    /// save() converts German comma decimal notation to Double correctly.
    func testSpeichernMitBetragKonvertiertKomma() async throws {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "hausrat"
        sut.provider = "Allianz"
        sut.premiumAmountText = "120,50"

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.first?.premiumAmount ?? 0, 120.50, accuracy: 0.01,
                       "Komma im Betrag muss korrekt in Double konvertiert werden")
    }

    /// save() without premium amount produces a contract with nil premiumAmount.
    func testSpeichernOhneBetragIstGueltig() async throws {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "depot"
        sut.provider = "Deutsche Bank"
        sut.premiumAmountText = ""

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.count, 1)
        XCTAssertNil(saved.first?.premiumAmount,
                     "Kein Betrag ist gültig — manche Verträge haben keinen Beitrag")
    }

    /// save() trims leading/trailing whitespace from provider.
    func testSpeichernTrimmedAnbieter() async throws {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "krankenversicherung"
        sut.provider = "  TK  "

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.first?.provider, "TK",
                       "Leerzeichen am Anfang/Ende des Anbieters müssen entfernt werden")
    }

    // MARK: — Leistungskriterien

    /// Selecting a category loads its criteria into availableCriteria.
    func testKategorieWahlLaedtLeistungskriterien() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        XCTAssertEqual(sut.availableCriteria.count, 10,
                       "Privathaftpflicht hat 10 Leistungskriterien zur Erfassung")
    }

    /// No criteria available before a category is selected.
    func testKeinKriteriumenOhneKategorieWahl() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        XCTAssertTrue(sut.availableCriteria.isEmpty,
                      "Ohne Kategorie sind keine Kriterien verfügbar")
    }

    /// Criteria reset when category changes.
    func testKriterienWerdenBeiKategoriewechselZurueckgesetzt() {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.criteriaChecked["gross_negligence_waiver"] = true

        sut.selectedCategoryKey = "hausrat"

        XCTAssertTrue(sut.criteriaChecked.isEmpty,
                      "Kriterien müssen bei Kategorienwechsel zurückgesetzt werden")
    }

    /// save() persists criteria in the saved Contract.
    func testSpeichernPersistiertKriterien() async throws {
        let sut = AddContractViewModel(contractRepository: repo, catalog: catalog)
        sut.selectedCategoryKey = "privathaftpflicht"
        sut.provider = "HUK-COBURG"
        sut.criteriaChecked["gross_negligence_waiver"] = true
        sut.criteriaChecked["lost_key_cover"] = true
        sut.criteriaChecked["overseas_cover"] = false

        try await sut.save()

        let saved = try await repo.list()
        XCTAssertEqual(saved.first?.criteria["gross_negligence_waiver"], true,
                       "Erfüllte Kriterien müssen im Vertrag gespeichert werden")
        XCTAssertEqual(saved.first?.criteria["lost_key_cover"], true)
        XCTAssertEqual(saved.first?.criteria["overseas_cover"], false,
                       "Nicht-erfüllte Kriterien müssen als false gespeichert werden")
    }
}
