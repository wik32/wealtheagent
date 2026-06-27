// LocalContractRepository.swift
// Adapters — implements ContractRepository protocol using SwiftData.
// SCAFFOLD: true
//
// Note: CloudKit entitlement removed due to free Apple account limitation.
// SwiftData (local persistent store) is the mechanism for Stage 1.
// CloudKit will be added when paid account is available.
// The ContractRepository protocol is unchanged — swap is adapter-only.
//
// DELIVER wave: replace every fatalError with a real SwiftData implementation.
// Pattern:
//   1. Add `import SwiftData`
//   2. Store a `ModelContainer` (injected via init)
//   3. Each method opens a `@MainActor ModelContext` from the container and
//      operates on `ContractRecord` / `PendingContractRecord` @Model objects
//   4. Map @Model ↔ Domain value types via the extensions at the bottom of this file.

import Foundation
// SwiftData import added by DELIVER when @Model types are defined.
// import SwiftData

// MARK: - ContractRepositoryError

/// Errors thrown by ContractRepository implementations.
enum ContractRepositoryError: Error, Equatable {
    /// No record with the given identifier exists in the store.
    case notFound(UUID)
}

// MARK: - LocalContractRepository

/// Implements ContractRepository using SwiftData local persistence.
/// Driven internal port — real adapter, not a fake.
/// Invoked by ViewModels via the ContractRepository protocol.
///
/// Test isolation: inject a ModelContainer configured with
/// `ModelConfiguration(isStoredInMemoryOnly: true)` in setUp().
final class LocalContractRepository: ContractRepository, @unchecked Sendable {

    // MARK: - SCAFFOLD placeholder
    // DELIVER wave: inject ModelContainer and implement below.
    //
    // Example init (DELIVER fills this in):
    //   init(modelContainer: ModelContainer) {
    //       self.modelContainer = modelContainer
    //   }
    //   private let modelContainer: ModelContainer

    func list() async throws -> [Contract] {
        // DELIVER: fetch all ContractRecord from ModelContext, map to Contract
        throw ContractRepositoryError.notFound(UUID())
    }

    func listPending() async throws -> [PendingContract] {
        // DELIVER: fetch all PendingContractRecord from ModelContext, map to PendingContract
        throw ContractRepositoryError.notFound(UUID())
    }

    func save(_ contract: Contract) async throws {
        // DELIVER: upsert ContractRecord in ModelContext (insert or update by id)
        throw ContractRepositoryError.notFound(UUID())
    }

    func savePending(_ pending: PendingContract) async throws {
        // DELIVER: upsert PendingContractRecord in ModelContext
        throw ContractRepositoryError.notFound(UUID())
    }

    func confirm(_ pending: PendingContract, corrected: ContractFields?) async throws -> Contract {
        // DELIVER:
        //   1. Fetch PendingContractRecord by pending.id — throw .notFound if absent
        //   2. Build Contract value from pending + corrected fields
        //   3. Delete PendingContractRecord
        //   4. Insert ContractRecord
        //   5. try modelContext.save()
        //   6. Return the new Contract value
        throw ContractRepositoryError.notFound(pending.id)
    }

    func delete(id: UUID) async throws {
        // DELIVER: fetch ContractRecord by id, delete, save context
        throw ContractRepositoryError.notFound(id)
    }

    func discard(id: UUID) async throws {
        // DELIVER: fetch PendingContractRecord by id, delete, save context
        throw ContractRepositoryError.notFound(id)
    }
}

// MARK: - SwiftData @Model types (SCAFFOLD — defined here for test compilation)
//
// DELIVER: move these into their own files and add `import SwiftData`.
// Annotate with @Model. The init and mapping extensions below drive the
// ContractRecord <-> Contract round-trip.
//
// @Model
// final class ContractRecord { ... }
//
// @Model
// final class PendingContractRecord { ... }
//
// Each @Model class mirrors the Contract / PendingContract domain fields
// using SwiftData-compatible types (String, Double, Date, Data for encoded blobs).
// The JSON encoding strategy follows ADR-002 (fieldsJSON as String).
