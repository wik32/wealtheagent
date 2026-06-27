// InMemoryContractRepository.swift
// Adapters — in-memory ContractRepository for Stage 1 (no persistence).
// Used by WealthEagentApp until LocalContractRepository (SwiftData) is implemented.
// Thread-safe via actor isolation through @MainActor ViewModels.

import Foundation

// MARK: - InMemoryContractRepository

/// In-memory implementation of ContractRepository.
/// Returns empty collections; mutations are kept in memory for the session.
/// Stage 1 placeholder — replaced by LocalContractRepository when SwiftData is wired.
final class InMemoryContractRepository: ContractRepository, @unchecked Sendable {

    private var contracts: [Contract] = []
    private var pendingContracts: [PendingContract] = []

    func list() async throws -> [Contract] {
        return contracts
    }

    func listPending() async throws -> [PendingContract] {
        return pendingContracts
    }

    func save(_ contract: Contract) async throws {
        if let index = contracts.firstIndex(where: { $0.id == contract.id }) {
            contracts[index] = contract
        } else {
            contracts.append(contract)
        }
    }

    func savePending(_ pending: PendingContract) async throws {
        if let index = pendingContracts.firstIndex(where: { $0.id == pending.id }) {
            pendingContracts[index] = pending
        } else {
            pendingContracts.append(pending)
        }
    }

    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract {
        pendingContracts.removeAll { $0.id == pending.id }
        let confirmed = Contract(
            id: pending.id,
            categoryKey: pending.categoryKey,
            provider: pending.extractedFields.values["provider"]?.textValue ?? "Unknown",
            fields: corrected ?? pending.extractedFields,
            confirmedAt: Date()
        )
        contracts.append(confirmed)
        return confirmed
    }

    func delete(id: UUID) async throws {
        contracts.removeAll { $0.id == id }
    }

    func discard(id: UUID) async throws {
        pendingContracts.removeAll { $0.id == id }
    }
}

// textValue/numberValue helpers are defined in PendingContractReviewViewModel.swift
