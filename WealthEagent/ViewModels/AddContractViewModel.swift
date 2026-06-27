// AddContractViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only.
//
// Driving port: form state + validation + save for the manual add-contract flow.
// Injected into AddContractView.
//
// Universe (observable properties for tests):
//   - selectedCategoryKey: String
//   - provider: String
//   - premiumAmountText: String
//   - premiumInterval: String
//   - contractNumber: String
//   - criteriaChecked: [String: Bool]
//   - availableCriteria: [ContractCriterion] (computed)
//   - canSave: Bool (computed)

import Foundation
import Observation

@Observable
@MainActor
final class AddContractViewModel {

    // MARK: - Form state

    var selectedCategoryKey: String = "" {
        didSet { if oldValue != selectedCategoryKey { resetCriteria() } }
    }
    var provider: String = ""
    var premiumAmountText: String = ""
    var premiumInterval: String = "monatlich"
    var contractNumber: String = ""

    /// Criterion key → user-checked (true = contract covers this criterion).
    var criteriaChecked: [String: Bool] = [:]

    // MARK: - Catalog (for pickers)

    let catalog: Catalog

    // MARK: - Computed

    /// Criteria available for the currently selected category.
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

    init(contractRepository: ContractRepository, catalog: Catalog) {
        self.contractRepository = contractRepository
        self.catalog = catalog
    }

    // MARK: - Commands

    /// Builds a Contract from form state and persists it via the repository.
    func save() async throws {
        let trimmedProvider = provider.trimmingCharacters(in: .whitespaces)
        guard !trimmedProvider.isEmpty, !selectedCategoryKey.isEmpty else { return }

        let amountText = premiumAmountText
            .replacingOccurrences(of: ",", with: ".")
            .trimmingCharacters(in: .whitespaces)
        let amount = Double(amountText)

        let contract = Contract(
            categoryKey: selectedCategoryKey,
            provider: trimmedProvider,
            contractNumber: contractNumber.isEmpty ? nil : contractNumber,
            premiumAmount: amount,
            premiumInterval: premiumInterval.isEmpty ? nil : premiumInterval,
            criteria: criteriaChecked
        )
        try await contractRepository.save(contract)
    }

    // MARK: - Private

    private func resetCriteria() {
        criteriaChecked = [:]
    }
}
