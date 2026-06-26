// ContractListViewModel.swift
// ViewModels — @Observable. Imports Ports + Domain only. No framework imports.
// SCAFFOLD: true
//
// @contract-shape:bounded-change — state update bounded to: contracts, pendingContracts, isLoading, error.
//
// Universe (observable properties for state-delta assertions in tests):
//   - contracts: [Contract]              (confirmed portfolio)
//   - pendingContracts: [PendingContract] (awaiting user review)
//   - isLoading: Bool
//   - error: Error?

import Foundation
import Observation

// MARK: - ContractListViewModel

/// Driving port: manages the confirmed contract portfolio and the pending review queue.
/// Calls ContractRepository for all persistence operations.
@Observable
@MainActor
final class ContractListViewModel {

    // MARK: - Observable state (Universe)

    private(set) var contracts: [Contract] = []
    private(set) var pendingContracts: [PendingContract] = []
    private(set) var isLoading: Bool = false
    private(set) var error: Error?

    // MARK: - Dependencies (protocol-typed, injectable for tests)

    private let contractRepository: ContractRepository

    // MARK: - Init

    init(contractRepository: ContractRepository) {
        self.contractRepository = contractRepository
    }

    // MARK: - SCAFFOLD: fatalError placeholder
    // DELIVER wave: replace fatalError with real implementation.

    /// Loads confirmed contracts and pending contracts from the repository.
    func load() async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    /// Saves a new confirmed contract and reloads the portfolio.
    func add(contract: Contract) async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    /// Promotes a pending contract to confirmed and removes it from the review queue.
    /// Applies optional field corrections the user made during review.
    func confirm(pending: PendingContract, corrected: ContractFields? = nil) async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    /// Discards a pending contract (user rejected the OCR result).
    func discard(pending: PendingContract) async {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
