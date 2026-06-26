// CatalogTests.swift
// FinanzAppTests — Domain Tests (Priority 2)
//
// Tests for BundleCatalogProvider / catalog.json loading.
// Uses Swift Testing framework (import Testing).
//
// All tests are RED against the scaffold. Enable one at a time in DELIVER.

import Testing
@testable import FinanzApp

// MARK: - Walking Skeleton

@Suite("CatalogProvider — Walking Skeleton")
struct CatalogProviderWalkingSkeletonTests {

    @Test("Catalog loads successfully and contains 22 categories")
    func catalogLoadsWithAllCategories() {
        // Given: BundleCatalogProvider (reads from app bundle catalog.json)
        let provider = MockCatalogProvider()

        // When: catalog is requested
        let catalog = provider.catalog()

        // Then: 22 categories are present (the canonical FinanzApp catalog)
        #expect(catalog.categories.count == 22)
    }
}

// MARK: - Category Count and Level Distribution

@Suite("CatalogProvider — Category Structure")
struct CatalogCategoryStructureTests {

    let provider = MockCatalogProvider()

    @Test("Catalog has exactly 22 categories")
    func catalogHas22Categories() {
        let catalog = provider.catalog()
        #expect(catalog.categories.count == 22)
    }

    @Test("Catalog has 11 level-1 categories (existential protection)")
    func catalogHas11Level1Categories() {
        let catalog = provider.catalog()
        let level1 = catalog.categories.filter { $0.needsLevel == 1 }
        #expect(level1.count == 11)
    }

    @Test("Catalog has 8 level-2 categories (provision and wealth)")
    func catalogHas8Level2Categories() {
        let catalog = provider.catalog()
        let level2 = catalog.categories.filter { $0.needsLevel == 2 }
        #expect(level2.count == 8)
    }

    @Test("Catalog has 3 level-3 categories (supplements)")
    func catalogHas3Level3Categories() {
        let catalog = provider.catalog()
        let level3 = catalog.categories.filter { $0.needsLevel == 3 }
        #expect(level3.count == 3)
    }

    @Test("All catalog categories have a non-empty key")
    func allCategoriesHaveNonEmptyKey() {
        let catalog = provider.catalog()
        for category in catalog.categories {
            #expect(!category.key.isEmpty, "Category '\(category.nameDE)' has empty key")
        }
    }

    @Test("All catalog category keys are unique")
    func allCategoryKeysAreUnique() {
        let catalog = provider.catalog()
        let keys = catalog.categories.map { $0.key }
        let uniqueKeys = Set(keys)
        #expect(keys.count == uniqueKeys.count, "Duplicate category keys found")
    }
}

// MARK: - Category Lookup

@Suite("CatalogProvider — Category Lookup")
struct CatalogLookupTests {

    let provider = MockCatalogProvider()

    @Test("Category lookup by key 'privathaftpflicht' returns correct category")
    func lookupPrivathaftpflichtReturnsCorrectCategory() {
        let catalog = provider.catalog()

        let category = catalog.category(for: "privathaftpflicht")

        #expect(category != nil)
        #expect(category?.key == "privathaftpflicht")
        #expect(category?.needsLevel == 1)
    }

    @Test("Category lookup by key 'berufsunfaehigkeit' returns correct category")
    func lookupBerufsunfaehigkeitReturnsCorrectCategory() {
        let catalog = provider.catalog()

        let category = catalog.category(for: "berufsunfaehigkeit")

        #expect(category != nil)
        #expect(category?.key == "berufsunfaehigkeit")
        #expect(category?.needsLevel == 1)
    }

    @Test("Category lookup by key 'depot' returns level-2 category")
    func lookupDepotReturnsLevel2Category() {
        let catalog = provider.catalog()

        let category = catalog.category(for: "depot")

        #expect(category != nil)
        #expect(category?.needsLevel == 2)
    }

    @Test("Category lookup with unknown key returns nil")
    func lookupUnknownKeyReturnsNil() {
        let catalog = provider.catalog()

        let category = catalog.category(for: "unknown_category_xyz")

        #expect(category == nil)
    }

    @Test("Category lookup with empty key returns nil")
    func lookupEmptyKeyReturnsNil() {
        let catalog = provider.catalog()

        let category = catalog.category(for: "")

        #expect(category == nil)
    }
}

// MARK: - Criteria Lookup

@Suite("CatalogProvider — Criteria")
struct CatalogCriteriaTests {

    let provider = MockCatalogProvider()

    @Test("criteriaFor('privathaftpflicht') returns exactly 8 criteria")
    func criteriaForPrivathaftpflichtReturns8() {
        let criteria = provider.criteriaFor("privathaftpflicht")

        #expect(criteria.count == 8, "Privathaftpflicht has 8 evaluation criteria per catalog")
    }

    @Test("criteriaFor('berufsunfaehigkeit') returns exactly 5 criteria")
    func criteriaForBUReturns5() {
        let criteria = provider.criteriaFor("berufsunfaehigkeit")

        #expect(criteria.count == 5, "BU has 5 evaluation criteria per catalog")
    }

    @Test("criteriaFor('hausrat') returns exactly 5 criteria")
    func criteriaForHausratReturns5() {
        let criteria = provider.criteriaFor("hausrat")

        #expect(criteria.count == 5)
    }

    @Test("criteriaFor('kfz') returns exactly 7 criteria")
    func criteriaForKfzReturns7() {
        let criteria = provider.criteriaFor("kfz")

        #expect(criteria.count == 7)
    }

    @Test("criteriaFor('rechtsschutz') returns exactly 6 criteria")
    func criteriaForRechtsschutzReturns6() {
        let criteria = provider.criteriaFor("rechtsschutz")

        #expect(criteria.count == 6)
    }

    @Test("criteriaFor('risikoleben') returns exactly 5 criteria")
    func criteriaForRisikolebensversicherungReturns5() {
        let criteria = provider.criteriaFor("risikoleben")

        #expect(criteria.count == 5)
    }

    @Test("criteriaFor('reiseversicherung') returns exactly 5 criteria")
    func criteriaForReiseversicherungReturns5() {
        let criteria = provider.criteriaFor("reiseversicherung")

        #expect(criteria.count == 5)
    }

    @Test("criteriaFor unknown category key returns empty array")
    func criteriaForUnknownKeyReturnsEmptyArray() {
        let criteria = provider.criteriaFor("unknown_key")

        #expect(criteria.isEmpty)
    }

    @Test("All criteria have unique keys within their category")
    func allCriteriaHaveUniqueKeysWithinCategory() {
        let catalog = provider.catalog()
        for category in catalog.categories where !category.criteria.isEmpty {
            let keys = category.criteria.map { $0.key }
            let uniqueKeys = Set(keys)
            #expect(keys.count == uniqueKeys.count,
                    "Category '\(category.key)' has duplicate criterion keys")
        }
    }
}

// MARK: - Bilingual Category Names

@Suite("CatalogProvider — Bilingual Names")
struct CatalogBilingualTests {

    let provider = MockCatalogProvider()

    @Test("privathaftpflicht category has German name 'Privathaftpflicht'")
    func privathaftpflichtHasGermanName() {
        let catalog = provider.catalog()
        let category = catalog.category(for: "privathaftpflicht")

        #expect(category?.name(for: "de") == "Privathaftpflicht")
    }

    @Test("privathaftpflicht category has English name 'Personal Liability'")
    func privathaftpflichtHasEnglishName() {
        let catalog = provider.catalog()
        let category = catalog.category(for: "privathaftpflicht")

        #expect(category?.name(for: "en") == "Personal Liability")
    }

    @Test("berufsunfaehigkeit category has German name 'Berufsunfähigkeit'")
    func berufsunfaehigkeitHasGermanName() {
        let catalog = provider.catalog()
        let category = catalog.category(for: "berufsunfaehigkeit")

        #expect(category?.name(for: "de") == "Berufsunfähigkeit")
    }

    @Test("All categories have non-empty names in both DE and EN")
    func allCategoriesHaveNonEmptyBilingualNames() {
        let catalog = provider.catalog()
        for category in catalog.categories {
            #expect(!category.name(for: "de").isEmpty,
                    "Category '\(category.key)' has empty DE name")
            #expect(!category.name(for: "en").isEmpty,
                    "Category '\(category.key)' has empty EN name")
        }
    }

    @Test("Category names do not contain banned terms 'DIN 77230' or 'Defino'")
    func categoryNamesDoNotContainBannedTerms() {
        let catalog = provider.catalog()
        for category in catalog.categories {
            let de = category.name(for: "de")
            let en = category.name(for: "en")
            #expect(!de.contains("DIN 77230"), "DE name contains banned term 'DIN 77230'")
            #expect(!de.contains("Defino"), "DE name contains banned term 'Defino'")
            #expect(!en.contains("DIN 77230"), "EN name contains banned term 'DIN 77230'")
            #expect(!en.contains("Defino"), "EN name contains banned term 'Defino'")
        }
    }
}

// MARK: - byLevel grouping

@Suite("CatalogProvider — byLevel Grouping")
struct CatalogByLevelTests {

    let provider = MockCatalogProvider()

    @Test("byLevel[1] contains 11 level-1 categories")
    func byLevel1Contains11Categories() {
        let catalog = provider.catalog()
        #expect(catalog.byLevel[1]?.count == 11)
    }

    @Test("byLevel[2] contains 8 level-2 categories")
    func byLevel2Contains8Categories() {
        let catalog = provider.catalog()
        #expect(catalog.byLevel[2]?.count == 8)
    }

    @Test("byLevel[3] contains 3 level-3 categories")
    func byLevel3Contains3Categories() {
        let catalog = provider.catalog()
        #expect(catalog.byLevel[3]?.count == 3)
    }

    @Test("level1Categories helper returns 11 categories")
    func level1CategoriesReturns11() {
        let catalog = provider.catalog()
        #expect(catalog.level1Categories.count == 11)
    }
}
