// ContractCategory.swift
// FinanzApp — Domain Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// One of the 22 types of insurance or financial products tracked by FinanzApp.
/// DE: Vertragsart
struct ContractCategory: Codable, Identifiable {
    var id: String { key }
    var key: String
    var nameDE: String
    var nameEN: String
    var needsLevel: Int
    var purpose: String?
    var relevance: String?
    var watch: String?
    var fields: [ContractFieldSpec]
    var criteria: [ContractCriterion]
    var knowledgeArticles: [KnowledgeArticle]

    /// Returns the localised name based on the provided locale language code.
    /// - Parameter languageCode: "de" or "en" — defaults to "de".
    func name(for languageCode: String) -> String {
        fatalError("Not yet implemented — RED scaffold")
    }
}

/// Whether a given category allows duplicate detection.
/// depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve do NOT trigger duplicate observations.
extension ContractCategory {
    var allowsDuplicateObservation: Bool {
        fatalError("Not yet implemented — RED scaffold")
    }
}

/// Knowledge article linked from an observation.
/// DE: Wissensartikel
struct KnowledgeArticle: Codable, Identifiable {
    var id: String
    var title: String
    var body: String
}
