// ContractRepository.swift
// Ports — Swift protocols. Import Domain only. No framework imports.
// SCAFFOLD: true

import Foundation

// MARK: - ContractRepository protocol

/// Driving port: the single point of access for storing and retrieving user contracts.
/// Implemented by LocalContractRepository (SwiftData) in production.
/// Implemented by MockContractRepository in tests.
protocol ContractRepository: Sendable {
    /// Returns all confirmed contracts in the portfolio.
    func list() async throws -> [Contract]

    /// Returns all pending contracts awaiting user review.
    func listPending() async throws -> [PendingContract]

    /// Persists a confirmed contract (create or update by id).
    func save(_ contract: Contract) async throws

    /// Persists a pending contract (after OCR extraction).
    func savePending(_ pending: PendingContract) async throws

    /// Atomically: delete the PendingContract + save the resulting confirmed Contract.
    /// Applies optional field corrections the user made during review.
    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract

    /// Permanently deletes a confirmed contract.
    func delete(id: UUID) async throws

    /// Permanently deletes a pending contract (user discarded).
    func discard(id: UUID) async throws
}
