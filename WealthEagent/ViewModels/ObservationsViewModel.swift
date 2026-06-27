// ObservationsViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only. No framework imports.

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
///
/// @contract-shape:bounded-change — state update bounded to: insights, isLoading, error.
@Observable
@MainActor
final class ObservationsViewModel {

    // MARK: - Observable state (Universe)

    private(set) var insights: FinInsights = FinInsights()
    private(set) var contracts: [Contract] = []
    private(set) var catalog: Catalog = Catalog(categories: [])
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

    // MARK: - Commands

    /// Loads confirmed contracts from the repository and computes Beobachtungen.
    func loadInsights() async {
        isLoading = true
        error = nil
        do {
            let contracts = try await contractRepository.list()
            let catalog = catalogProvider.catalog()
            insights = InsightsEngine.insights(contracts: contracts, catalog: catalog)
            self.contracts = contracts
            self.catalog = catalog
        } catch {
            self.error = error
            insights = FinInsights()
        }
        isLoading = false
    }

    /// Clears all Beobachtungen and error state (called on sign-out).
    func signOut() {
        insights = FinInsights()
        error = nil
    }
}
