// CompareViewModelTests.swift
// Layer 2 — In-memory acceptance (XCTest @MainActor)
//
// Driving port: CompareViewModel init(categoryKey:contracts:catalog:)
// Dependencies: MockCatalogProvider, MockContractRepository.fixtureContracts()
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import XCTest
@testable import WealthEagent

@MainActor
final class CompareViewModelTests: XCTestCase {

    // MARK: - Helpers

    private var catalog: Catalog!

    override func setUp() async throws {
        catalog = MockCatalogProvider().catalog()
    }

    override func tearDown() async throws {
        catalog = nil
    }

    // MARK: — Walking skeleton

    /// CompareViewModel initializes without crash with two fixture contracts.
    func testCompareViewModelInitialisiert() {
        let contracts = [
            MockContractRepository.hukPrivathaftpflicht(),
            MockContractRepository.axaPrivathaftpflicht()
        ]
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: contracts,
            catalog: catalog
        )
        XCTAssertEqual(sut.contracts.count, 2, "Vergleich muss beide Verträge enthalten")
        XCTAssertFalse(sut.categoryName.isEmpty, "Kategoriename darf nicht leer sein")
    }

    // MARK: — Kriterien-Matrix

    /// HUK-COBURG has 7/10 criteria met in the fixture.
    func testHukHatSiebenVonZehnKriterienErfuellt() {
        let contracts = [MockContractRepository.hukPrivathaftpflicht()]
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: contracts,
            catalog: catalog
        )
        XCTAssertEqual(sut.summaries.first?.metCount, 7,
                       "HUK-COBURG erfüllt 7 von 10 Privathaftpflicht-Kriterien")
    }

    /// AXA has 2/10 criteria met in the fixture (lost_key_cover + e_mobility).
    func testAxaHatZweiVonZehnKriterienErfuellt() {
        let contracts = [MockContractRepository.axaPrivathaftpflicht()]
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: contracts,
            catalog: catalog
        )
        XCTAssertEqual(sut.summaries.first?.metCount, 2,
                       "AXA erfüllt 2 von 10 Privathaftpflicht-Kriterien")
    }

    /// Total criteria count matches catalog (10 for Privathaftpflicht).
    func testGesamstzahlKriterienKorrekt() {
        let contracts = [MockContractRepository.hukPrivathaftpflicht()]
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: contracts,
            catalog: catalog
        )
        XCTAssertEqual(sut.summaries.first?.totalCriteria, 10,
                       "Privathaftpflicht hat 10 Leistungskriterien")
        XCTAssertEqual(sut.criterionRows.count, 10,
                       "Vergleich zeigt eine Zeile pro Kriterium")
    }

    /// CompareViewModel with no criteria (unknown category) produces empty rows.
    func testUnbekannteKategorieProduzierteLeereMatrix() {
        let contract = Contract(categoryKey: "unbekannt", provider: "Test")
        let sut = CompareViewModel(
            categoryKey: "unbekannt",
            contracts: [contract],
            catalog: catalog
        )
        XCTAssertTrue(sut.criterionRows.isEmpty,
                      "Unbekannte Kategorie produziert keine Kriteriums-Zeilen")
    }

    /// Both contracts appear in the results for each criterion row.
    func testBeideVertraegeErscheinenInKriteriumsZeile() {
        let huk = MockContractRepository.hukPrivathaftpflicht()
        let axa = MockContractRepository.axaPrivathaftpflicht()
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: [huk, axa],
            catalog: catalog
        )
        for row in sut.criterionRows {
            XCTAssertEqual(row.results.count, 2,
                           "Jede Kriterium-Zeile muss Ergebnisse für beide Verträge enthalten")
        }
    }

    /// gross_negligence_waiver: HUK true, AXA false.
    func testGrobeFahrlässigkeitHukErfuelltAxaNicht() {
        let huk = MockContractRepository.hukPrivathaftpflicht()
        let axa = MockContractRepository.axaPrivathaftpflicht()
        let sut = CompareViewModel(
            categoryKey: "privathaftpflicht",
            contracts: [huk, axa],
            catalog: catalog
        )
        let gnwRow = sut.criterionRows.first { $0.criterion.key == "gross_negligence_waiver" }
        XCTAssertNotNil(gnwRow, "Grobe Fahrlässigkeit muss als Kriterium vorhanden sein")
        XCTAssertEqual(gnwRow?.results[huk.id] as? Bool, true,
                       "HUK-COBURG erfüllt grobe Fahrlässigkeit")
        XCTAssertEqual(gnwRow?.results[axa.id] as? Bool, false,
                       "AXA erfüllt grobe Fahrlässigkeit nicht")
    }
}
