// Catalog.swift
// Domain — pure Swift value types. No framework imports beyond Foundation.

import Foundation

// MARK: - Catalog

/// The complete collection of 22 contract categories, field specifications,
/// and knowledge articles. Loaded from catalog.json at startup.
struct Catalog: Equatable, Codable {
    var categories: [ContractCategory]
    var schemaVersion: String

    init(categories: [ContractCategory], schemaVersion: String = "1.0") {
        self.categories = categories
        self.schemaVersion = schemaVersion
    }

    // MARK: - Computed properties

    /// All categories grouped by needsLevel.
    /// Level 1 = Basisabsicherung (existential protection)
    /// Level 2 = Vermögensaufbau & Vorsorge (wealth building & provision)
    /// Level 3 = Ergänzungen (supplements)
    var byLevel: [Int: [ContractCategory]] {
        Dictionary(grouping: categories, by: \.needsLevel)
    }

    /// All level-1 categories (existential protection — the basis for gap detection).
    var level1Categories: [ContractCategory] {
        categories.filter { $0.needsLevel == 1 }
    }

    /// Look up a category by its key.
    func category(for key: String) -> ContractCategory? {
        categories.first { $0.key == key }
    }

    /// Criteria for a category identified by key.
    /// Returns empty array if category not found.
    func criteriaFor(_ key: String) -> [ContractCriterion] {
        category(for: key)?.criteria ?? []
    }
}
