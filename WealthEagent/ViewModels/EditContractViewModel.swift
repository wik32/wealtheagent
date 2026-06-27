// EditContractViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only.
//
// Driving port: pre-filled form state for editing an existing confirmed Contract.
// Preserves the original contract.id on save → repository upserts by ID.
//
// Universe (observable properties for tests):
//   - selectedCategoryKey: String  (pre-filled from contract.categoryKey)
//   - provider: String             (pre-filled from contract.provider)
//   - premiumAmountText: String    (pre-filled, German comma notation)
//   - premiumInterval: String      (pre-filled)
//   - contractNumber: String       (pre-filled)
//   - criteriaChecked: [String: Bool] (pre-filled from contract.criteria)
//   - availableCriteria: [ContractCriterion] (computed)
//   - canSave: Bool (computed)

import Foundation
import Observation

@Observable
@MainActor
final class EditContractViewModel {

    // MARK: - Form state (pre-filled from existing Contract)

    var selectedCategoryKey: String {
        didSet { if oldValue != selectedCategoryKey { criteriaChecked = [:] } }
    }
    var provider: String
    var premiumAmountText: String
    var premiumInterval: String
    var contractNumber: String
    var hasStartDate: Bool
    var startDate: Date
    var hasEndDate: Bool
    var endDate: Date
    var criteriaChecked: [String: Bool]

    // MARK: - Catalog + identity

    let catalog: Catalog
    let existingId: UUID

    // MARK: - Computed

    var availableCriteria: [ContractCriterion] {
        catalog.criteriaFor(selectedCategoryKey)
    }

    var canSave: Bool {
        !provider.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedCategoryKey.isEmpty
    }

    // MARK: - Dependencies

    private let contractRepository: ContractRepository

    // MARK: - Init

    init(contract: Contract, contractRepository: ContractRepository, catalog: Catalog) {
        self.existingId = contract.id
        self.selectedCategoryKey = contract.categoryKey
        self.provider = contract.provider
        self.contractNumber = contract.contractNumber ?? ""
        self.premiumInterval = contract.premiumInterval ?? "monatlich"
        self.hasStartDate = contract.startDate != nil
        self.startDate = contract.startDate ?? Date()
        self.hasEndDate = contract.endDate != nil
        self.endDate = contract.endDate ?? Date()
        self.criteriaChecked = contract.criteria
        self.catalog = catalog
        self.contractRepository = contractRepository

        if let amount = contract.premiumAmount {
            self.premiumAmountText = String(format: "%.2f", amount)
                .replacingOccurrences(of: ".", with: ",")
        } else {
            self.premiumAmountText = ""
        }
    }

    // MARK: - Commands

    /// Saves the updated contract, preserving the original ID (upsert via repository).
    func save() async throws {
        let trimmedProvider = provider.trimmingCharacters(in: .whitespaces)
        guard !trimmedProvider.isEmpty, !selectedCategoryKey.isEmpty else { return }

        let amountText = premiumAmountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        let amount = Double(amountText)

        let updated = Contract(
            id: existingId,
            categoryKey: selectedCategoryKey,
            provider: trimmedProvider,
            contractNumber: contractNumber.isEmpty ? nil : contractNumber,
            startDate: hasStartDate ? startDate : nil,
            endDate: hasEndDate ? endDate : nil,
            premiumAmount: amount,
            premiumInterval: premiumInterval.isEmpty ? nil : premiumInterval,
            criteria: criteriaChecked
        )
        try await contractRepository.save(updated)
    }
}
