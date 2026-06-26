// Catalog.swift
// FinanzApp — Domain Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// The complete collection of contract categories, field specifications, and knowledge articles.
/// Loaded from catalog.json at startup. Read-only. Offline-capable.
/// DE: Katalog
struct Catalog: Codable {
    var schemaVersion: String
    var categories: [ContractCategory]

    /// Returns categories grouped by needsLevel (1, 2, or 3).
    var byLevel: [Int: [ContractCategory]] {
        fatalError("Not yet implemented — RED scaffold")
    }

    /// Returns all level-1 categories (existential protection).
    var level1Categories: [ContractCategory] {
        fatalError("Not yet implemented — RED scaffold")
    }

    /// Look up a category by its canonical key (e.g. "privathaftpflicht").
    func category(for key: String) -> ContractCategory? {
        fatalError("Not yet implemented — RED scaffold")
    }

    /// Returns the evaluation criteria for a given category key.
    func criteria(for categoryKey: String) -> [ContractCriterion] {
        fatalError("Not yet implemented — RED scaffold")
    }
}
