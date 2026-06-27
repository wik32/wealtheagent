// BundleCatalogProviderTests.swift
// Layer 3 — Adapter integration test: real catalog.json bundle read.
// Verifies that BundleCatalogProvider correctly decodes catalog.json at runtime.
//
// Per atdd-infrastructure-policy.md: "BundleCatalogProvider integration test (planned)
// — Layer 3 — Adapter integration — Real catalog.json bundle read, XCTest"

import XCTest
@testable import WealthEagent

final class BundleCatalogProviderTests: XCTestCase {

    // MARK: - Walking skeleton

    /// BundleCatalogProvider decodes catalog.json without crash.
    func testCatalogProviderLadtKatalogOhneAbsturz() {
        XCTAssertNoThrow(BundleCatalogProvider())
    }

    // MARK: - Catalog structure

    /// Decoded catalog has exactly 22 categories.
    func testKatalogHat22Kategorien() {
        let catalog = BundleCatalogProvider().catalog()
        XCTAssertEqual(catalog.categories.count, 22,
                       "catalog.json muss exakt 22 Kategorien enthalten")
    }

    /// Level distribution: 11 Level-1, 8 Level-2, 3 Level-3.
    func testKatalogNiveauVerteilungKorrekt() {
        let catalog = BundleCatalogProvider().catalog()
        XCTAssertEqual(catalog.byLevel[1]?.count, 11, "Stufe 1: 11 Basisabsicherungs-Kategorien")
        XCTAssertEqual(catalog.byLevel[2]?.count, 8, "Stufe 2: 8 Vermögensaufbau-Kategorien")
        XCTAssertEqual(catalog.byLevel[3]?.count, 3, "Stufe 3: 3 Ergänzungs-Kategorien")
    }

    /// Privathaftpflicht has 10 criteria.
    func testPrivathaftpflichtHat10Kriterien() {
        let catalog = BundleCatalogProvider().catalog()
        let criteria = catalog.criteriaFor("privathaftpflicht")
        XCTAssertEqual(criteria.count, 10,
                       "Privathaftpflicht muss 10 Leistungskriterien haben")
    }

    /// gross_negligence_waiver exists in privathaftpflicht criteria.
    func testGrobeFahrlässigkeitKriteriumVorhanden() {
        let catalog = BundleCatalogProvider().catalog()
        let criteria = catalog.criteriaFor("privathaftpflicht")
        XCTAssertTrue(criteria.contains { $0.key == "gross_negligence_waiver" },
                      "Grobe Fahrlässigkeit muss als Kriterium in der Privathaftpflicht vorhanden sein")
    }

    /// No category key is empty.
    func testAlleKategorieschluesselnichtLeer() {
        let catalog = BundleCatalogProvider().catalog()
        for category in catalog.categories {
            XCTAssertFalse(category.key.isEmpty,
                           "Kategorieschlüssel darf nicht leer sein: \(category.nameDe)")
        }
    }
}
