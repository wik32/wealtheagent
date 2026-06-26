// CatalogTests.swift
// Priority 2 — Catalog (BundleCatalogProvider / MockCatalogProvider)
//
// Swift Testing framework (import Testing).
// MockCatalogProvider used here (BundleCatalogProvider is the production adapter,
// tested via integration when catalog.json is available).
//
// Contract shapes:
//   @contract-shape:pure-function — catalog() is synchronous, cached, no mutation
//
// NON-NEGOTIABLE: zero "Empfehlung/empfehlen" in test names or assertion strings.

import Testing
@testable import WealthEagent

// MARK: - Test fixtures

private let provider = MockCatalogProvider()
private let catalog = provider.catalog()

// MARK: - Suite: Catalog — Category count and structure

@Suite("Catalog — Kategorie-Struktur (22 categories, 3 levels)")
struct CatalogStructureTests {

    /// Verifies catalog decodes without crash and has exactly 22 categories.
    /// First test to skip / enable: this one is the first in the suite.
    @Test("Katalog enthält genau 22 Kategorien")
    func catalogHas22Categories() throws {
        withKnownIssue("MockCatalogProvider not yet returning all 22 categories — enable after scaffold") {
            #expect(catalog.categories.count == 22,
                    "Expected 22 categories, got \(catalog.categories.count)")
        }
    }

    /// Level 1 has 11 categories (Basisabsicherung).
    @Test("Stufe 1 enthält genau 11 Basisabsicherungskategorien")
    func level1Has11Categories() throws {
        withKnownIssue("Catalog structure test — enable after 22-category test passes") {
            let level1 = catalog.byLevel[1] ?? []
            #expect(level1.count == 11,
                    "Level 1 (Basisabsicherung) expected 11 categories, got \(level1.count)")
        }
    }

    /// Level 2 has 8 categories (Vermögensaufbau & Vorsorge).
    @Test("Stufe 2 enthält genau 8 Vermögensaufbau-Kategorien")
    func level2Has8Categories() throws {
        withKnownIssue("Catalog structure test — enable after level-1 test passes") {
            let level2 = catalog.byLevel[2] ?? []
            #expect(level2.count == 8,
                    "Level 2 (Vermögensaufbau) expected 8 categories, got \(level2.count)")
        }
    }

    /// Level 3 has 3 categories (Ergänzungen).
    @Test("Stufe 3 enthält genau 3 Ergänzungskategorien")
    func level3Has3Categories() throws {
        withKnownIssue("Catalog structure test — enable after level-2 test passes") {
            let level3 = catalog.byLevel[3] ?? []
            #expect(level3.count == 3,
                    "Level 3 (Ergänzungen) expected 3 categories, got \(level3.count)")
        }
    }

    /// Every category has a non-empty key.
    @Test("Jede Kategorie hat einen nicht-leeren Schlüssel")
    func allCategoriesHaveNonEmptyKeys() throws {
        withKnownIssue("Catalog structure test — enable after count tests pass") {
            for category in catalog.categories {
                #expect(!category.key.isEmpty, "Category '\(category.nameDe)' has empty key")
            }
        }
    }

    /// Category keys are unique across the catalog.
    @Test("Alle Kategorieschlüssel sind eindeutig")
    func categoryKeysAreUnique() throws {
        withKnownIssue("Catalog structure test — enable after non-empty key test passes") {
            let keys = catalog.categories.map(\.key)
            let uniqueKeys = Set(keys)
            #expect(keys.count == uniqueKeys.count, "Duplicate category keys found in catalog")
        }
    }
}

// MARK: - Suite: Catalog — Criteria for Privathaftpflicht

@Suite("Catalog — Leistungskriterien Privathaftpflicht")
struct CatalogPrivathaftpflichtCriteriaTests {

    /// criteriaFor("privathaftpflicht") returns exactly 10 criteria.
    /// Source: Stiftung Warentest 49-criteria catalog + Franke & Bornberg 2025.
    /// Selected 10 consumer-verifiable criteria from criteria-research.md.
    @Test("Privathaftpflicht hat genau 10 Leistungskriterien")
    func privathaftpflichtHas10Criteria() throws {
        withKnownIssue("Catalog criteria test — enable after structure tests pass") {
            let criteria = catalog.criteriaFor("privathaftpflicht")
            #expect(criteria.count == 10,
                    "Privathaftpflicht expected 10 criteria (Stiftung Warentest research), got \(criteria.count)")
        }
    }

    /// gross_negligence_waiver criterion is present in privathaftpflicht.
    @Test("Privathaftpflicht enthält Kriterium 'Verzicht auf grobe Fahrlässigkeit'")
    func privathaftpflichtHasGrossNegligenceWaiver() throws {
        withKnownIssue("Catalog criteria test — enable after count test passes") {
            let criteria = catalog.criteriaFor("privathaftpflicht")
            let keys = criteria.map(\.key)
            #expect(keys.contains("gross_negligence_waiver"),
                    "gross_negligence_waiver not found in privathaftpflicht criteria")
        }
    }

    /// All 10 expected criteria keys are present in privathaftpflicht.
    @Test("Privathaftpflicht enthält alle 10 erwarteten Kriterienschlüssel")
    func privathaftpflichtContainsAllExpectedCriteriaKeys() throws {
        withKnownIssue("Catalog criteria test — enable after individual key tests pass") {
            let expectedKeys: Set<String> = [
                "min_coverage_sum",
                "gradual_damage",
                "gross_negligence_waiver",
                "lost_key_cover",
                "volunteer_work",
                "tenant_damage",
                "overseas_cover",
                "pet_sitting",
                "contingency_cover",
                "e_mobility"
            ]

            let criteria = catalog.criteriaFor("privathaftpflicht")
            let actualKeys = Set(criteria.map(\.key))
            let missingKeys = expectedKeys.subtracting(actualKeys)

            #expect(missingKeys.isEmpty,
                    "Missing criteria keys in privathaftpflicht: \(missingKeys.sorted().joined(separator: ", "))")
        }
    }
}

// MARK: - Suite: Catalog — gross_negligence_waiver presence in 4 categories

@Suite("Catalog — Verzicht auf grobe Fahrlässigkeit (4 Kategorien)")
struct CatalogGrossNegligenceWaiverTests {

    /// gross_negligence_waiver must be present in: privathaftpflicht, hausrat, kfz, wohngebaeude.
    /// Source: criteria-research.md confirms this criterion across all 4 categories.
    @Test("Verzicht auf grobe Fahrlässigkeit ist in privathaftpflicht vorhanden")
    func grossNegligenceWaiverInPrivathaftpflicht() throws {
        withKnownIssue("Catalog criteria test — enable in order") {
            let keys = catalog.criteriaFor("privathaftpflicht").map(\.key)
            #expect(keys.contains("gross_negligence_waiver"))
        }
    }

    @Test("Verzicht auf grobe Fahrlässigkeit ist in hausrat vorhanden")
    func grossNegligenceWaiverInHausrat() throws {
        withKnownIssue("Catalog criteria test — enable in order") {
            let keys = catalog.criteriaFor("hausrat").map(\.key)
            #expect(keys.contains("gross_negligence_waiver"))
        }
    }

    @Test("Verzicht auf grobe Fahrlässigkeit ist in kfz vorhanden")
    func grossNegligenceWaiverInKfz() throws {
        withKnownIssue("Catalog criteria test — enable in order") {
            let keys = catalog.criteriaFor("kfz").map(\.key)
            #expect(keys.contains("gross_negligence_waiver"))
        }
    }

    @Test("Verzicht auf grobe Fahrlässigkeit ist in wohngebaeude vorhanden")
    func grossNegligenceWaiverInWohngebaeude() throws {
        withKnownIssue("Catalog criteria test — enable in order") {
            let keys = catalog.criteriaFor("wohngebaeude").map(\.key)
            #expect(keys.contains("gross_negligence_waiver"))
        }
    }
}

// MARK: - Suite: Catalog — Bilingual category names

@Suite("Catalog — Zweisprachige Kategorienamen (DE/EN)")
struct CatalogBilingualTests {

    /// category.name(locale: .de) and .en must differ for privathaftpflicht.
    @Test("Privathaftpflicht hat unterschiedliche Namen auf Deutsch und Englisch")
    func privathaftpflichtNamesDiffer() throws {
        withKnownIssue("Catalog bilingual test — enable after structure tests pass") {
            guard let category = catalog.category(for: "privathaftpflicht") else {
                Issue.record("privathaftpflicht not found in catalog")
                return
            }

            let nameDe = category.name(locale: Locale(identifier: "de_DE"))
            let nameEn = category.name(locale: Locale(identifier: "en_US"))

            #expect(!nameDe.isEmpty, "German name must not be empty")
            #expect(!nameEn.isEmpty, "English name must not be empty")
            #expect(nameDe != nameEn,
                    "German and English names must differ: '\(nameDe)' vs '\(nameEn)'")
        }
    }

    /// German locale returns the German name for berufsunfaehigkeit.
    @Test("Deutscher Locale gibt deutschen Namen für Berufsunfähigkeit zurück")
    func berufsunfaehigkeitGermanName() throws {
        withKnownIssue("Catalog bilingual test — enable in order") {
            guard let category = catalog.category(for: "berufsunfaehigkeit") else {
                Issue.record("berufsunfaehigkeit not found in catalog")
                return
            }

            let nameDe = category.name(locale: Locale(identifier: "de_DE"))
            #expect(nameDe == "Berufsunfähigkeit")
        }
    }

    /// English locale returns English name for berufsunfaehigkeit.
    @Test("Englischer Locale gibt englischen Namen für Berufsunfähigkeit zurück")
    func berufsunfaehigkeitEnglishName() throws {
        withKnownIssue("Catalog bilingual test — enable in order") {
            guard let category = catalog.category(for: "berufsunfaehigkeit") else {
                Issue.record("berufsunfaehigkeit not found in catalog")
                return
            }

            let nameEn = category.name(locale: Locale(identifier: "en_US"))
            #expect(nameEn == "Disability Insurance")
        }
    }

    /// All categories have non-empty DE and EN names.
    @Test("Alle Kategorien haben nicht-leere deutsche und englische Namen")
    func allCategoriesHaveBothLanguageNames() throws {
        withKnownIssue("Catalog bilingual test — enable after individual tests pass") {
            for category in catalog.categories {
                #expect(!category.nameDe.isEmpty,
                        "Category '\(category.key)' has empty German name")
                #expect(!category.nameEn.isEmpty,
                        "Category '\(category.key)' has empty English name")
            }
        }
    }
}

// MARK: - Suite: Catalog — allowsDuplicateObservation

@Suite("Catalog — Portfolio-Kategorien erlauben keine Dopplung-Prüfung")
struct CatalogAllowsDuplicateObservationTests {

    /// noDuplicate categories: depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve.
    @Test("Depot lässt Dopplung-Beobachtung NICHT zu")
    func depotAllowsDuplicateFalse() throws {
        withKnownIssue("Catalog allowsDuplicateObservation test — enable in order") {
            guard let depot = catalog.category(for: "depot") else {
                Issue.record("depot not found in catalog")
                return
            }
            #expect(depot.allowsDuplicateObservation == false)
        }
    }

    @Test("Sparplan lässt Dopplung-Beobachtung NICHT zu")
    func sparplanAllowsDuplicateFalse() throws {
        withKnownIssue("Catalog allowsDuplicateObservation test — enable in order") {
            guard let sparplan = catalog.category(for: "sparplan") else {
                Issue.record("sparplan not found in catalog")
                return
            }
            #expect(sparplan.allowsDuplicateObservation == false)
        }
    }

    @Test("Tagesgeld/Festgeld lässt Dopplung-Beobachtung NICHT zu")
    func tagesgeldAllowsDuplicateFalse() throws {
        withKnownIssue("Catalog allowsDuplicateObservation test — enable in order") {
            guard let tg = catalog.category(for: "tagesgeld_festgeld") else {
                Issue.record("tagesgeld_festgeld not found in catalog")
                return
            }
            #expect(tg.allowsDuplicateObservation == false)
        }
    }

    @Test("Liquiditätsreserve lässt Dopplung-Beobachtung NICHT zu")
    func liquiditaetsreserveAllowsDuplicateFalse() throws {
        withKnownIssue("Catalog allowsDuplicateObservation test — enable in order") {
            guard let lr = catalog.category(for: "liquiditaetsreserve") else {
                Issue.record("liquiditaetsreserve not found in catalog")
                return
            }
            #expect(lr.allowsDuplicateObservation == false)
        }
    }

    /// All non-portfolio categories allow duplicate observation.
    @Test("Privathaftpflicht lässt Dopplung-Beobachtung zu (kein Portfolio-Typ)")
    func privathaftpflichtAllowsDuplicateTrue() throws {
        withKnownIssue("Catalog allowsDuplicateObservation test — enable in order") {
            guard let phv = catalog.category(for: "privathaftpflicht") else {
                Issue.record("privathaftpflicht not found in catalog")
                return
            }
            #expect(phv.allowsDuplicateObservation == true)
        }
    }
}

// MARK: - Suite: Catalog — No banned terms in category content

@Suite("Catalog — Verbotene Begriffe in Kategorieinhalten")
struct CatalogBannedTermsTests {

    /// Category content (purpose, relevance, watch) must not contain "DIN 77230" or "Defino".
    @Test("Kein Kategorieinhalt enthält 'DIN 77230' oder 'Defino'")
    func categoriesContainNoBannedTerms() throws {
        withKnownIssue("Catalog banned terms test — enable after structure tests pass") {
            for category in catalog.categories {
                let allText = [category.purpose, category.relevance, category.watch,
                               category.nameDe, category.nameEn].joined(separator: " ").lowercased()
                #expect(!allText.contains("din 77230"),
                        "Category '\(category.key)' contains banned term 'DIN 77230'")
                #expect(!allText.contains("defino"),
                        "Category '\(category.key)' contains banned term 'Defino'")
            }
        }
    }

    /// Category content must not contain "Empfehlung" or "empfehlen".
    @Test("Kein Kategorieinhalt enthält 'Empfehlung' oder 'empfehlen'")
    func categoriesContainNoEmpfehlung() throws {
        withKnownIssue("Catalog banned terms test — enable in order") {
            for category in catalog.categories {
                let allText = [category.purpose, category.relevance, category.watch].joined(separator: " ").lowercased()
                #expect(!allText.contains("empfehlung"),
                        "Category '\(category.key)' contains banned word 'Empfehlung'")
                #expect(!allText.contains("empfehlen"),
                        "Category '\(category.key)' contains banned verb 'empfehlen'")
            }
        }
    }
}

// MARK: - Suite: Catalog — criteriaFor unknown key

@Suite("Catalog — Fehlerbehandlung für unbekannte Schlüssel")
struct CatalogCriteriaForUnknownKeyTests {

    /// criteriaFor with unknown key returns empty array, does not crash.
    @Test("criteriaFor mit unbekanntem Schlüssel gibt leeres Array zurück (kein Absturz)")
    func criteriaForUnknownKeyReturnsEmpty() throws {
        withKnownIssue("Catalog error handling test — enable in order") {
            let criteria = catalog.criteriaFor("nonexistent_category_key_xyz")
            #expect(criteria.isEmpty, "Unknown category key must return empty criteria array, not crash")
        }
    }

    /// category(for:) with unknown key returns nil, does not crash.
    @Test("category(for:) mit unbekanntem Schlüssel gibt nil zurück (kein Absturz)")
    func categoryForUnknownKeyReturnsNil() throws {
        withKnownIssue("Catalog error handling test — enable in order") {
            let category = catalog.category(for: "nonexistent_key")
            #expect(category == nil)
        }
    }
}
