// LocalContractRepository.swift
// Adapters — implements ContractRepository protocol using SwiftData.
//
// Note: CloudKit entitlement removed due to free Apple account limitation.
// SwiftData (local persistent store) is the mechanism for Stage 1.
// CloudKit will be added when paid account is available.
// The ContractRepository protocol is unchanged — swap is adapter-only.

import Foundation
import SwiftData

// MARK: - ContractRepositoryError

/// Errors thrown by ContractRepository implementations.
enum ContractRepositoryError: Error, Equatable {
    /// No record with the given identifier exists in the store.
    case notFound(UUID)
}

// MARK: - ContractRecord (@Model)

/// SwiftData persistent model for a confirmed contract.
/// Separate from the Contract domain value type — adapter layer only.
@Model
final class ContractRecord {
    var id: UUID
    var categoryKey: String
    var provider: String
    var contractNumber: String?
    var startDate: Date?
    var endDate: Date?
    var premiumAmount: Double?
    var premiumInterval: String?
    var fieldsData: Data
    var criteriaData: Data
    var confirmedAt: Date
    var schemaVersion: String

    init(from contract: Contract) throws {
        id = contract.id
        categoryKey = contract.categoryKey
        provider = contract.provider
        contractNumber = contract.contractNumber
        startDate = contract.startDate
        endDate = contract.endDate
        premiumAmount = contract.premiumAmount
        premiumInterval = contract.premiumInterval
        fieldsData = try JSONEncoder().encode(contract.fields)
        criteriaData = try JSONEncoder().encode(contract.criteria)
        confirmedAt = contract.confirmedAt
        schemaVersion = contract.schemaVersion
    }

    func toDomain() throws -> Contract {
        Contract(
            id: id,
            categoryKey: categoryKey,
            provider: provider,
            contractNumber: contractNumber,
            startDate: startDate,
            endDate: endDate,
            premiumAmount: premiumAmount,
            premiumInterval: premiumInterval,
            fields: try JSONDecoder().decode(ContractFields.self, from: fieldsData),
            criteria: try JSONDecoder().decode([String: Bool].self, from: criteriaData),
            confirmedAt: confirmedAt,
            schemaVersion: schemaVersion
        )
    }
}

// MARK: - PendingContractRecord (@Model)

/// SwiftData persistent model for a pending (OCR-extracted) contract.
@Model
final class PendingContractRecord {
    var id: UUID
    var categoryKey: String
    var rawOCRText: String
    var ocrConfidence: Double
    var extractedAt: Date
    var extractedFieldsData: Data
    var schemaVersion: String

    init(from pending: PendingContract) throws {
        id = pending.id
        categoryKey = pending.categoryKey
        rawOCRText = pending.rawOCRText
        ocrConfidence = pending.ocrConfidence
        extractedAt = pending.extractedAt
        extractedFieldsData = try JSONEncoder().encode(pending.extractedFields)
        schemaVersion = pending.schemaVersion
    }

    func toDomain() throws -> PendingContract {
        PendingContract(
            id: id,
            categoryKey: categoryKey,
            rawOCRText: rawOCRText,
            ocrConfidence: ocrConfidence,
            extractedAt: extractedAt,
            extractedFields: try JSONDecoder().decode(ContractFields.self, from: extractedFieldsData),
            schemaVersion: schemaVersion
        )
    }
}

// MARK: - LocalContractRepository

/// Implements ContractRepository using SwiftData local persistence.
/// Driven internal port — real adapter, not a fake.
/// Invoked by ViewModels via the ContractRepository protocol.
///
/// Test isolation: inject a ModelContainer configured with
/// `ModelConfiguration(isStoredInMemoryOnly: true)` in setUp().
@MainActor
final class LocalContractRepository: ContractRepository {

    private let modelContext: ModelContext

    init(modelContainer: ModelContainer) {
        modelContext = ModelContext(modelContainer)
    }

    // MARK: - ContractRepository

    func list() async throws -> [Contract] {
        try modelContext
            .fetch(FetchDescriptor<ContractRecord>())
            .map { try $0.toDomain() }
    }

    func listPending() async throws -> [PendingContract] {
        try modelContext
            .fetch(FetchDescriptor<PendingContractRecord>())
            .map { try $0.toDomain() }
    }

    func save(_ contract: Contract) async throws {
        if let existing = try fetchContractRecord(id: contract.id) {
            modelContext.delete(existing)
        }
        modelContext.insert(try ContractRecord(from: contract))
        try modelContext.save()
    }

    func savePending(_ pending: PendingContract) async throws {
        if let existing = try fetchPendingRecord(id: pending.id) {
            modelContext.delete(existing)
        }
        modelContext.insert(try PendingContractRecord(from: pending))
        try modelContext.save()
    }

    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract {
        guard let pendingRecord = try fetchPendingRecord(id: pending.id) else {
            throw ContractRepositoryError.notFound(pending.id)
        }
        let effectiveFields = corrected ?? pending.extractedFields
        let confirmed = Contract(
            id: pending.id,
            categoryKey: pending.categoryKey,
            provider: providerName(from: effectiveFields, fallback: pending.categoryKey),
            fields: effectiveFields,
            confirmedAt: Date()
        )
        modelContext.delete(pendingRecord)
        modelContext.insert(try ContractRecord(from: confirmed))
        try modelContext.save()
        return confirmed
    }

    func delete(id: UUID) async throws {
        guard let record = try fetchContractRecord(id: id) else {
            throw ContractRepositoryError.notFound(id)
        }
        modelContext.delete(record)
        try modelContext.save()
    }

    func discard(id: UUID) async throws {
        guard let record = try fetchPendingRecord(id: id) else {
            throw ContractRepositoryError.notFound(id)
        }
        modelContext.delete(record)
        try modelContext.save()
    }

    // MARK: - Private helpers

    private func fetchContractRecord(id: UUID) throws -> ContractRecord? {
        var descriptor = FetchDescriptor<ContractRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func fetchPendingRecord(id: UUID) throws -> PendingContractRecord? {
        var descriptor = FetchDescriptor<PendingContractRecord>(
            predicate: #Predicate { $0.id == id }
        )
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }

    private func providerName(from fields: ContractFields, fallback: String) -> String {
        if case .text(let name) = fields.values["provider"] { return name }
        return fallback
    }
}
