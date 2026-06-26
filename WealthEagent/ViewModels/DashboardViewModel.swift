// DashboardViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only. No framework imports.
//
// @contract-shape:bounded-change — state updates bounded to: coverageScore, monthlySpend, isLoading, error.
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

    // MARK: - Commands

    /// Loads contracts and computes the coverage score and monthly spend.
    func load() async {
        isLoading = true
        error = nil
        do {
            let contracts = try await contractRepository.list()
            let catalog = catalogProvider.catalog()
            let computed = InsightsEngine.insights(contracts: contracts, catalog: catalog)
            coverageScore = computed.coverageScore
            monthlySpend = DashboardViewModel.computeMonthlySpend(contracts: contracts)
        } catch {
            self.error = error
            coverageScore = 0
            monthlySpend = 0.0
        }
        isLoading = false
    }

    // MARK: - Private helpers

    private static func computeMonthlySpend(contracts: [Contract]) -> Double {
        contracts.reduce(0.0) { total, contract in
            guard let amount = contract.premiumAmount else { return total }
            let monthly = monthlyEquivalent(amount: amount, interval: contract.premiumInterval)
            return total + monthly
        }
    }

    private static func monthlyEquivalent(amount: Double, interval: String?) -> Double {
        switch interval {
        case "monatlich":        return amount
        case "vierteljaehrlich": return amount / 3.0
        case "halbjaehrlich":    return amount / 6.0
        case "jaehrlich":        return amount / 12.0
        case "einmalig":         return 0.0
        default:                 return amount
        }
    }
}
