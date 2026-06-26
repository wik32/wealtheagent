// ObservationsViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only. No framework imports.
// SCAFFOLD: true

import Foundation
import Observation

// MARK: - ObservationsViewModel

/// Driving port: coordinates InsightsEngine with ContractRepository and CatalogProvider.
/// Populates the Beobachtungen (Observations) tab in the UI.
///
/// Observable properties (Universe for state-delta assertions in tests):
///   - insights: FinInsights
///   - isLoading: Bool
///   - error: Error?
@Observable
final class ObservationsViewModel {

    // MARK: - Observable state (Universe)

    private(set) var insights: FinInsights = FinInsights()
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

    /// Loads confirmed contracts from the repository and computes Beobachtungen.
    @MainActor
    func loadInsights() async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
