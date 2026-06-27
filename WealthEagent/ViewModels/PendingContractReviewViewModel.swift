// PendingContractReviewViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain + Foundation only.
//
// Driving port: confirm() or discard() on a PendingContract.
//
// Universe:
//   - selectedCategoryKey: String   (editable, pre-filled from OCR hint)
//   - provider: String              (editable, pre-filled from OCR)
//   - contractNumber: String        (editable, pre-filled from OCR)

import Foundation
import Observation

@Observable
@MainActor
final class PendingContractReviewViewModel {

    // MARK: - Observable state (user-editable form fields)

    var selectedCategoryKey: String
    var provider: String
    var contractNumber: String

    // MARK: - Read-only data

    let pending: PendingContract
    let catalog: Catalog

    // MARK: - Dependencies

    private let contractRepository: ContractRepository

    // MARK: - Init

    init(
        pending: PendingContract,
        contractRepository: ContractRepository,
        catalog: Catalog
    ) {
        self.pending = pending
        self.contractRepository = contractRepository
        self.catalog = catalog

        // Pre-fill from OCR extraction
        self.selectedCategoryKey = pending.categoryKey
        self.provider = pending.extractedFields["provider"]?.textValue ?? ""
        self.contractNumber = pending.extractedFields["contract_number"]?.textValue ?? ""
    }

    // MARK: - Validation

    var canConfirm: Bool {
        !provider.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // MARK: - Commands

    /// Creates a confirmed Contract from the reviewed fields and saves it.
    /// Atomically saves the confirmed Contract + discards the PendingContract.
    func confirm() async throws {
        let trimmedProvider = provider.trimmingCharacters(in: .whitespaces)
        let contract = Contract(
            categoryKey: selectedCategoryKey.isEmpty ? pending.categoryKey : selectedCategoryKey,
            provider: trimmedProvider.isEmpty ? "Unbekannt" : trimmedProvider,
            contractNumber: contractNumber.isEmpty ? nil : contractNumber,
            premiumAmount: pending.extractedFields["premium_amount"]?.numberValue,
            premiumInterval: pending.extractedFields["premium_interval"]?.textValue
        )
        try await contractRepository.save(contract)
        try await contractRepository.discard(id: pending.id)
    }

    /// Permanently discards the PendingContract (user rejected the OCR result).
    func discard() async throws {
        try await contractRepository.discard(id: pending.id)
    }
}

// MARK: - ContractFieldValue helpers

extension ContractFieldValue {
    var textValue: String? {
        if case .text(let str) = self { return str }
        return nil
    }

    var numberValue: Double? {
        if case .number(let num) = self { return num }
        return nil
    }
}
