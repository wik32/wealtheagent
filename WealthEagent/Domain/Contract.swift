// Contract.swift
// Domain — pure Swift value types. No framework imports beyond Foundation.
// SCAFFOLD: true

import Foundation

// MARK: - PendingContract

/// OCR-extracted contract record awaiting user review.
/// Entwurf in German user-facing strings.
/// Never passed to InsightsEngine — type system enforces the boundary.
struct PendingContract: Identifiable, Equatable {
    var id: UUID
    var categoryKey: String
    var rawOCRText: String
    var ocrConfidence: Double            // 0.0–1.0, mean across VNRecognizedTextObservations
    var extractedAt: Date
    var extractedFields: ContractFields
    var fieldConfidences: [String: FieldConfidence]
    var schemaVersion: String

    init(
        id: UUID = UUID(),
        categoryKey: String,
        rawOCRText: String,
        ocrConfidence: Double = 0.0,
        extractedAt: Date = Date(),
        extractedFields: ContractFields = ContractFields(),
        fieldConfidences: [String: FieldConfidence] = [:],
        schemaVersion: String = "1.0"
    ) {
        self.id = id
        self.categoryKey = categoryKey
        self.rawOCRText = rawOCRText
        self.ocrConfidence = ocrConfidence
        self.extractedAt = extractedAt
        self.extractedFields = extractedFields
        self.fieldConfidences = fieldConfidences
        self.schemaVersion = schemaVersion
    }
}

// MARK: - Contract

/// User-confirmed financial contract. Canonical portfolio unit.
/// Vertrag in German user-facing strings.
/// The only type InsightsEngine accepts — PendingContract is excluded by type.
struct Contract: Identifiable, Equatable {
    var id: UUID
    var categoryKey: String             // catalog key e.g. "privathaftpflicht"
    var provider: String                // required, non-empty
    var contractNumber: String?
    var startDate: Date?
    var endDate: Date?
    var premiumAmount: Double?          // EUR
    var premiumInterval: String?        // "monatlich" | "vierteljaehrlich" | "halbjaehrlich" | "jaehrlich" | "einmalig"
    var fields: ContractFields
    var criteria: [String: Bool]        // criterion key → met/not-met
    var confirmedAt: Date
    var schemaVersion: String

    init(
        id: UUID = UUID(),
        categoryKey: String,
        provider: String,
        contractNumber: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        premiumAmount: Double? = nil,
        premiumInterval: String? = nil,
        fields: ContractFields = ContractFields(),
        criteria: [String: Bool] = [:],
        confirmedAt: Date = Date(),
        schemaVersion: String = "1.0"
    ) {
        self.id = id
        self.categoryKey = categoryKey
        self.provider = provider
        self.contractNumber = contractNumber
        self.startDate = startDate
        self.endDate = endDate
        self.premiumAmount = premiumAmount
        self.premiumInterval = premiumInterval
        self.fields = fields
        self.criteria = criteria
        self.confirmedAt = confirmedAt
        self.schemaVersion = schemaVersion
    }
}

// MARK: - ContractFields (value object)

/// Typed field values for a specific contract. A value object — no independent identity.
struct ContractFields: Equatable, Codable {
    var values: [String: ContractFieldValue]

    init(_ values: [String: ContractFieldValue] = [:]) {
        self.values = values
    }

    subscript(key: String) -> ContractFieldValue? {
        get { values[key] }
        set { values[key] = newValue }
    }
}

// MARK: - ContractFieldValue

enum ContractFieldValue: Equatable, Codable {
    case text(String)
    case number(Double)
    case boolean(Bool)
    case date(Date)
    case choice(String)
}

// MARK: - FieldConfidence (value object)

/// Per-field OCR confidence. Present on PendingContract only.
/// Discarded after ContractConfirmed.
struct FieldConfidence: Equatable {
    var confidence: Double   // 0.0–1.0
    var needsReview: Bool
}
