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
//   - canSave: Bool (computed)

import Foundation
import Observation

@Observable
@MainActor
final class AddContractViewModel {

    // MARK: - Form state

    var selectedCategoryKey: String = ""
    var provider: String = ""
    var premiumAmountText: String = ""
    var premiumInterval: String = "monatlich"
    var contractNumber: String = ""

    // MARK: - Catalog (for category picker)

    let catalog: Catalog

    // MARK: - Validation

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
    /// Silently returns if canSave precondition is unmet (defensive guard for disabled button race).
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
            premiumInterval: premiumInterval.isEmpty ? nil : premiumInterval
        )
        try await contractRepository.save(contract)
    }
}
