// Contract.swift
// FinanzApp — Domain Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave
// Replace fatalError with real implementation in DELIVER wave.

import Foundation

// MARK: - PendingContract (OCR output awaiting user review)

/// An OCR-extracted contract record awaiting user review.
/// Not yet confirmed. Not visible to InsightsEngine.
/// DE: Entwurf
struct PendingContract: Identifiable, Codable {
    var id: UUID
    var categoryKey: String?
    var provider: String?
    var contractNumber: String?
    var startDate: Date?
    var premiumAmount: Double?
    var premiumInterval: String?
    var rawOCRText: String
    var ocrConfidence: Double
    var extractedAt: Date
    var fieldsJSON: String?
    var schemaVersion: String

    init(
        id: UUID = UUID(),
        categoryKey: String? = nil,
        provider: String? = nil,
        contractNumber: String? = nil,
        startDate: Date? = nil,
        premiumAmount: Double? = nil,
        premiumInterval: String? = nil,
        rawOCRText: String,
        ocrConfidence: Double,
        extractedAt: Date = Date(),
        fieldsJSON: String? = nil,
        schemaVersion: String = "1.0"
    ) {
        fatalError("Not yet implemented — RED scaffold")
    }
}

// MARK: - Contract (user-confirmed, stored in CloudKit)

/// A user-confirmed financial contract record.
/// The canonical user portfolio unit.
/// DE: Vertrag
struct Contract: Identifiable, Codable {
    var id: UUID
    var categoryKey: String
    var provider: String
    var contractNumber: String?
    var startDate: Date?
    var endDate: Date?
    var premiumAmount: Double?
    var premiumInterval: String?
    var fieldsJSON: String
    var criteriaJSON: String?
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
        fieldsJSON: String = "{}",
        criteriaJSON: String? = nil,
        confirmedAt: Date = Date(),
        schemaVersion: String = "1.0"
    ) {
        fatalError("Not yet implemented — RED scaffold")
    }
}

// MARK: - Domain Events (in-process, Stage 1)

/// Raised when a PendingContract is promoted to a Contract.
struct ContractConfirmed {
    let id: UUID
    let categoryKey: String
    let provider: String
    let confirmedAt: Date
}

/// Raised when a confirmed Contract is edited.
struct ContractEdited {
    let id: UUID
    let changedFields: [String]
}

/// Raised when a Contract is deleted from the portfolio.
struct ContractDeleted {
    let id: UUID
    let categoryKey: String
}
