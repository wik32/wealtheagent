// CompareViewModel.swift
// ViewModels — @Observable. Imports Domain only. No framework imports.
//
// Driving port: comparison matrix for two or more contracts of the same category.
// Consumed by CompareView to render the side-by-side Leistungskriterien grid.
//
// Stage-1 vocabulary constraint (CLAUDE.md):
//   - "Kriterien erfüllt" — factual count
//   - "Empfehlung" / "empfehlen" are BANNED

import Foundation
import Observation

// MARK: - Supporting types

/// One row in the criterion comparison grid.
struct CriterionComparisonRow: Identifiable {
    var id: String { criterion.key }
    let criterion: ContractCriterion
    /// Contract ID → true (met) / false (not met) / nil (not assessed)
    let results: [UUID: Bool?]
}

/// Summary card for one contract in the comparison header.
struct ContractComparisonSummary: Identifiable {
    var id: UUID { contract.id }
    let contract: Contract
    /// Number of criteria that are explicitly `true` in `contract.criteria`.
    let metCount: Int
    let totalCriteria: Int

    var scoreText: String { "\(metCount)/\(totalCriteria) Kriterien erfüllt" }
}

// MARK: - CompareViewModel

/// View model for the side-by-side contract comparison screen.
/// Computes CriterionComparisonRow + ContractComparisonSummary purely from domain values.
@Observable
@MainActor
final class CompareViewModel {

    // MARK: - Computed comparison data

    let categoryName: String
    let contracts: [Contract]
    let criterionRows: [CriterionComparisonRow]
    let summaries: [ContractComparisonSummary]

    // MARK: - Init

    init(categoryKey: String, contracts: [Contract], catalog: Catalog) {
        self.contracts = contracts
        let category = catalog.category(for: categoryKey)
        self.categoryName = category?.nameDe ?? categoryKey
        let criteria = catalog.criteriaFor(categoryKey)

        self.criterionRows = criteria.map { criterion in
            var results: [UUID: Bool?] = [:]
            for contract in contracts {
                results[contract.id] = contract.criteria[criterion.key]
            }
            return CriterionComparisonRow(criterion: criterion, results: results)
        }

        self.summaries = contracts.map { contract in
            let metCount = criteria.filter { contract.criteria[$0.key] == true }.count
            return ContractComparisonSummary(
                contract: contract,
                metCount: metCount,
                totalCriteria: criteria.count
            )
        }
    }
}
