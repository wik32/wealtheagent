// ContractCategory.swift
// Domain — pure Swift value types. No framework imports beyond Foundation.
// SCAFFOLD: true

import Foundation

// MARK: - ContractCategory

/// One of the 22 types of insurance or financial products tracked by FinanzApp.
/// Vertragsart in German user-facing strings.
struct ContractCategory: Identifiable, Equatable, Codable {
    var id: String { key }
    var key: String                     // catalog identifier e.g. "privathaftpflicht"
    var nameDe: String
    var nameEn: String
    var needsLevel: Int                 // 1 | 2 | 3
    var purpose: String                 // Wozu dient dieser Vertrag?
    var relevance: String               // Warum ist das relevant? (never mentions DIN 77230 or Defino)
    var watch: String                   // Worauf achten?
    var fieldSpecs: [ContractFieldSpec]
    var criteria: [ContractCriterion]
    var knowledgeArticles: [KnowledgeArticle]

    /// Whether this category can show a DuplicateBeobachtung.
    /// Portfolio-type categories (depot, sparplan, tagesgeld_festgeld, liquiditaetsreserve)
    /// legitimately have multiple contracts — no duplicate observation raised.
    var allowsDuplicateObservation: Bool {
        let noDuplicateKeys: Set<String> = [
            "depot",
            "sparplan",
            "tagesgeld_festgeld",
            "liquiditaetsreserve"
        ]
        return !noDuplicateKeys.contains(key)
    }

    /// Localised display name.
    func name(locale: Locale) -> String {
        if locale.language.languageCode?.identifier == "de" {
            return nameDe
        }
        return nameEn
    }
}

// MARK: - ContractFieldSpec

/// A typed, labelled field definition within a category.
struct ContractFieldSpec: Equatable, Codable {
    var fieldKey: String
    var labelDe: String
    var labelEn: String
    var kind: FieldKind
    var required: Bool
    var choices: [ContractFieldChoice]
}

// MARK: - FieldKind

enum FieldKind: String, Equatable, Codable {
    case text
    case date
    case money
    case premium
    case intNum
    case boolean
    case choice
}

// MARK: - ContractFieldChoice

/// One option in a choice field.
struct ContractFieldChoice: Equatable, Codable {
    var value: String
    var labelDe: String
    var labelEn: String
}

// MARK: - ContractCriterion

/// A named quality criterion for comparing contracts of the same category.
/// Leistungskriterium in German user-facing strings.
struct ContractCriterion: Identifiable, Equatable, Codable {
    var id: String { key }
    var key: String
    var labelDe: String
    var labelEn: String
    var whyItMatters: String
}

// MARK: - KnowledgeArticle

/// Educational content about a contract category or topic.
/// Wissensartikel in German user-facing strings.
struct KnowledgeArticle: Identifiable, Equatable, Codable {
    var id: String
    var titleDe: String
    var titleEn: String
    var bodyDe: String
    var bodyEn: String
    // Note: body must NEVER contain "DIN 77230", "Defino", or "Empfehlung"
}
