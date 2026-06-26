// DashboardViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only. No framework imports.
// SCAFFOLD: true
//
// @contract-shape:bounded-change — state update bounded to: coverageScore, monthlySpend, isLoading, error.
//
// Universe (observable properties for state-delta assertions in tests):
//   - coverageScore: Int     (0–100, % of level-1 categories covered)
//   - monthlySpend: Double   (sum of all monthly-equivalent premiums, EUR)
//   - isLoading: Bool
//   - error: Error?

import Foundation
import Observation

// MARK: - DashboardViewModel

/// Driving port: computes portfolio score and monthly spend for the Dashboard tab.
/// Calls ContractRepository.list() + CatalogProvider.catalog() → InsightsEngine.
@Observable
@MainActor
final class DashboardViewModel {

    // MARK: - Observable state (Universe)

    /// Percentage of level-1 categories covered by ≥1 confirmed contract (0–100).
    /// Abdeckungsgrad in German user-facing strings.
    private(set) var coverageScore: Int = 0

    /// Sum of all confirmed contract premiums normalised to monthly EUR.
    /// Monatliche Ausgaben in German user-facing strings.
    private(set) var monthlySpend: Double = 0.0

    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    // MARK: - Dependencies (protocol-typed, injectable for tests)

    private let contractRepository: ContractRepository
    private let catalogProvider: CatalogProvider

    // MARK: - Init

    init(contractRepository: ContractRepository, catalogProvider: CatalogProvider) {
        self.contractRepository = contractRepository
        self.catalogProvider = catalogProvider
    }

    // MARK: - SCAFFOLD: fatalError placeholder
    // DELIVER wave: replace fatalError with real implementation.

    /// Loads contracts and computes the coverage score and monthly spend.
    func load() async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
