// LocalContractRepository.swift
// Adapters — implements ContractRepository protocol using SwiftData.
// SCAFFOLD: true
//
// Note: CloudKit entitlement removed due to free Apple account limitation.
// SwiftData (local persistent store) is the mechanism for Stage 1.
// CloudKit will be added when paid account is available.
// The ContractRepository protocol is unchanged — swap is adapter-only.

import Foundation
// SwiftData import will be added by DELIVER crafter when implementing
// Do not import SwiftData here in the scaffold to avoid compile errors
// in targets that do not include SwiftData support yet.

// MARK: - LocalContractRepository

/// Implements ContractRepository using SwiftData local persistence.
/// Driven internal port — real adapter (not a fake).
/// Invoked by ViewModels via the ContractRepository protocol.
final class LocalContractRepository: ContractRepository {

    // MARK: - SCAFFOLD: fatalError placeholders
    // DELIVER wave: replace with SwiftData ModelContainer + ModelContext implementation.

    func list() async throws -> [Contract] {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func listPending() async throws -> [PendingContract] {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func save(_ contract: Contract) async throws {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func savePending(_ pending: PendingContract) async throws {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func delete(id: UUID) async throws {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }

    func discard(id: UUID) async throws {
        fatalError("Not yet implemented — RED scaffold. DELIVER wave replaces this.")
    }
}
