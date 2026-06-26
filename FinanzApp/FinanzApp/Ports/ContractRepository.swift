// ContractRepository.swift
// FinanzApp — Ports Layer
// SCAFFOLD: true — RED scaffold created by DISTILL wave

import Foundation

/// Driving port: the entry point for all contract persistence operations.
/// Implemented by CloudKitContractRepository in production.
/// Implemented by MockContractRepository in tests and SwiftUI Previews.
protocol ContractRepository {

    /// Returns all confirmed contracts in the user's portfolio.
    func listContracts() async throws -> [Contract]

    /// Returns all pending contracts (OCR output awaiting review).
    func listPendingContracts() async throws -> [PendingContract]

    /// Persists a confirmed contract. Upsert semantics (idempotent by id).
    func save(_ contract: Contract) async throws

    /// Saves an OCR extraction result as a PendingContract awaiting user review.
    func savePending(_ pending: PendingContract) async throws

    /// Atomically deletes the PendingContract and saves a new Contract.
    /// The corrected fields (if non-nil) override the OCR-extracted fields.
    func confirm(_ pending: PendingContract, corrected: [String: String]?) async throws

    /// Discards a PendingContract without creating a Contract.
    func discard(_ pending: PendingContract) async throws

    /// Permanently removes a confirmed Contract from the portfolio.
    func delete(id: UUID) async throws

    /// Deletes PendingContracts older than the given date (orphan cleanup).
    func deleteOrphanedPending(olderThan: Date) async throws

    /// Verifies substrate availability (CloudKit account, zone, write access).
    /// Called at app startup before ViewModels are created.
    func probe() async -> ProbeResult
}

/// Result of a substrate verification probe.
enum ProbeResult {
    case success
    case failure(ProbeFailure)
}

struct ProbeFailure {
    let component: String
    let lie: String
    let suggestion: String
}
