// ContractCriterion.swift
// FinanzApp — Domain Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// A named quality criterion for evaluating contracts of a specific category.
/// DE: Leistungskriterium
/// Example: "Forderungsausfalldeckung" on Privathaftpflicht
struct ContractCriterion: Codable, Identifiable {
    var id: String { key }
    var key: String
    var labelDE: String
    var labelEN: String
    var descriptionDE: String?
    var descriptionEN: String?

    func label(for languageCode: String) -> String {
        fatalError("Not yet implemented — RED scaffold")
    }
}

/// Typed field specification for a contract category.
/// DE: Feld
struct ContractFieldSpec: Codable, Identifiable {
    var id: String { fieldKey }
    var fieldKey: String
    var labelDE: String
    var labelEN: String
    var kind: FieldKind
    var required: Bool
    var choices: [ContractFieldChoice]

    func label(for languageCode: String) -> String {
        fatalError("Not yet implemented — RED scaffold")
    }
}

/// The data type of a contract field.
enum FieldKind: String, Codable {
    case text
    case date
    case money
    case premium
    case intNum
    case boolean
    case choice
}

/// One option in a choice field.
/// DE: Auswahl
struct ContractFieldChoice: Codable {
    var key: String
    var labelDE: String
    var labelEN: String
}
